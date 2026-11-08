-- Recata: permitir editar puntuaciones 'aprobada' cuando la muestra
-- ya no está completada (admin la devolvió a pendiente / se reabrió).
--
-- Ejecutar también a mano en el SQL Editor de Supabase (cloud y Geekom local)
-- si el trigger antiguo sigue bloqueando con:
--   "Esta muestra ya fue aprobada y no admite cambios."

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

  -- Solo bloquear si la muestra sigue cerrada.
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
DROP TRIGGER IF EXISTS proteger_puntuacion_aprobada ON public.puntuaciones;
DROP TRIGGER IF EXISTS trg_puntuaciones_aprobada ON public.puntuaciones;
DROP TRIGGER IF EXISTS puntuaciones_proteger_aprobada ON public.puntuaciones;

-- Elimina otros triggers de usuario en puntuaciones que mencionen "aprobada".
DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT t.oid AS toid, t.tgname
    FROM pg_trigger t
    JOIN pg_class c ON c.oid = t.tgrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND c.relname = 'puntuaciones'
      AND NOT t.tgisinternal
  LOOP
    IF pg_get_triggerdef(r.toid) ILIKE '%aprobada%' THEN
      EXECUTE format('DROP TRIGGER IF EXISTS %I ON public.puntuaciones', r.tgname);
    END IF;
  END LOOP;
EXCEPTION
  WHEN others THEN
    NULL;
END $$;

CREATE TRIGGER trg_proteger_puntuacion_aprobada
  BEFORE UPDATE OR DELETE ON public.puntuaciones
  FOR EACH ROW
  EXECUTE FUNCTION public.proteger_puntuacion_aprobada();
