# Atividade 3 — App Flutter: UI + Estado + Firebase (15 pts)

**Disciplina:** Arquitetura de Aplicações Móveis e Multiplataforma
**Aula:** 3 · **Entrega:** ver Canvas
**Modalidade:** individual · **Dificuldade:** ⭐⭐⭐ Médio-difícil
**Auto-grade:** ✅ (J.A.R.V.I.S. lê seu PR)

> Na Aula 3 você viu Flutter por dentro — **widgets, composição e estado com Riverpod** — e começou a montar o `MovieCard` no DartPad. **Esta atividade é o término disso, num projeto Flutter de verdade**, e estende o estado local pra **cloud com Firebase** (Firestore + Remote Config). Você baixa o projeto (que já roda), completa os scaffolds e faz os **testes ficarem verdes** — inclusive **um teste que você mesmo escreve**.

## Objetivos de aprendizagem (Bloom)
- **Entender** — explicar a UI do Flutter como **árvore de widgets** e por que estado compartilhado pede um *provider* (e não prop drilling).
- **Aplicar (Ex1)** — **compor** um `MovieCard` (`Card`/`Column`/`Row`/`Text`/`Icon`).
- **Aplicar/Analisar (Ex2)** — **modelar estado compartilhado** com **Riverpod** refletindo em 3 lugares (card, contador, botão limpar) a partir de **uma fonte só**.
- **Aplicar (Ex3)** — **escrever um teste automatizado** do estado (`flutter test` com `ProviderContainer`).
- **Aplicar (Ex4)** — **persistir estado na nuvem** com **Firestore**, substituindo a fonte de verdade local por um documento remoto.
- **Aplicar (Ex5)** — **consumir configuração remota** com **Firebase Remote Config** pra controlar comportamento da UI sem novo deploy.
- **Avaliar** — argumentar (README, 1 parágrafo) o trade-off entre estado **local** (rápido, offline, mas preso ao device) e estado **cloud** (sincroniza entre devices, mas depende de rede/latência).

## 📍 Em aula (🧑‍🏫) × em casa (🧑‍💻)
Fazemos **juntos em aula**: **TASK 1** (compor o card), **TASK 2** (provider local) e **TASK 3** (criar seu projeto Firebase + `flutterfire configure` — cada aluno com o próprio projeto grátis). **TASK 4–9 você termina sozinho** (parte solo avaliativa).

---

## Setup (na aula a gente começa o download)
```bash
flutter doctor                          # https://docs.flutter.dev/get-started/install
cd exercicios/03-flutter-ui-estado/pratica
flutter pub get
flutter run -d chrome                   # o app já abre (lista de filmes), sem emulador
flutter test                            # começa VERMELHO — deixe verde (checklist_test.dart confirma que terminou tudo)
```

