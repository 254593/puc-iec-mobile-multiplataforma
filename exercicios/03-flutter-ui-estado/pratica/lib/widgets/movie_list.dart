// lib/widgets/movie_list.dart — PRONTO (não precisa mexer).
// A lista da tela: carregando, erro (sem dados e sem rede) ou os cards.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/movies_provider.dart';
import 'movie_card.dart';

class MovieList extends ConsumerWidget {
  const MovieList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movies = ref.watch(moviesProvider);
    return movies.when(
      skipLoadingOnReload: true, // mantém a lista na tela enquanto atualiza
      data: (list) => ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, i) => MovieCard(movie: list[i]),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48),
            const SizedBox(height: 12),
            const Text('Sem dados salvos e sem conexão'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => ref.invalidate(moviesProvider),
              child: const Text('Tentar de novo'),
            ),
          ],
        ),
      ),
    );
  }
}
