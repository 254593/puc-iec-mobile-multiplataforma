// test/offline_test.dart — SPEC das TASKs 11 a 15 (offline-first). NÃO edite este arquivo.
//
// Rode:  flutter test test/offline_test.dart
// Cada grupo é uma TASK. Verde = a TASK está certa. Começa tudo vermelho.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmes_flutter/data/key_value_store.dart';
import 'package:filmes_flutter/data/movie_repository.dart';
import 'package:filmes_flutter/data/remote_movie_source.dart';
import 'package:filmes_flutter/data/sync_queue.dart';
import 'package:filmes_flutter/models/movie.dart';
import 'package:filmes_flutter/state/network.dart';
import 'package:filmes_flutter/widgets/offline_banner.dart';

const matrix = Movie(id: 1, title: 'Matrix', rating: 8.7, year: '1999 · Ficção');
const inception = Movie(id: 2, title: 'Inception', rating: 8.8, year: '2010 · Ficção');

/// API falsa: conta chamadas e pode simular "sem rede".
class FakeRemote implements MovieSource {
  final List<Movie> data;
  bool online;
  int calls = 0;
  FakeRemote(this.data, {this.online = true});
  @override
  Future<List<Movie>> fetchMovies() async {
    calls++;
    if (!online) throw const OfflineException();
    return data;
  }
}

