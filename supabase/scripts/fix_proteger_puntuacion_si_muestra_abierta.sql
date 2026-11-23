-- Candado: solo bloquear notas `aprobada` si la muestra sigue CERRADA.
-- En Geekom había un trigger más estricto que impedía editar aunque la
-- muestra estuviera `activa`/`pendiente` → la app mostraba "ya fue cerrada".

CREATE OR REPLACE FUNCTION public.proteger_puntuacion_aprobada()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  estado_muestra text;
BEGIN
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

  -- Abierta / en curso / pendiente / incidencia → se puede editar (recata / reabrir).
  IF estado_muestra IS NULL
     OR estado_muestra NOT IN ('completada', 'finalizada') THEN
    IF TG_OP = 'DELETE' THEN
      RETURN OLD;
    END IF;
    RETURN NEW;
  END IF;

  RAISE EXCEPTION 'MUESTRA_APROBADA: esta muestra ya fue aprobada y no admite cambios';
END;
$$;

DROP TRIGGER IF EXISTS trg_proteger_puntuacion_aprobada ON public.puntuaciones;
DROP TRIGGER IF EXISTS proteger_puntuacion_aprobada ON public.puntuaciones;
DROP TRIGGER IF EXISTS trg_puntuaciones_aprobada ON public.puntuaciones;
DROP TRIGGER IF EXISTS puntuaciones_proteger_aprobada ON public.puntuaciones;
DROP TRIGGER IF EXISTS bloquear_puntuacion_aprobada ON public.puntuaciones;
DROP TRIGGER IF EXISTS trg_bloquear_puntuacion_aprobada ON public.puntuaciones;

CREATE TRIGGER trg_proteger_puntuacion_aprobada
  BEFORE UPDATE OR DELETE ON public.puntuaciones
  FOR EACH ROW
  EXECUTE FUNCTION public.proteger_puntuacion_aprobada();
