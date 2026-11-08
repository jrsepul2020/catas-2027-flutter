-- Recata controlada (solo admin / service_role).
-- Las tablets (anon / authenticated) NO pueden ejecutar reabrir_muestra.
--
-- Flujo:
--   1) Admin llama: SELECT public.reabrir_muestra(<tanda_muestra_id>, false, true, 'motivo');
--   2) Muestra → pendiente (ABRIR CATA en tablet presidente).
--   3) Puntuaciones aprobada → enviada (notas conservadas si p_borrar_notas=false).
--   4) Tras ABRIR CATA + reenviar + aprobar, el candado vuelve a cerrar.

-- ── Bypass de sesión para el candado (solo dentro de la función) ───

CREATE OR REPLACE FUNCTION public.proteger_puntuacion_aprobada()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  estado_muestra text;
BEGIN
  -- Recata admin: saltar candado solo si la transacción lo pidió.
  IF coalesce(current_setting('app.recata_bypass', true), '') = '1' THEN
    IF TG_OP = 'DELETE' THEN
      RETURN OLD;
    END IF;
    RETURN NEW;
  END IF;

  IF TG_OP = 'DELETE' THEN
    IF lower(coalesce(OLD.estado, '')) <> 'aprobada' THEN
      RETURN OLD;
    END IF;
  ELSIF TG_OP = 'UPDATE' THEN
    IF lower(coalesce(OLD.estado, '')) <> 'aprobada' THEN
      RETURN NEW;
    END IF;
  ELSE
    RETURN NEW;
  END IF;

  SELECT lower(trim(coalesce(tm.estado, '')))
    INTO estado_muestra
  FROM public.tanda_muestras tm
  WHERE tm.tanda_id = OLD.tanda_id
    AND tm.muestra_id = OLD.muestra_id
  LIMIT 1;

  IF estado_muestra IN ('completada', 'finalizada') THEN
    RAISE EXCEPTION 'Esta muestra ya fue aprobada y no admite cambios.';
  END IF;

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_proteger_puntuacion_aprobada ON public.puntuaciones;
CREATE TRIGGER trg_proteger_puntuacion_aprobada
  BEFORE UPDATE OR DELETE ON public.puntuaciones
  FOR EACH ROW
  EXECUTE FUNCTION public.proteger_puntuacion_aprobada();

-- ── Historial de recatas ───────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.muestra_recata_historial (
  id               bigserial PRIMARY KEY,
  tanda_muestra_id integer NOT NULL REFERENCES public.tanda_muestras(id) ON DELETE CASCADE,
  tanda_id         integer,
  muestra_id       integer,
  actor            text NOT NULL DEFAULT CURRENT_USER,
  motivo           text,
  borrar_notas     boolean NOT NULL DEFAULT false,
  al_final         boolean NOT NULL DEFAULT false,
  created_at       timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_recata_hist_tm
  ON public.muestra_recata_historial (tanda_muestra_id, created_at DESC);

ALTER TABLE public.muestra_recata_historial ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS lectura_recata_historial ON public.muestra_recata_historial;
-- Lectura solo con rol de servicio / postgres (sin policy = denegado a anon).
-- Escritura únicamente vía función SECURITY DEFINER.

REVOKE ALL ON TABLE public.muestra_recata_historial FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT ON TABLE public.muestra_recata_historial TO postgres, service_role;
GRANT USAGE, SELECT ON SEQUENCE public.muestra_recata_historial_id_seq TO postgres, service_role;

-- ── Función admin ─────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.reabrir_muestra(
  p_tanda_muestra_id integer,
  p_borrar_notas boolean DEFAULT false,
  p_al_final boolean DEFAULT false,
  p_motivo text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_tm        public.tanda_muestras%ROWTYPE;
  v_max_orden integer;
  v_actor     text := CURRENT_USER;
  v_notas     integer := 0;
BEGIN
  SELECT * INTO v_tm
  FROM public.tanda_muestras
  WHERE id = p_tanda_muestra_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'reabrir_muestra: tanda_muestra_id % no existe', p_tanda_muestra_id;
  END IF;

  -- Candado: bypass solo en esta transacción.
  PERFORM set_config('app.recata_bypass', '1', true);

  IF p_borrar_notas THEN
    DELETE FROM public.puntuaciones
    WHERE tanda_id = v_tm.tanda_id
      AND muestra_id = v_tm.muestra_id;
    GET DIAGNOSTICS v_notas = ROW_COUNT;
  ELSE
    UPDATE public.puntuaciones
    SET estado = 'enviada',
        updated_at = now()
    WHERE tanda_id = v_tm.tanda_id
      AND muestra_id = v_tm.muestra_id
      AND lower(coalesce(estado, '')) = 'aprobada';
    GET DIAGNOSTICS v_notas = ROW_COUNT;
  END IF;

  IF p_al_final THEN
    SELECT coalesce(max(orden), 0) INTO v_max_orden
    FROM public.tanda_muestras
    WHERE tanda_id = v_tm.tanda_id
      AND id <> v_tm.id;

    UPDATE public.tanda_muestras
    SET orden = v_max_orden + 1,
        estado = 'pendiente',
        incidencia_motivo = NULL
    WHERE id = v_tm.id;
  ELSE
    UPDATE public.tanda_muestras
    SET estado = 'pendiente',
        incidencia_motivo = NULL
    WHERE id = v_tm.id;
  END IF;

  INSERT INTO public.muestra_recata_historial (
    tanda_muestra_id, tanda_id, muestra_id,
    actor, motivo, borrar_notas, al_final
  ) VALUES (
    v_tm.id, v_tm.tanda_id, v_tm.muestra_id,
    v_actor, nullif(trim(coalesce(p_motivo, '')), ''),
    p_borrar_notas, p_al_final
  );

  -- Apaga bypass al terminar (también se limpia al cerrar la tx).
  PERFORM set_config('app.recata_bypass', '', true);

  RETURN jsonb_build_object(
    'ok', true,
    'tanda_muestra_id', v_tm.id,
    'tanda_id', v_tm.tanda_id,
    'muestra_id', v_tm.muestra_id,
    'estado', 'pendiente',
    'borrar_notas', p_borrar_notas,
    'al_final', p_al_final,
    'filas_puntuacion', v_notas,
    'actor', v_actor
  );
END;
$$;

COMMENT ON FUNCTION public.reabrir_muestra(integer, boolean, boolean, text) IS
  'Recata admin: reabre muestra (pendiente), puntuaciones aprobada→enviada o borra notas; opcional al final de tanda. Solo service_role.';

-- Nadie desde tablets.
REVOKE ALL ON FUNCTION public.reabrir_muestra(integer, boolean, boolean, text)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.reabrir_muestra(integer, boolean, boolean, text)
  TO postgres, service_role;