void main() {
  // ─────────────────────────── TASK 11 · banner offline ───────────────────────────
  group('TASK 11 — OfflineBanner', () {
    Future<void> pump(WidgetTester t, {required bool offline}) async {
      await t.pumpWidget(ProviderScope(
        overrides: [simulatedOfflineProvider.overrideWith(() => _FixedOffline(offline))],
        child: const MaterialApp(home: Scaffold(body: OfflineBanner())),
      ));
    }

    testWidgets('offline → mostra o aviso', (t) async {
      await pump(t, offline: true);
      expect(find.text('Você está offline — mostrando dados salvos'), findsOneWidget);
    });

    testWidgets('online → não mostra nada', (t) async {
      await pump(t, offline: false);
      expect(find.text('Você está offline — mostrando dados salvos'), findsNothing);
    });
  });

  // ─────────────────────────── TASK 12 · serialização ───────────────────────────
  group('TASK 12 — Movie.toJson / fromJson', () {
    test('toJson tem os 4 campos', () {
      expect(matrix.toJson(), {'id': 1, 'title': 'Matrix', 'rating': 8.7, 'year': '1999 · Ficção'});
    });

    test('fromJson(toJson(m)) devolve um filme igual', () {
      final m = Movie.fromJson(inception.toJson());
      expect(m.id, 2);
      expect(m.title, 'Inception');
      expect(m.rating, 8.8);
      expect(m.year, '2010 · Ficção');
    });

    test('fromJson aceita rating inteiro (JSON pode trazer 8 em vez de 8.0)', () {
      final m = Movie.fromJson({'id': 3, 'title': 'X', 'rating': 8, 'year': '2000 · Drama'});
      expect(m.rating, 8.0);
    });
  });

  // ─────────────────────────── TASK 13 · cache-first ───────────────────────────
  group('TASK 13 — MovieRepository.watchMovies (cache-first)', () {
    late InMemoryStore store;
    var t = DateTime(2026, 1, 1, 12);
    MovieRepository repo(FakeRemote r) =>
        MovieRepository(remote: r, store: store, ttl: Duration.zero, now: () => t); // ttl 0 = sempre velho

    setUp(() => store = InMemoryStore());

    test('sem cache + online → emite os frescos e GRAVA o cache', () async {
      final r = FakeRemote([matrix]);
      final out = await repo(r).watchMovies().toList();
      expect(out.length, 1);
      expect(out.first.first.title, 'Matrix');
      final cached = await repo(r).readCache();
      expect(cached, isNotNull, reason: 'o dado fresco precisa ser gravado com writeCache');
    });

    test('com cache + online → emite o CACHE primeiro, depois o fresco', () async {
      await repo(FakeRemote([])).writeCache([matrix]);
      final r = FakeRemote([matrix, inception]);
      final out = await repo(r).watchMovies().toList();
      expect(out.length, 2, reason: 'esperado: [cache, fresco]');
      expect(out[0].length, 1); // cache (só o Matrix)
      expect(out[1].length, 2); // fresco (Matrix + Inception)
    });

    test('com cache + OFFLINE → emite só o cache, sem erro', () async {
      await repo(FakeRemote([])).writeCache([matrix]);
      final r = FakeRemote([matrix, inception], online: false);
      final out = await repo(r).watchMovies().toList();
      expect(out.length, 1);
      expect(out.first.first.title, 'Matrix');
    });

    test('sem cache + OFFLINE → erro OfflineException (a tela mostra "sem dados")', () async {
      final r = FakeRemote([matrix], online: false);
      await expectLater(repo(r).watchMovies().toList(), throwsA(isA<OfflineException>()));
    });
  });

  // ─────────────────────────── TASK 14 · TTL ───────────────────────────
  group('TASK 14 — validade do cache (TTL)', () {
    late InMemoryStore store;
    late DateTime clock;
    MovieRepository repo(FakeRemote r) => MovieRepository(
        remote: r, store: store, ttl: const Duration(minutes: 10), now: () => clock);

    setUp(() {
      store = InMemoryStore();
      clock = DateTime(2026, 1, 1, 12);
    });

    test('cacheStatus: none → fresh → stale conforme o relógio', () async {
      final r = repo(FakeRemote([matrix]));
      expect(await r.cacheStatus(), CacheStatus.none);
      await r.writeCache([matrix]);
      expect(await r.cacheStatus(), CacheStatus.fresh);
      clock = clock.add(const Duration(minutes: 9));
      expect(await r.cacheStatus(), CacheStatus.fresh);
      clock = clock.add(const Duration(minutes: 2)); // 11 min > ttl
      expect(await r.cacheStatus(), CacheStatus.stale);
    });

    test('cache FRESCO + online → emite só o cache e NÃO chama a API', () async {
      final remote = FakeRemote([matrix, inception]);
      final r = repo(remote);
      await r.writeCache([matrix]);
      final out = await r.watchMovies().toList();
      expect(out.length, 1);
      expect(remote.calls, 0, reason: 'cache fresco: não precisa buscar de novo');
    });

    test('cache VELHO + online → emite cache, busca 1x e emite o fresco', () async {
      final remote = FakeRemote([matrix, inception]);
      final r = repo(remote);
      await r.writeCache([matrix]);
      clock = clock.add(const Duration(minutes: 30));
      final out = await r.watchMovies().toList();
      expect(out.length, 2);
      expect(remote.calls, 1);
    });
  });

  // ─────────────────────────── TASK 15 · fila de sincronização ───────────────────────────
  group('TASK 15 — SyncQueue (difícil: regras de conflito + flush)', () {
    late InMemoryStore store;
    late SyncQueue q;
    PendingOp op(String id, int movie, bool add) => PendingOp(id: id, movieId: movie, add: add);

    setUp(() {
      store = InMemoryStore();
      q = SyncQueue(store);
    });

    test('(pronto) enqueue persiste: uma NOVA fila sobre o mesmo store enxerga a operação', () async {
      await q.enqueue(op('a', 1, true));
      final again = await SyncQueue(store).pending();
      expect(again.map((o) => o.id), ['a']);
    });

    test('(pronto) enqueue é idempotente por id', () async {
      await q.enqueue(op('a', 1, true));
      await q.enqueue(op('a', 1, true));
      expect((await q.pending()).length, 1);
    });

    test('mesma ação no mesmo filme não duplica', () async {
      await q.enqueue(op('a', 1, true));
      await q.enqueue(op('b', 1, true));
      expect((await q.pending()).length, 1);
    });

    test('ação OPOSTA no mesmo filme: as duas se cancelam', () async {
      await q.enqueue(op('a', 1, true));
      await q.enqueue(op('b', 1, false));
      expect(await q.pending(), isEmpty, reason: 'add + remove do mesmo filme = nada a enviar');
    });

    test('cancelamento não atrapalha outros filmes (ordem preservada)', () async {
      await q.enqueue(op('a', 1, true));
      await q.enqueue(op('b', 2, true));
      await q.enqueue(op('c', 1, false)); // cancela a
      expect((await q.pending()).map((o) => o.id), ['b']);
    });

    test('flush envia NA ORDEM, esvazia a fila e devolve a contagem', () async {
      await q.enqueue(op('a', 1, true));
      await q.enqueue(op('b', 2, true));
      await q.enqueue(op('c', 3, false));
      final sent = <String>[];
      final n = await q.flush((o) async => sent.add(o.id));
      expect(sent, ['a', 'b', 'c']);
      expect(n, 3);
      expect(await q.pending(), isEmpty);
    });

    test('flush PARA no primeiro erro, preserva o resto e não propaga o erro', () async {
      await q.enqueue(op('a', 1, true));
      await q.enqueue(op('b', 2, true));
      await q.enqueue(op('c', 3, true));
      final n = await q.flush((o) async {
        if (o.id == 'b') throw const OfflineException();
      });
      expect(n, 1); // só o 'a' foi
      expect((await q.pending()).map((o) => o.id), ['b', 'c']); // resto, na mesma ordem
    });

    test('flush persiste a cada sucesso (se o app fechar no meio, não reenvia)', () async {
      await q.enqueue(op('a', 1, true));
      await q.enqueue(op('b', 2, true));
      await q.flush((o) async {
        if (o.id == 'b') throw const OfflineException();
      });
      final after = await SyncQueue(store).pending(); // "reabriu o app"
      expect(after.map((o) => o.id), ['b']);
    });
  });
}

class _FixedOffline extends SimulatedOffline {
  final bool offline;
  _FixedOffline(this.offline);
  @override
  bool build() => offline;
}
