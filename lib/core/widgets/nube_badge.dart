import 'package:flutter/material.dart';
import 'package:virtus2027/config/supabase_config.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';

/// Etiqueta naranja «NUBE» solo si el cliente apunta de verdad a Cloud.
class NubeBadge extends StatelessWidget {
  const NubeBadge({super.key});

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.pointsToCloud) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFE65100),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'NUBE',
          style: VirtusTextStyles.plain(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
