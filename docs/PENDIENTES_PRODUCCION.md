# Pendientes al pasar a producción (fin de pruebas)

Checklist de cosas a hacer cuando `esModoPruebas` pase a `false` y se use el concurso real.

## Seguridad y salida

- [ ] **No permitir la salida fácil** de la app en tablet (quitar botón SALIR / menú “Salir a tablets”; bloquear back/gesture hacia la cuadrícula de dispositivos).
- [ ] Decidir protocolo de salida de emergencia (PIN, gesto oculto, tablet de admin).
- [ ] Revisar políticas RLS de Supabase (ahora hay escritura abierta en tablas clave para pruebas).

## Modo pruebas / demo

- [ ] Poner `esModoPruebas = false` en `lib/config/app_mode.dart`.
- [ ] Confirmar que desaparecen etiqueta **MODO PRUEBAS**, botón **TRUCOS** y panel de trucos.
- [ ] Eliminar o archivar `lib/features/pruebas/` si ya no hace falta.
- [ ] Limpiar muestras `DEMO-*` y datos de ensayo en Cloud / local.
- [ ] Quitar o restringir RPC `demo_reiniciar_muestra` en producción.
- [ ] Confirmar que `reabrir_muestra` sigue REVOKE’d a `anon`/`authenticated` (solo admin / `service_role`).

## Flujo de cata

- [ ] Verificar que el catador solo ve espera + auto-apertura de ficha (sin botones de decisión).
- [ ] Verificar que solo el presidente usa **ABRIR CATA**.
- [ ] Revisar botón temporal **APROBAR CATA ADMIN** (si sigue existiendo): quitarlo o protegerlo.
- [ ] Confirmar flujo incidencia / DESCARTAR en concurso real.

## App / tablet

- [ ] Bloqueo de barra de estado / kiosk mode en Android (si aplica).
- [ ] APK firmado de release con versión y nombre de paquete definitivos.
- [ ] Comprobar contraste y tipografía en tablet física (no solo Chrome).
- [ ] Keepalive / reconexión Realtime en salas con Wi‑Fi inestable.

## Datos y operación

- [ ] Cargar concursos, mesas, catadores, tandas y muestras reales.
- [ ] Asignar dispositivos ↔ catadores antes del día de cata.
- [ ] Prueba completa de una mesa (5 catadores + presidente) de punta a punta.
- [ ] Plan de respaldo si falla Realtime (refresco manual / poll).

## Documentación

- [ ] Actualizar README con el flujo definitivo de concurso.
- [ ] Anotar umbrales de medallas y reglas de aprobación finales.
