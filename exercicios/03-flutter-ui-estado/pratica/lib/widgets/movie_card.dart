// lib/widgets/movie_card.dart
//
// Ex1 (TASK 1): componha o card.
// Ex2 (TASK 4): ligue o coração ao estado de favoritos.

import 'package:flutter/material.dart';
// TASK 4 — descomente para ler o estado (e troque StatelessWidget por ConsumerWidget):
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../state/favorites.dart';
import '../models/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    // ── Ex1 · TASK 1 — componha o MovieCard · 🧑‍🏫 EM AULA (juntos) ─────────────────────────────
    // Hoje só aparece o título. Deixe assim:
    //   Card → Padding(16) → Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //       Text(movie.title, fontSize 20, bold),
    //       Row([ Icon(Icons.star, color: Colors.amber, size: 18), Text(' ${movie.rating}') ]),
    //       Text(movie.year, color: Colors.grey),
    //     ])
    //
    // ── Ex2 · TASK 4 — coração de favorito · 🧑‍💻 EM CASA (sozinho) ──────────────────────────────
    // Vire `ConsumerWidget` (build(context, ref)) e:
    //   final isFav = ref.watch(favoritesProvider).contains(movie.id);
    //   ...adicione um IconButton (Icons.favorite / Icons.favorite_border) que chama
    //   ref.read(favoritesProvider.notifier).toggle(movie.id)
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(movie.title),
      ),
    );
  }
}
