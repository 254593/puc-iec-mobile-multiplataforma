// lib/screens/home_screen.dart
//
// A lista já está pronta (usa o MovieCard).
// Ex2 (TASK 5): contador de favoritos no header.
// Ex2 (TASK 6): botão "limpar" favoritos.
// Ex5 (TASK 8): banner com Remote Config.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/favorites.dart';
// ⏸ [TASK 8 — ADIADA, pule]: descomente quando o remote_config.dart estiver pronto
// import '../services/remote_config.dart';
import '../widgets/movie_list.dart';
import '../widgets/offline_banner.dart';
import '../widgets/offline_toggle.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(favoritesProvider).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filmes'),
        actions: [
          const OfflineToggle(), // modo avião simulado (pronto)
          // ── Ex2 · TASK 6 — botão "limpar" favoritos ──
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Limpar favoritos',
            onPressed: () => ref.read(favoritesProvider.notifier).clear(),
          ),
          // ── Ex2 · TASK 5 — contador de favoritos (mesma fonte que o card) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: Text('♥ $count')),
          ),
        ],
      ),
      body: Column(
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          const OfflineBanner(), // TASK 11 — aviso de offline
          // ── Ex5 · TASK 8 — banner Remote Config · 🧑‍💻 EM CASA (sozinho) ────────────────
          // Vire esta parte um FutureBuilder<String> (ou StatefulWidget com initState)
          // que chama fetchBannerMessage() de '../services/remote_config.dart' e
          // renderiza o texto retornado num Container no topo da lista.
          const Expanded(child: MovieList()), // lista vinda do repositório (cache-first)
        ],
      ),
    );
  }
}
