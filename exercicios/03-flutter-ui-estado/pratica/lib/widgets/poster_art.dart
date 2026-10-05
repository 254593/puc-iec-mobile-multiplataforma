// lib/widgets/poster_art.dart — pôster do filme (PRONTO, não precisa mexer).
// Mostra o pôster real; se estiver offline ou a imagem falhar, aparece um gradiente.
// Use no MovieCard (TASK 1):  PosterArt(movie: movie)

import 'package:flutter/material.dart';
import '../data/posters.dart';
import '../models/movie.dart';

const _palettes = <List<Color>>[
  [Color(0xFF6C5CE7), Color(0xFFA855F7)],
  [Color(0xFF0EA5E9), Color(0xFF6366F1)],
  [Color(0xFFF43F5E), Color(0xFFF59E0B)],
  [Color(0xFF10B981), Color(0xFF0EA5E9)],
  [Color(0xFFEC4899), Color(0xFF8B5CF6)],
];

class PosterArt extends StatelessWidget {
  final Movie movie;
  final double width;
  final double height;
  const PosterArt({super.key, required this.movie, this.width = 64, this.height = 88});

  @override
  Widget build(BuildContext context) {
    final colors = _palettes[movie.id % _palettes.length];
    // dados reais trazem o caminho do pôster; a lista simulada usa o mapa de posters.dart
    final url = movie.posterPath != null
        ? 'https://image.tmdb.org/t/p/w342${movie.posterPath}'
        : posterUrlFor(movie.id);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Center(child: Icon(Icons.movie_rounded, size: 30, color: Colors.white)),
            if (url != null)
              Image.network(
                url,
                fit: BoxFit.cover,
                // sem rede / falha: some a imagem e o gradiente de fundo aparece
                errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                frameBuilder: (context, child, frame, sync) => AnimatedOpacity(
                  opacity: frame == null && !sync ? 0 : 1,
                  duration: const Duration(milliseconds: 450),
                  child: child,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
