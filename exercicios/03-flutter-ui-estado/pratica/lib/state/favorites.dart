// lib/state/favorites.dart
//
// Ex2 (TASK 2): estado compartilhado de favoritos com Riverpod (local).
// Ex4 (TASK 7): mesmo provider, mas sincronizado com Firestore (cloud).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // debugPrint
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Ex4 · TASK 7 — favoritos persistidos no Firestore ────────────────────────────────────────
// Mesma interface do TASK 2 (toggle/clear sobre um Set<int> imutável) — a UI não muda nada.
// O que muda é a FONTE DE VERDADE: o documento `favorites/meus-favoritos` ({'ids': [...]}).
//   - build(): começa vazio e dispara a leitura do documento (async);
//   - toggle/clear: atualiza o `state` NA HORA (otimista) e grava o documento em paralelo.
// Sem Firebase (ex.: `flutter test`) a leitura/gravação falha, cai no catch e o provider segue
// funcionando só em memória — o mesmo comportamento do TASK 2.
const _favDoc = 'favorites/meus-favoritos'; // 1 documento por aluno (seu projeto = seu Firestore)

class FavoritesNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() {
    _load(); // state começa vazio até o Firestore responder
    return {};
  }

  Future<void> _load() async {
    try {
      final doc = await FirebaseFirestore.instance.doc(_favDoc).get();
      final ids = (doc.data()?['ids'] as List<dynamic>?) ?? const [];
      state = ids.map((e) => (e as num).toInt()).toSet(); // num: na web o número pode vir como double
    } catch (e) {
      // offline sem cache, ou `flutter test` ("No Firebase App") — mantém vazio.
      // `permission-denied` no console = revise as REGRAS do Firestore.
      debugPrint('Firestore (ler): $e');
    }
  }

  Future<void> _persist(Set<int> next) async {
    try {
      await FirebaseFirestore.instance.doc(_favDoc).set({'ids': next.toList()});
    } catch (e) {
      // o estado local (otimista) já refletiu na UI; `permission-denied` = regras.
      debugPrint('Firestore (gravar): $e');
    }
  }

  void toggle(int id) {
    final next = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
    state = next; // UI reage na hora (otimista)
    _persist(next); // grava no Firestore em paralelo
  }

  void clear() {
    state = {}; // usado pelo botão "limpar" (TASK 6)
    _persist({});
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<int>>(FavoritesNotifier.new);
