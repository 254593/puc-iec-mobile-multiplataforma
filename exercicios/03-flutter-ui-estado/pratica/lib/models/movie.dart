// lib/models/movie.dart — modelo de domínio.
//
// TASK 12 (🧑‍💻 EM CASA · fácil): implemente toJson() e Movie.fromJson().
// O cache offline guarda cada filme como JSON — sem isso nada é salvo.

class Movie {
  final int id;
  final String title;
  final double rating;
  final String year;

  const Movie({
    required this.id,
    required this.title,
    required this.rating,
    required this.year,
  });

  // ── TASK 12 — serialização · fácil ───────────────────────────────────────────────
  // toJson: devolva {'id': ..., 'title': ..., 'rating': ..., 'year': ...}
  // fromJson: faça o caminho de volta. Dica: `(json['rating'] as num).toDouble()`
  // (o JSON pode trazer 8 em vez de 8.0).
  Map<String, dynamic> toJson() => throw UnimplementedError('TASK 12: implemente toJson()');

  factory Movie.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError('TASK 12: implemente Movie.fromJson()');
}
