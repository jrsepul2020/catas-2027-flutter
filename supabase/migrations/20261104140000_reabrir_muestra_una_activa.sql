-- reabrir_muestra: no permitir recata si ya hay otra muestra abierta
-- (activa / en_curso) en la misma tanda. Solo una abierta a la vez.

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
  v_tm           public.tanda_muestras%ROWTYPE;
  v_max_orden    integer;
  v_actor        text := CURRENT_USER;
  v_notas        integer := 0;
  v_otra_abierta integer;
  v_estado       text;
BEGIN
  SELECT * INTO v_tm
  FROM public.tanda_muestras
  WHERE id = p_tanda_muestra_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'reabrir_muestra: tanda_muestra_id % no existe', p_tanda_muestra_id;
  END IF;

  v_estado := lower(trim(coalesce(v_tm.estado, '')));

  IF v_estado NOT IN ('completada', 'finalizada') THEN
    RAISE EXCEPTION
      'reabrir_muestra: solo se pueden recatar muestras cerradas (completada/finalizada). Estado actual: %',
      coalesce(nullif(v_estado, ''), '(vacío)');
  END IF;

  -- Solo una muestra abierta a la vez en la tanda.
  SELECT tm.id INTO v_otra_abierta
  FROM public.tanda_muestras tm
  WHERE tm.tanda_id = v_tm.tanda_id
    AND tm.id <> v_tm.id
    AND lower(trim(coalesce(tm.estado, ''))) IN ('activa', 'en_curso')
  LIMIT 1;

  IF v_otra_abierta IS NOT NULL THEN
    RAISE EXCEPTION
      'reabrir_muestra: hay otra muestra abierta en la tanda (tanda_muestra_id %). Ciérrala o complétala antes de recatar.',
      v_otra_abierta;
  END IF;

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
  'Recata admin: solo si está cerrada y no hay otra activa/en_curso en la tanda. Solo service_role.';

REVOKE ALL ON FUNCTION public.reabrir_muestra(integer, boolean, boolean, text)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.reabrir_muestra(integer, boolean, boolean, text)
  TO postgres, service_role;
