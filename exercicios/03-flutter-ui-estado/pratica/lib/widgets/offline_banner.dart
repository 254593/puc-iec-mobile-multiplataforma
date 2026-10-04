// lib/widgets/offline_banner.dart
//
// TASK 11 (🧑‍💻 EM CASA · fácil): mostre um aviso quando NÃO há conexão.
//
//   1. vire `ConsumerWidget` (build(context, ref)) e importe o flutter_riverpod;
//   2. leia `final online = ref.watch(onlineProvider);` (de '../state/network.dart');
//   3. se online → devolva `const SizedBox.shrink()` (nada na tela);
//      se offline → um Container no topo com o texto EXATO:
//        'Você está offline — mostrando dados salvos'
//
// O teste está em test/offline_test.dart (NÃO edite).
import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // 👈 implemente (TASK 11)
  }
}
