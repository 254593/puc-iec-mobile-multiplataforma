// Ex3 · TASK 9 — teste unitário do `favoritesProvider` ISOLADO (sem UI) com ProviderContainer.
//
// ProviderContainer = um "mini-app" do Riverpod: cada teste ganha o seu, então o estado
// não vaza de um teste para outro (addTearDown descarta o container no fim).

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filmes_flutter/state/favorites.dart';

void main() {
  late ProviderContainer c;

  setUp(() {
    c = ProviderContainer();
    addTearDown(c.dispose);
  });

  test('favoritos: começa vazio', () {
    expect(c.read(favoritesProvider), isEmpty);
  });

  test('favoritos: toggle e clear', () {
    final notifier = c.read(favoritesProvider.notifier);

    notifier.toggle(1);
    expect(c.read(favoritesProvider), {1});

    notifier.toggle(1); // de novo → remove
    expect(c.read(favoritesProvider).contains(1), isFalse);
    expect(c.read(favoritesProvider), isEmpty);

    notifier
      ..toggle(1)
      ..toggle(2);
    expect(c.read(favoritesProvider), {1, 2});

    notifier.clear();
    expect(c.read(favoritesProvider), isEmpty);
  });

  test('favoritos: toggle cria um NOVO Set (estado imutável)', () {
    final antes = c.read(favoritesProvider);
    c.read(favoritesProvider.notifier).toggle(1);
    expect(identical(antes, c.read(favoritesProvider)), isFalse);
    expect(antes, isEmpty); // o Set anterior não foi mutado
  });

  test('favoritos: quem escuta é notificado a cada mudança', () {
    final emitidos = <Set<int>>[];
    c.listen<Set<int>>(favoritesProvider, (_, next) => emitidos.add(next));

    c.read(favoritesProvider.notifier)
      ..toggle(1)
      ..toggle(2)
      ..clear();

    expect(emitidos, [
      {1},
      {1, 2},
      <int>{},
    ]);
  });
}
