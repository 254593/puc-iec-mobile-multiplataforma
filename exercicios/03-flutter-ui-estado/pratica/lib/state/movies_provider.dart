// lib/state/movies_provider.dart — PRONTO (não precisa mexer).
//
// Liga as peças: armário (store) → API simulada → repositório → lista da tela.
// A UI só enxerga `moviesProvider`. Quando o modo avião muda, a lista é recarregada.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/key_value_store.dart';
import '../data/movie_repository.dart';
import '../data/remote_movie_source.dart';
import '../models/movie.dart';
import 'network.dart';

/// No app real o main.dart troca por SharedPrefsStore (sobrevive ao F5). Nos testes: em memória.
final storeProvider = Provider<KeyValueStore>((ref) => InMemoryStore());

final movieSourceProvider = Provider<MovieSource>(
  (ref) => SimulatedRemote(isOnline: () => ref.read(onlineProvider)),
);

final movieRepositoryProvider = Provider<MovieRepository>(
  (ref) => MovieRepository(
    remote: ref.watch(movieSourceProvider),
    store: ref.watch(storeProvider),
  ),
);

final moviesProvider = StreamProvider<List<Movie>>((ref) {
  ref.watch(onlineProvider); // voltou a rede (ou caiu)? recarrega
  return ref.watch(movieRepositoryProvider).watchMovies();
});
