-- Amplía supabase_realtime a las tablas que escuchan catas + gestión.
-- Idempotente: solo añade si falta.

DO $$
DECLARE
  t text;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    CREATE PUBLICATION supabase_realtime;
  END IF;

  FOREACH t IN ARRAY ARRAY[
    'concursos',
    'categorias',
    'dias_concurso',
    'mesas',
    'catadores',
    'muestras',
    'tandas',
    'tanda_muestras',
    'puntuaciones',
    'medallas',
    'dispositivos',
    'registro_cambios',
    'sync_estado'
  ]
  LOOP
    IF EXISTS (
      SELECT 1 FROM information_schema.tables
      WHERE table_schema = 'public' AND table_name = t
    ) AND NOT EXISTS (
      SELECT 1 FROM pg_publication_tables
      WHERE pubname = 'supabase_realtime'
        AND schemaname = 'public'
        AND tablename = t
    ) THEN
      EXECUTE format('ALTER PUBLICATION supabase_realtime ADD TABLE public.%I', t);
    END IF;
  END LOOP;
END $$;
