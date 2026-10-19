// lib/widgets/offline_banner.dart
//
// TASK 11: mostra um aviso quando NÃO há conexão (rede real OU modo avião simulado).
// Online → nada na tela. O teste está em test/offline_test.dart (NÃO edite).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/network.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(onlineProvider);
    if (online) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: scheme.errorContainer,
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, size: 18, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Você está offline — mostrando dados salvos',
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
