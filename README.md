# Virtus 2027

Aplicación Flutter con [Supabase](https://supabase.com) como backend (base de datos PostgreSQL, autenticación y API en tiempo real).

## Requisitos

- Flutter SDK 3.27+
- Cuenta en [Supabase](https://supabase.com)
- Tablet en **1003×627** px (horizontal). Toda la UI se diseña para ese canvas.

## Resolución tablet (1003×627)

La interfaz usa un canvas fijo de **1003×627** píxeles lógicos (`lib/core/layout/tablet_layout.dart`):

- `TabletViewport`: escala el contenido en pantallas distintas (p. ej. Chrome en desarrollo).
- `TabletScaffold`, `TabletTheme` y tamaños de fuente/espaciado derivan de ese canvas.
- Orientación bloqueada en horizontal.

Al crear pantallas nuevas, usa siempre `TabletLayout` y envuelve la ruta en `TabletViewport`.

## Configuración

### 1. Proyecto Supabase

1. Crea un proyecto en [app.supabase.com](https://app.supabase.com).
2. Ve a **Project Settings → API** y copia:
   - **Project URL**
   - **anon public** key

### 2. Variables de entorno

```bash
cp .env.example .env
```

Edita `.env` con tus credenciales:

```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 3. Esquema de base de datos

En el **SQL Editor** de Supabase, ejecuta `supabase/schema.sql` (crea filas 1–25 y política de lectura).

El nombre del catador va en la columna **`descripcion`**:

```sql
update public.tablets set descripcion = 'María García' where numero = 1;
update public.tablets set descripcion = 'Juan Pérez' where numero = 2;
```

### 4. Ejecutar la app

```bash
flutter pub get
flutter run
```

## Estructura del proyecto

```
lib/
├── app/                 # Widget raíz y tema
├── config/              # Inicialización de Supabase
├── core/constants/      # Claves de entorno
├── features/            # Módulos por funcionalidad
│   └── home/
└── main.dart
```

## Pantalla inicial

Cuadrícula 5×5 con 25 recuadros. Cada uno muestra el número de tablet (`numero`) y el catador (`descripcion` en `public.tablets`). No requiere login.

**Pulsar un recuadro** abre el dashboard de esa tablet con la tanda asignada (`tandas` por `mesa_id` = número de tablet; prioridad: tanda activa → última actualizada).

## Próximos pasos

- Editar catadores desde un panel de administración
- Sincronización en tiempo real con Supabase Realtime

## Recursos

- [Documentación Supabase Flutter](https://supabase.com/docs/reference/dart/introduction)
- [Documentación Flutter](https://docs.flutter.dev)
