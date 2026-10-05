// lib/data/tmdb_source.dart — PRONTO (não precisa mexer).
//
// Fonte de dados REAL (TMDB). Só entra quando você passa a chave:
//   flutter run -d chrome --web-port 5300 --dart-define=TMDB_KEY=sua_chave
// (ou guarde a chave em .env.local — veja .env.local.example — e use F5 / rodar.sh).
// SEM chave, o app usa a lista simulada (movies.dart) — é o que o `flutter test` usa.
//
// Repare: a UI e o estado NÃO mudam. O repositório só depende da interface MovieSource,
// então trocar a fonte (simulada ↔ TMDB) não toca em nenhuma tela.
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import 'remote_movie_source.dart';

const kTmdbKey = String.fromEnvironment('TMDB_KEY');

const _genres = <int, String>{
  28: 'Ação', 12: 'Aventura', 16: 'Animação', 35: 'Comédia', 80: 'Crime', 99: 'Documentário',
  18: 'Drama', 10751: 'Família', 14: 'Fantasia', 36: 'História', 27: 'Terror', 10402: 'Música',
  9648: 'Mistério', 10749: 'Romance', 878: 'Ficção', 53: 'Suspense', 10752: 'Guerra', 37: 'Faroeste',
};

class TmdbSource implements MovieSource {
  final String key;
  final bool Function() isOnline;
  final http.Client _http;
  TmdbSource({required this.key, required this.isOnline, http.Client? client})
      : _http = client ?? http.Client();

  @override
  Future<List<Movie>> fetchMovies() async {
    // o botão ✈️ (modo avião simulado) continua valendo com dados reais
    if (!isOnline()) throw const OfflineException();
    try {
      final out = <Movie>[];
      for (final page in [1, 2]) {
        final uri = Uri.https('api.themoviedb.org', '/3/movie/popular',
            {'api_key': key, 'language': 'pt-BR', 'page': '$page'});
        final res = await _http.get(uri).timeout(const Duration(seconds: 15));
        if (res.statusCode == 401) {
          throw Exception('TMDB: chave inválida (401) — confira o TMDB_KEY');
        }
        if (res.statusCode != 200) throw Exception('TMDB respondeu ${res.statusCode}');
        final data = json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        for (final m in data['results'] as List) {
          out.add(_toMovie(m as Map<String, dynamic>));
        }
      }
      return out;
    } on TimeoutException {
      throw const OfflineException();
    } on http.ClientException {
      throw const OfflineException(); // sem rede de verdade
    }
  }

  Movie _toMovie(Map<String, dynamic> m) {
    final date = (m['release_date'] as String?) ?? '';
    final year = date.length >= 4 ? date.substring(0, 4) : '—';
    final ids = (m['genre_ids'] as List?)?.cast<int>() ?? const <int>[];
    final genre = ids.map((g) => _genres[g]).whereType<String>().firstOrNull ?? 'Filme';
    return Movie(
      id: m['id'] as int,
      title: m['title'] as String,
      // 1 casa decimal (o TMDB manda 7.269): assim o card mostra 7.3 sem formatar na UI
      rating: double.parse(((m['vote_average'] as num?) ?? 0).toStringAsFixed(1)),
      year: '$year · $genre',
      posterPath: m['poster_path'] as String?,
    );
  }
}
