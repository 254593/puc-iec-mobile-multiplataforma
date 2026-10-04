// lib/state/network.dart — PRONTO (não precisa mexer).
//
// `onlineProvider` diz se há conexão: combina a rede REAL (navegador/aparelho) com o "modo avião" SIMULADO
// (o botão do app). No navegador, DevTools → Network → Offline também derruba a conexão de verdade.
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SimulatedOffline extends Notifier<bool> {
  @override
  bool build() => false; // false = online
  void set(bool offline) => state = offline;
  void toggle() => state = !state;
}

final simulatedOfflineProvider =
    NotifierProvider<SimulatedOffline, bool>(SimulatedOffline.new);

/// Conectividade real. Nos testes (sem plugin) cai no valor seguro "online".
final realConnectivityProvider = StreamProvider<bool>((ref) async* {
  final c = Connectivity();
  try {
    yield !(await c.checkConnectivity()).contains(ConnectivityResult.none);
  } catch (_) {
    yield true;
    return;
  }
  yield* c.onConnectivityChanged.map((r) => !r.contains(ConnectivityResult.none));
});

/// true = tem conexão (rede real E modo avião desligado).
final onlineProvider = Provider<bool>((ref) {
  final simulatedOffline = ref.watch(simulatedOfflineProvider);
  final real = ref.watch(realConnectivityProvider).valueOrNull ?? true;
  return !simulatedOffline && real;
});
