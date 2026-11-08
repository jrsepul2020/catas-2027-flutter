-- codigo_ciego: TEXT → INTEGER (1–9999), único en toda la BD.
-- Manual (no premia): 1–999. Web: 1000–9999. codigo_texto = solo etiqueta.
-- Idempotente. Si falla por trigger, se suelta, se convierte y se recrea.

-- 1) Quitar triggers que dependen de codigo_ciego (bloquean ALTER TYPE).
DROP TRIGGER IF EXISTS muestras_normalizar_codigo ON public.muestras;

DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT t.tgname
    FROM pg_trigger t
    JOIN pg_class c ON c.oid = t.tgrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND c.relname = 'muestras'
      AND NOT t.tgisinternal
      AND pg_get_triggerdef(t.oid) ILIKE '%codigo_ciego%'
  LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS %I ON public.muestras', r.tgname);
  END LOOP;
EXCEPTION
  WHEN others THEN
    NULL;
END $$;

-- 2) Convertir columna si sigue siendo texto.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'muestras'
      AND column_name = 'codigo_ciego'
      AND data_type IN ('text', 'character varying', 'character')
  ) THEN
    ALTER TABLE public.muestras
      ALTER COLUMN codigo_ciego TYPE integer
      USING NULLIF(trim(codigo_ciego::text), '')::integer;
  END IF;
END $$;

-- 3) CHECK 1–9999
ALTER TABLE public.muestras
  DROP CONSTRAINT IF EXISTS muestras_codigo_ciego_check;

ALTER TABLE public.muestras
  ADD CONSTRAINT muestras_codigo_ciego_check
  CHECK (codigo_ciego >= 1 AND codigo_ciego <= 9999);

-- 4) Único global
ALTER TABLE public.muestras
  DROP CONSTRAINT IF EXISTS muestras_codigo_ciego_key;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'muestras_codigo_ciego_key'
      AND conrelid = 'public.muestras'::regclass
  ) THEN
    ALTER TABLE public.muestras
      ADD CONSTRAINT muestras_codigo_ciego_key UNIQUE (codigo_ciego);
  END IF;
EXCEPTION
  WHEN duplicate_table THEN NULL;
  WHEN duplicate_object THEN NULL;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS muestras_codigo_ciego_uidx
  ON public.muestras (codigo_ciego);

-- 5) Recrear normalización de codigo_texto (compatible con integer).
--    Si codigo_texto viene vacío/NULL → lpad(codigo_ciego, 4, '0').
--    No pisa etiquetas DEMO-… ni otras ya informadas.
CREATE OR REPLACE FUNCTION public.muestras_normalizar_codigo()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.codigo_ciego IS NULL THEN
    RAISE EXCEPTION 'codigo_ciego es obligatorio';
  END IF;

  IF NEW.codigo_texto IS NULL OR btrim(NEW.codigo_texto) = '' THEN
    NEW.codigo_texto := lpad(NEW.codigo_ciego::text, 4, '0');
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS muestras_normalizar_codigo ON public.muestras;
CREATE TRIGGER muestras_normalizar_codigo
  BEFORE INSERT OR UPDATE OF codigo_ciego, codigo_texto
  ON public.muestras
  FOR EACH ROW
  EXECUTE FUNCTION public.muestras_normalizar_codigo();

COMMENT ON COLUMN public.muestras.codigo_ciego IS
  'Entero 1–9999 único global. <1000 = manual (no premia); >=1000 = inscripción web.';

COMMENT ON COLUMN public.muestras.codigo_texto IS
  'Etiqueta de pantalla (p. ej. DEMO-001 o lpad del ciego). No usar para lógica.';

COMMENT ON FUNCTION public.muestras_normalizar_codigo() IS
  'Rellena codigo_texto con lpad(codigo_ciego,4,''0'') si viene vacío. codigo_ciego es integer.';
