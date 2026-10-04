// lib/data/remote_movie_source.dart — PRONTO (não precisa mexer).
//
// A "API" do app. É SIMULADA (sem rede, sem token, sem custo): devolve os filmes de
// `movies.dart` depois de uma pequena latência, e LANÇA OfflineException quando o
// modo avião simulado está ligado. Assim você testa o offline de forma determinística.
import '../models/movie.dart';
import 'movies.dart';

class OfflineException implements Exception {
  const OfflineException();
  @override
  String toString() => 'OfflineException: sem conexão';
}

abstract class MovieSource {
  Future<List<Movie>> fetchMovies();
}

class SimulatedRemote implements MovieSource {
  final bool Function() isOnline;
  final Duration latency;
  SimulatedRemote({required this.isOnline, this.latency = const Duration(milliseconds: 600)});

  @override
  Future<List<Movie>> fetchMovies() async {
    await Future<void>.delayed(latency);
    if (!isOnline()) throw const OfflineException();
    return movies;
  }
}
