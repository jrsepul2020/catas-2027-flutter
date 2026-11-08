-- Migración 0001: esquema de catas (copia exacta del de Cloud, 29-oct-2026)
-- Se puede ejecutar varias veces sin romper nada.
-- No incluye: medallas, asignaciones, dias_concurso, despertador_tabla, keepalive.

-- ── Tablas (en orden de dependencias) ─────────────────────────────

CREATE TABLE IF NOT EXISTS concursos (
  id                 serial PRIMARY KEY,
  nombre             text NOT NULL,
  fecha_inicio       date,
  fecha_fin          date,
  gran_oro           numeric DEFAULT 92,
  oro                numeric DEFAULT 85,
  plata              numeric DEFAULT 82,
  catadores_por_mesa integer DEFAULT 5,
  activo             boolean DEFAULT true,
  logo_url           text,
  color_primario     text DEFAULT '#8B0000',
  color_secundario   text DEFAULT '#F5C518',
  imagen_gran_oro    text,
  imagen_oro         text,
  imagen_plata       text,
  patrocinadores     jsonb
);

CREATE TABLE IF NOT EXISTS categorias (
  id     serial PRIMARY KEY,
  codigo text NOT NULL,
  nombre text NOT NULL,
  ficha  jsonb NOT NULL,
  CONSTRAINT categorias_codigo_key UNIQUE (codigo)
);

CREATE TABLE IF NOT EXISTS mesas (
  id          serial PRIMARY KEY,
  concurso_id integer,
  numero      integer NOT NULL,
  nombre      text,
  CONSTRAINT mesas_concurso_id_fkey FOREIGN KEY (concurso_id) REFERENCES concursos(id)
);

CREATE TABLE IF NOT EXISTS catadores (
  id          serial PRIMARY KEY,
  nombre      text NOT NULL,
  rol         text NOT NULL DEFAULT 'catador',
  mesa_id     integer,
  activo      boolean DEFAULT false,
  pais_codigo text,
  titulo      text,
  mesa        integer,
  pais        text,
  puesto      smallint,
  CONSTRAINT catadores_mesa_id_fkey FOREIGN KEY (mesa_id) REFERENCES mesas(id)
);

CREATE TABLE IF NOT EXISTS dispositivos (
  id         serial PRIMARY KEY,
  device_id  text NOT NULL,
  catador_id integer,
  ultima_vez timestamptz DEFAULT now(),
  CONSTRAINT dispositivos_device_id_key UNIQUE (device_id),
  CONSTRAINT dispositivos_catador_id_fkey FOREIGN KEY (catador_id) REFERENCES catadores(id)
);

CREATE TABLE IF NOT EXISTS muestras (
  id           serial PRIMARY KEY,
  concurso_id  integer,
  categoria_id integer,
  -- Entero 1–9999, único global. 1–999 = manual (no premia); 1000–9999 = web.
  codigo_ciego integer NOT NULL,
  codigo_texto text,
  activo       boolean DEFAULT true,
  CONSTRAINT muestras_concurso_id_fkey FOREIGN KEY (concurso_id) REFERENCES concursos(id),
  CONSTRAINT muestras_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES categorias(id),
  CONSTRAINT muestras_codigo_ciego_check CHECK (codigo_ciego >= 1 AND codigo_ciego <= 9999),
  CONSTRAINT muestras_codigo_ciego_key UNIQUE (codigo_ciego)
);

CREATE TABLE IF NOT EXISTS tandas (
  id           serial PRIMARY KEY,
  mesa_id      integer,
  numero       integer NOT NULL,
  estado       text DEFAULT 'pendiente',
  categoria_id integer,
  CONSTRAINT tandas_mesa_id_fkey FOREIGN KEY (mesa_id) REFERENCES mesas(id),
  CONSTRAINT tandas_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

-- Sin claves foráneas a propósito (velocidad); la integridad la dan los candados únicos
CREATE TABLE IF NOT EXISTS tanda_muestras (
  id                serial PRIMARY KEY,
  tanda_id          integer NOT NULL,
  muestra_id        integer NOT NULL,
  orden             integer NOT NULL,
  estado            text DEFAULT 'pendiente',
  incidencia_motivo text,
  CONSTRAINT tanda_muestra_unique UNIQUE (tanda_id, muestra_id)
);

CREATE TABLE IF NOT EXISTS puntuaciones (
  id         serial PRIMARY KEY,
  catador_id integer NOT NULL,
  muestra_id integer NOT NULL,
  tanda_id   integer NOT NULL,
  scores     jsonb NOT NULL,
  total      numeric NOT NULL,
  estado     text DEFAULT 'borrador',
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT puntuacion_unica UNIQUE (catador_id, muestra_id)
);

-- ── Índices ────────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_dispositivos_device ON dispositivos(device_id);
CREATE INDEX IF NOT EXISTS idx_muestras_concurso   ON muestras(concurso_id);
CREATE INDEX IF NOT EXISTS idx_tandas_mesa         ON tandas(mesa_id);
CREATE INDEX IF NOT EXISTS idx_tm_tanda            ON tanda_muestras(tanda_id);
CREATE INDEX IF NOT EXISTS idx_tm_estado           ON tanda_muestras(tanda_id, estado);
CREATE INDEX IF NOT EXISTS idx_pun_muestra         ON puntuaciones(muestra_id);
CREATE INDEX IF NOT EXISTS idx_pun_catador         ON puntuaciones(catador_id);
CREATE INDEX IF NOT EXISTS idx_pun_tanda           ON puntuaciones(tanda_id);

-- ── Seguridad por filas (RLS) y políticas, como en Cloud ───────────

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['concursos','categorias','mesas','catadores','dispositivos',
                           'muestras','tandas','tanda_muestras','puntuaciones']
  LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('DROP POLICY IF EXISTS lectura_publica ON %I', t);
    EXECUTE format('CREATE POLICY lectura_publica ON %I FOR SELECT USING (true)', t);
  END LOOP;

  FOREACH t IN ARRAY ARRAY['catadores','dispositivos','tanda_muestras','puntuaciones']
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON %I', 'escritura_' || t, t);
    EXECUTE format('CREATE POLICY %I ON %I FOR ALL USING (true) WITH CHECK (true)',
                   'escritura_' || t, t);
  END LOOP;
END $$;

-- ── Permisos de acceso para la API ─────────────────────────────────
-- (las políticas de arriba son las que realmente limitan quién escribe)

GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON
  concursos, categorias, mesas, catadores, dispositivos,
  muestras, tandas, tanda_muestras, puntuaciones
TO anon, authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- ── Realtime: tablas que la app escucha ────────────────────────────

DO $$
DECLARE t text;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    CREATE PUBLICATION supabase_realtime;
  END IF;
  FOREACH t IN ARRAY ARRAY['tanda_muestras','puntuaciones','tandas']
  LOOP
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables
                   WHERE pubname = 'supabase_realtime'
                     AND schemaname = 'public' AND tablename = t) THEN
      EXECUTE format('ALTER PUBLICATION supabase_realtime ADD TABLE public.%I', t);
    END IF;
  END LOOP;
END $$;
