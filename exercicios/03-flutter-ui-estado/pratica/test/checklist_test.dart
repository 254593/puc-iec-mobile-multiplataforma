// test/checklist_test.dart — ✅ AUTO-VERIFICAÇÃO · NÃO EDITE.
//
// Rode `flutter test`. Se TUDO aqui passar, você concluiu a Atividade 3.
// É o seu checklist de conclusão (ponta a ponta) — diferente do app_test.dart:
// app_test = a spec de cada exercício; aqui = "terminei tudo?".
// As TASKs de offline-first (11–15) têm a spec em test/offline_test.dart — `flutter test` roda tudo.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filmes_flutter/screens/home_screen.dart';

void main() {
  testWidgets('✔ Ex1 — a lista mostra os filmes com nota (⭐)', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: HomeScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Matrix'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsWidgets); // cada card tem a estrela da nota
  });

  testWidgets('✔ Ex2 — favoritar 2 filmes → ♥ 2 (estado compartilhado)', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: HomeScreen())));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.favorite_border).at(0));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.favorite_border).at(0)); // próximo ainda vazio
    await tester.pump();
    expect(find.text('♥ 2'), findsOneWidget);
  });

  testWidgets('✔ Ex2 — limpar zera (♥ 0)', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: HomeScreen())));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.favorite_border).at(0));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();
    expect(find.text('♥ 0'), findsOneWidget);
  });

  test('✔ Ex3 — você escreveu um teste em test/favorites_test.dart', () {
    // lê o arquivo do aluno ignorando linhas comentadas (o modelo vem comentado)
    final code = File('test/favorites_test.dart')
        .readAsLinesSync()
        .where((l) => !l.trimLeft().startsWith('//'))
        .join('\n');
    expect(code.contains('test('), isTrue,
        reason: 'Escreva um test() de verdade em test/favorites_test.dart (Ex3).');
    expect(code.contains('favoritesProvider'), isTrue,
        reason: 'Seu teste do Ex3 deve usar o favoritesProvider.');
  });
}
