-- Virtus 2027 — tablets (tabla ya existente)
-- Columnas: id, numero, descripcion, activa, created_at, updated_at
--
-- El nombre del catador se guarda en DESCRIPCION (no hace falta crear columnas).

-- Crear filas 1 a 25 si no existen
insert into public.tablets (numero, descripcion, activa)
select gs, '', true
from generate_series(1, 25) as gs
where not exists (
  select 1 from public.tablets t where t.numero = gs
);

-- Lectura pública sin login
alter table public.tablets enable row level security;

drop policy if exists "Lectura pública de tablets" on public.tablets;
create policy "Lectura pública de tablets"
  on public.tablets for select
  to anon, authenticated
  using (true);

-- Asignar catadores (usa descripcion y numero)
-- update public.tablets set descripcion = 'María García' where numero = 1;
-- update public.tablets set descripcion = 'Juan Pérez' where numero = 2;
