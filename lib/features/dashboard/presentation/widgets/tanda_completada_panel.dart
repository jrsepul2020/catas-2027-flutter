import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/dashboard/presentation/widgets/muestra_hero_card.dart';

/// Pantalla de fin de tanda: felicitación para todos; botón solo presidente.
class TandaCompletadaPanel extends StatelessWidget {
  const TandaCompletadaPanel({
    super.key,
    required this.esPresidente,
    required this.haySiguienteTanda,
    required this.tandaNumero,
    required this.iniciando,
    this.onIniciarSiguiente,
  });

  final bool esPresidente;
  final bool haySiguienteTanda;
  final int? tandaNumero;
  final bool iniciando;
  final VoidCallback? onIniciarSiguiente;

  @override
  Widget build(BuildContext context) {
    final finJornada = !haySiguienteTanda;
    final titulo = finJornada
        ? '¡JORNADA DE MESA COMPLETADA!'
        : '¡TANDA COMPLETADA!';
    final subtitulo = finJornada
        ? 'Enhorabuena. No hay más tandas preparadas para hoy.'
        : 'Enhorabuena a toda la mesa por terminar la tanda'
            '${tandaNumero != null ? ' $tandaNumero' : ''}.';

    return ColoredBox(
      color: CataV2Theme.fondo,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  finJornada
                      ? Icons.emoji_events_rounded
                      : Icons.celebration_rounded,
                  size: 72,
                  color: CataV2Theme.cabecera,
                ),
                const SizedBox(height: 18),
                Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: CataV2Theme.text(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: CataV2Theme.texto,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitulo,
                  textAlign: TextAlign.center,
                  style: DashboardType.body(
                    color: CataV2Theme.textoSecundario,
                  ),
                ),
                if (!esPresidente) ...[
                  const SizedBox(height: 20),
                  Text(
                    finJornada
                        ? 'Pueden retirar las tablets cuando indiquen.'
                        : 'Esperando a que el presidente inicie la siguiente tanda…',
                    textAlign: TextAlign.center,
                    style: DashboardType.label(),
                  ),
                ],
                if (esPresidente && haySiguienteTanda) ...[
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: iniciando ? null : onIniciarSiguiente,
                      style: FilledButton.styleFrom(
                        backgroundColor: CataV2Theme.cabeceraPresidente,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: iniciando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'INICIAR TANDA SIGUIENTE',
                              style: CataV2Theme.text(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                  ),
                ],
                if (esPresidente && finJornada) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Fin de la jornada en esta mesa.\n'
                    'Si hace falta reabrir o ajustar, usar la app de gestión.',
                    textAlign: TextAlign.center,
                    style: DashboardType.label(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