### Setup Firebase (TASK 3, feito junto em aula)
Cada aluno precisa do **próprio projeto Firebase** (gratuito, plano Spark — não precisa cartão):
```bash
dart pub global activate flutterfire_cli
npm install -g firebase-tools           # se ainda não tiver
firebase login                          # abre o browser, loga com sua conta Google

flutterfire configure                   # escolhe "Create a new project" (ou usa um seu já existente)
                                         # marca só a plataforma "web"
                                         # gera lib/firebase_options.dart — NÃO commita esse arquivo com valores reais de produção,
                                         # mas pro nosso caso (projeto pessoal, free tier) pode ir no PR sem problema
```
No [console do Firebase](https://console.firebase.google.com/) do seu projeto:
1. **Build → Firestore Database** → "Criar banco de dados" → *Location*: pode manter a sugestão → modo **teste** (regras abertas por 30 dias). Se aparecer *backup* ou plano Blaze, **ignore** (exige plano pago).
2. **Build → Remote Config** → "Criar configuração" → adiciona um parâmetro chamado `banner_message` (string, valor padrão: `"Bem-vindo ao app de filmes!"`) → **Publicar alterações** (sem publicar, o app não recebe o valor)

> `dart` já vem **dentro do Flutter SDK** — não precisa instalar à parte. Se `dart` não for reconhecido, o Flutter não está no seu PATH.

**Plano B — sem CLI** (se `npm install -g` ou o `firebase login` travarem, ex.: máquina sem permissão de administrador):
1. [Console do Firebase](https://console.firebase.google.com/) → **Adicionar projeto** (plano Spark, sem cartão).
2. Visão geral → ícone **`</>` (Web)** → registre o app (apelido qualquer) → copie o objeto `firebaseConfig`.
3. Crie **`lib/firebase_options.dart`** com os seus valores (o `flutterfire configure` só gera esse arquivo pra você):
```dart
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: 'SUA_API_KEY',
    appId: 'SEU_APP_ID',
    messagingSenderId: 'SEU_SENDER_ID',
    projectId: 'SEU_PROJECT_ID',
  );
}
```
4. Siga normalmente com Firestore e Remote Config no console (passos abaixo).

**Regras do Firestore.** O modo teste expira em 30 dias. Alternativa que não expira (Firestore → *Regras* → colar → *Publicar*):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /favorites/meus-favoritos { allow read, write: if true; }
  }
}
```
> Se escolher **modo produção**, tudo é negado e o favorito some no F5 sem aviso. No console do app aparece `permission-denied` (e, no `flutter test`, "No Firebase App" — esperado).

> ⚠️ **Custo zero.** Firestore + Remote Config no plano Spark cobrem esse exercício de sobra (uso de sala de aula é irrisório perto do limite grátis). Nunca peça cartão de crédito pra fazer essa atividade.

---

## Exercício 1 — UI: componha o `MovieCard`
🧑‍🏫 **TASK 1** (`lib/widgets/movie_card.dart`): hoje o card mostra **só o título**. Componha:
- `Card` → `Padding(16)` → `Column` (`crossAxisAlignment: .start`, `mainAxisSize: .min`): **título** (20, negrito) · **nota** (`Row` com `Icon(Icons.star, color: Colors.amber)` + `Text(' ${movie.rating}')`) · **ano** (`movie.year`, cinza).

✅ **Verde:** teste *"Ex1 — MovieCard mostra título, nota (⭐) e ano"*.

## Exercício 2 — Estado local: favoritos com Riverpod
Uma fonte só (`favoritesProvider`) refletindo no **card**, no **contador** e no botão **limpar**:
1. 🧑‍🏫 **TASK 2** (`state/favorites.dart`): `favoritesProvider` (`Notifier<Set<int>>` com `toggle(id)` **e** `clear()`).
2. 🧑‍💻 **TASK 4** (`widgets/movie_card.dart`): vire `ConsumerWidget`, leia `ref.watch(favoritesProvider)` e adicione um coração (`IconButton` `favorite`/`favorite_border`) que chama `toggle`.
3. 🧑‍💻 **TASK 5** (`screens/home_screen.dart`): vire `ConsumerWidget` e mostre `♥ <nº>` (`ref.watch(favoritesProvider).length`).
4. 🧑‍💻 **TASK 6** (`screens/home_screen.dart`): botão **limpar** (`IconButton(Icons.delete_outline)`) que chama `clear()`.

✅ **Verde:** *"Ex2 — favoritar reflete…"* + *"Ex2 — limpar zera o contador"*.

> **Prova do estado compartilhado:** card, contador e limpar leem/escrevem o **mesmo** provider — sem passar nada por parâmetro. Isso é a base que o Firestore (Ex4) vai persistir.

## Exercício 3 — Testes: você escreve
🧑‍💻 **TASK 9** (`test/favorites_test.dart`): escreva um teste **unitário** do `favoritesProvider` local com `ProviderContainer` (sem UI, sem Firestore): começa vazio → `toggle(1)` adiciona → `toggle(1)` remove → `clear()` esvazia. (Há um modelo comentado no arquivo.)

✅ **Verde:** seu teste em `test/favorites_test.dart` passa (`flutter test`).

## Exercício 4 — Firestore: favoritos na nuvem
🧑‍💻 **TASK 7** (`state/favorites.dart` + `lib/main.dart`): depois do TASK 3 (seu projeto Firebase configurado), troque a fonte de verdade do `favoritesProvider` — em vez de só `Set<int>` em memória, **sincronize com Firestore**:
- `main.dart`: `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);` antes do `runApp`.
- `favorites.dart`: ao montar (`build()`), leia o documento `favorites/meus-favoritos` do Firestore pra popular o estado inicial. Em `toggle(id)` e `clear()`, além de atualizar o `state` local (pra UI reagir na hora), grave a mudança no mesmo documento (`.set({...})` ou `.update({...})`).
- Modelo comentado no arquivo mostra a estrutura exata (imports, `FirebaseFirestore.instance`, nome da coleção).

✅ **Como testar você mesmo:** favorita um filme, dá **refresh completo** da página (`F5`) — o favorito **continua lá** (antes, sumia — só vivia na memória).

> **Por que isso importa:** estado local (TASK 2) é rápido mas morre com o reload. Firestore persiste — e sincroniza entre abas/dispositivos automaticamente (teste abrindo 2 abas!).

## Exercício 5 — Remote Config: comportamento sem novo deploy
🧑‍💻 **TASK 8** (`lib/screens/home_screen.dart` + novo arquivo `lib/services/remote_config.dart`): busque o parâmetro `banner_message` (criado no setup) via `firebase_remote_config` e mostre num banner no topo da `HomeScreen`.
- `remote_config.dart`: inicializa `FirebaseRemoteConfig.instance`, `setConfigSettings` (fetch timeout curto, tipo 10s), `fetchAndActivate()`, expõe `getString('banner_message')`.
- `home_screen.dart`: chama isso no `initState`/equivalente e renderiza o texto retornado num `Container` no topo.

✅ **Como testar você mesmo:** muda o valor de `banner_message` no console do Firebase → dá refresh no app → o texto muda **sem você recompilar nada**.

---

## Critérios de avaliação (15 pts)
| # | Critério | Pts | Como é medido |
|---|---|---|---|
| 1 | App compila e roda (`flutter run` / `flutter analyze` limpo) | 2 | manual (eliminatório) |
| 2 | **Ex1** · `MovieCard` compõe título + nota (⭐) + ano | 2 | `flutter test` |
| 3 | **Ex2** · favoritar (local) reflete no card + contador + limpar | 2 | `flutter test` |
| 4 | **Ex4** · Firestore — favoritos persistem após reload | 4 | manual + estrutural |
| 5 | **Ex5** · Remote Config — banner busca valor remoto | 2 | estrutural |
| 6 | **Ex3** · teste autoral do provider local passa | 2 | `flutter test` |
| 7 | README — como rodar + **1 parágrafo**: local vs cloud (trade-off) | 1 | manual (Canvas) |

> O autograder posta uma **nota mínima** (parte estrutural/estática — ele **lê** o código, não executa `flutter test` de verdade nem acessa seu Firestore). Persistência real (Ex4) e comportamento do Remote Config (Ex5) são conferidos na **leitura manual** do PR + o vídeo curto pedido no README. A final sai no Canvas.

## Entrega
- **Fork + Pull Request** no repo público; cole o link no Canvas.
- **Hands-on da aula não pontua** — a entrega solo vale os 15 pts.
- ✏️ **Edite os arquivos dentro de `exercicios/03-flutter-ui-estado/pratica/` (no lugar)** — **não crie subpasta** `aluno-.../`.
- **README:** além do parágrafo local vs cloud, inclua 1 print ou GIF curto mostrando o favorito sobrevivendo ao refresh (prova do Firestore funcionando) — é o que o professor confere na correção manual do Ex4/Ex5.
- Pode commitar seu `lib/firebase_options.dart` — é config de um projeto pessoal free tier, não é segredo de produção.

> **KMP entra na Aula 5** — aqui o foco é **UI + estado local + estado cloud (Firebase)**.
