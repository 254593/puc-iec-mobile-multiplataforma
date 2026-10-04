# Guia passo-a-passo — App Flutter: UI + Estado + Firebase + Offline-first

> O projeto **já roda** (`cd exercicios/03-flutter-ui-estado/pratica && ls lib` confirma o lugar → `flutter run -d chrome --web-port 5300`). Você completa as TASKs até `flutter test` ficar **todo verde**. Rode `flutter test` no começo — os vermelhos são o seu alvo.

> 🧑‍🏫 **EM AULA (juntos):** TASK 1, 2, 3 (Firebase) e 10 (persistência offline). 🧑‍💻 **EM CASA (sozinho):** TASK 4–9 e 11–15. A numeração é a **mesma do enunciado**.

## Ex1 · TASK 1 — componha o `MovieCard`
`lib/widgets/movie_card.dart`. Troque o stub (só título) por:
```dart
return Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(movie.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Row(children: [
          const Icon(Icons.star, color: Colors.amber, size: 18),
          Text(' ${movie.rating}'),
        ]),
        Text(movie.year, style: const TextStyle(color: Colors.grey)),
      ],
    ),
  ),
);
```
Rode **`flutter test`** → o teste do **Ex1** deve ficar verde.

## Ex2 · TASK 2 — `favoritesProvider` (estado)
`lib/state/favorites.dart`. Apague o stub e implemente:
```dart
class FavoritesNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => {};
  void toggle(int id) {
    state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
  }
}
final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<int>>(FavoritesNotifier.new);
```
> `Notifier` guarda o estado; `state = ...` notifica quem está ouvindo. Como o estado é imutável, criamos um **novo** Set a cada `toggle`.

## Ex2 · TASK 4 — coração no card
`lib/widgets/movie_card.dart`. Vire `ConsumerWidget` e leia o estado:
```dart
class MovieCard extends ConsumerWidget {
  // ...
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoritesProvider).contains(movie.id);
    // ...dentro de um Row, ao lado da Column do título, adicione:
    IconButton(
      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? Colors.red : null),
      onPressed: () => ref.read(favoritesProvider.notifier).toggle(movie.id),
    )
  }
}
```
> `ref.watch` = **lê e re-renderiza** quando muda. `ref.read(...notifier)` = **chama uma ação** (sem ouvir). Lembre dos imports (`flutter_riverpod` + `../state/favorites.dart`).

## Ex2 · TASK 5 — contador no header
`lib/screens/home_screen.dart`. Vire `ConsumerWidget` e troque o `♥ 0`:
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final count = ref.watch(favoritesProvider).length;
  // ... no AppBar actions: Text('♥ $count')
}
```
Rode **`flutter test`** → *"favoritar reflete…"* fica verde. 🎉

## Ex2 · TASK 6 — botão "limpar" 🧑‍💻
No `AppBar` `actions`, antes do contador:
```dart
IconButton(
  icon: const Icon(Icons.delete_outline),
  onPressed: () => ref.read(favoritesProvider.notifier).clear(),
)
```
(precisa do `clear()` no notifier — o do TASK 2.) ✅ teste *"limpar zera o contador"*.

## Ex3 · TASK 9 — escreva um teste 🧑‍💻
`test/favorites_test.dart` — teste o provider **isolado** (sem UI):
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filmes_flutter/state/favorites.dart';

void main() {
  test('favoritos: toggle e clear', () {
    final c = ProviderContainer(); addTearDown(c.dispose);
    expect(c.read(favoritesProvider), isEmpty);
    c.read(favoritesProvider.notifier).toggle(1);
    expect(c.read(favoritesProvider).contains(1), isTrue);
    // complete você: toggle(1) de novo remove · depois clear() esvazia
  });
}
```
> `ProviderContainer` = um "mini-app" pra testar o provider sem tela.

> **O "aha":** card, contador e limpar leem/escrevem o **mesmo** `favoritesProvider` — sem passar estado por parâmetro. É o fim do prop drilling.

---

## Firebase — TASK 3 (aula), 7 e 8 (casa)
Passo a passo do projeto Firebase, das regras do Firestore e do Remote Config: **veja o enunciado** (seções *Setup Firebase*, Ex4 e Ex5). Sem `firebase-tools`? Há o **Plano B** pelo console. Se o favorito **some no F5**, olhe o console do app: `permission-denied` = regras.

## Offline-first — TASK 10 a 15 🧑‍🏫/🧑‍💻
Teste cada TASK com `flutter test test/offline_test.dart` (cada grupo = uma TASK; começa tudo vermelho). Para ver no app: ✈️ na barra do topo = modo avião. **Use sempre `--web-port 5300`** — o cache fica no navegador *por porta*; com porta sorteada o app abre "sem dados salvos" toda vez.

**TASK 10 · aula · fácil** — `lib/main.dart`, logo depois do `Firebase.initializeApp`:
```dart
FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
```
(import `package:cloud_firestore/cloud_firestore.dart`). Na web essa persistência vem **desligada**.

**TASK 11 · fácil** — `widgets/offline_banner.dart`: `ConsumerWidget` → `ref.watch(onlineProvider)` → se `online`, `SizedBox.shrink()`; senão um `Container` com o texto **exato** do enunciado.

**TASK 12 · fácil** — `models/movie.dart`: `toJson()` devolve um `Map` com os 4 campos; `fromJson` faz o caminho de volta. Cuidado: `(json['rating'] as num).toDouble()` — o JSON pode trazer `8` em vez de `8.0`.

**TASK 13 · médio** — `data/movie_repository.dart`, `watchMovies()` (é um `Stream` com `async*` e `yield`). Pense na ordem:
1. `readCache()` — se tem, `yield` os filmes **na hora**;
2. `remote.fetchMovies()` — deu certo? `writeCache(...)` e `yield` os frescos;
3. `OfflineException`: se **já havia cache**, engula; se **não havia**, `rethrow`.

**TASK 14 · médio** — mesmo arquivo. `cacheStatus()` compara `now().difference(savedAt)` com `ttl` (use `now()`, **não** `DateTime.now()`: o teste controla o relógio). No `watchMovies`, se o status for `fresh`, **encerre sem buscar** na API.

**TASK 15 · 🔴 difícil** — `data/sync_queue.dart`. A persistência e o id único já vêm prontos.
- *Conflitos (`enqueue`)*: ache na fila uma operação do **mesmo filme**. **Mesma ação** → não duplique. **Ação oposta** → as duas se cancelam (remova a antiga, salve, e não enfileire a nova).
- *`flush`*: percorra a fila **em ordem**; a cada sucesso remova + `await _save(...)`; no **primeiro erro**, `break` (o resto fica) e **não** propague o erro; devolva quantas foram.
> Os nomes dos testes descrevem cada caso — leia a mensagem do teste que falhar: ela é a dica.
