// lib/data/posters.dart — pôsteres dos filmes da lista (sem token: a imagem é pública).
// O foco da atividade é UI + estado, não busca de dados. Não precisa mexer.

const _base = 'https://image.tmdb.org/t/p/w342';

const _posterPaths = <int, String>{
  1: '/lDqMDI3xpbB9UQRyeXfei0MXhqb.jpg', // Matrix
  2: '/9e3Dz7aCANy5aRUQF745IlNloJ1.jpg', // Inception
  3: '/tR1XVa5bxgdh2bRw2u0DzrgkO2l.jpg', // Interstellar
  4: '/tlvsNCwWEIgwAM23aNzTmMIcPEZ.jpg', // O Senhor dos Anéis
  5: '/gfnXixcGC060QcG6JPxN6AMdVsq.jpg', // Cidade de Deus
};

/// URL do pôster do filme `movieId`, ou null se não houver.
String? posterUrlFor(int movieId) {
  final path = _posterPaths[movieId];
  return path == null ? null : '$_base$path';
}
