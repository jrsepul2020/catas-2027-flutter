# Virtus 2027

Aplicación Flutter para cata de vinos en tablet, con [Supabase](https://supabase.com) como backend (PostgreSQL + Realtime). Sin login de usuario: cada tablet elige su dispositivo en la pantalla inicial.

**Última actualización:** junio 2026

---

## Estado actual

La aplicación es **funcional para concurso en mesa**: presidente y catadores pueden catar, puntuar, revisar y aprobar muestras con sincronización en tiempo real entre las 25 tablets.

### Lo que funciona

| Área | Estado |
|------|--------|
| **Login / selección de tablet** | Cuadrícula por mesas. Muestra nombre, puesto, bandera y número de tablet (arriba a la derecha). Presidente con tarjeta oscura y etiqueta «PRESIDENTE». |
| **Dashboard** | Tanda, mesa, muestras por estado, hero con acciones según rol. Recarga en tiempo real (debounce 400 ms). |
| **Apertura de cata** | Solo el presidente abre la muestra (`ABRIR CATA`). Catadores entran cuando está activa. |
| **Formulario de cata** | Ficha de vinos tranquilos, criterios por grupos, envío de puntuación. |
| **Aprobación (presidente)** | Modal con tabla de catadores, media, desvíos, puntuaciones en vivo. Banner naranja si faltan catadores. Botón **APROBAR CATA ADMIN** (temporal) para aprobar con puntuaciones parciales. |
| **Espera (catador)** | Modal tras enviar puntuación con opción de revisar. |
| **Aprobación final** | La muestra pasa a completada solo cuando el presidente aprueba. Al aprobar, los catadores vuelven al dashboard automáticamente (estén puntuando o esperando). |
| **Realtime Supabase** | Tablas publicadas: `tanda_muestras`, `puntuaciones`, `tandas`. |

### Roles

- **Presidente:** abre cata, puntúa, revisa, aprueba la mesa y continúa.
- **Catador:** entra a cata activa, puntúa, espera aprobación; si el presidente aprueba, sale al dashboard sin intervención manual.

### Pendiente / mejoras futuras

- Repaso visual general de la UI.
- Panel de administración (gestión de tandas, mesas, catadores) — previsto en VITTE.
- `supabase/schema.sql` está **obsoleto** (schema legacy `tablets`); la app usa `dispositivos`, `catadores`, `mesas`, `tandas`, etc.

---

## Requisitos

- Flutter SDK 3.27+
- Cuenta en [Supabase](https://supabase.com)
- Tablet **1003×627** px, orientación horizontal

## Resolución tablet (1003×627)

Canvas fijo en `lib/core/layout/tablet_layout.dart`:

- `TabletViewport`: escala en Chrome u otras pantallas.
- `TabletScaffold`, `TabletTheme`, `VirtusColors`, `VirtusTextStyles`.
- Pantallas nuevas: usar `TabletLayout` y envolver en `TabletViewport`.

## Configuración

### 1. Variables de entorno

```bash
cp .env.example .env
```

```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
```

### 2. Supabase Realtime

En el SQL Editor, añadir a la publicación `supabase_realtime`:

- `tanda_muestras`
- `puntuaciones`
- `tandas`

### 3. Datos clave (tablas actuales)

| Tabla | Uso en la app |
|-------|----------------|
| `dispositivos` | Tablets (`device_id` tipo `tablet-001` → se parsea a número 1) |
| `catadores` | Nombre, rol, `puesto`, `pais_codigo`, mesa |
| `mesas` | Agrupación en login |
| `tandas` / `tanda_muestras` | Dashboard y flujo de cata |
| `puntuaciones` | Scores y estados (`enviada`, `aprobada`) |

> **Nota:** el puesto del catador está en la columna `puesto`, no `codigo_catador`.

### 4. Ejecutar

```bash
flutter pub get
flutter run
```

Hot restart en desarrollo: **`R`** en la terminal de `flutter run`.

---

## Estructura del proyecto

```
lib/
├── app/                    # VirtusApp, tema
├── config/                 # Supabase
├── core/
│   ├── layout/             # TabletLayout, TabletViewport
│   ├── models/             # Catador, Tanda, Muestra…
│   ├── services/           # SupabaseService
│   └── theme/              # VirtusColors, VirtusTextStyles
├── features/
│   ├── home/               # Login: selección de dispositivo
│   ├── dashboard/          # Panel tanda / muestras
│   └── cata/               # Formulario, aprobación, realtime
└── main.dart
```

## Flujo principal

```
Home (elegir tablet)
  → Dashboard (muestras de la tanda)
    → Presidente: ABRIR CATA
    → Catador: ENTRAR A CATAR (muestra activa)
      → CataPage (puntuar)
        → Enviar → Modal espera (catador) / Modal aprobación (presidente)
        → Presidente aprueba → Catadores → Dashboard
```

## Archivos relevantes del flujo cata

| Archivo | Función |
|---------|---------|
| `cata_page.dart` | Pantalla de puntuación y modales |
| `cata_repository.dart` | Guardar, abrir, resumen mesa, aprobar |
| `cata_aprobacion_modal.dart` | Modal presidente con recarga en vivo |
| `cata_aprobacion_realtime_sync.dart` | Realtime puntuaciones (debounce 500 ms) |
| `cata_page_realtime_sync.dart` | Expulsa catador al dashboard tras aprobación |
| `dashboard_realtime_sync.dart` | Realtime del dashboard |

## Build APK release

```bash
flutter build apk --release
```

Salida: `build/app/outputs/flutter-apk/app-release.apk`

## Recursos

- [Supabase Flutter](https://supabase.com/docs/reference/dart/introduction)
- [Flutter](https://docs.flutter.dev)
