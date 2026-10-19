# Filmes (Flutter) — Atividade 3 · Evandro Junior

App de catálogo de filmes em **Flutter** (web): UI por composição de widgets, estado compartilhado com
**Riverpod**, favoritos persistidos no **Firestore** e arquitetura **offline-first** (cache com TTL,
banner de conexão e fila de sincronização).

## Como rodar
Pré-requisito: Flutter **3.27+**.

```bash
cd exercicios/03-flutter-ui-estado/pratica
flutter pub get
./rodar.sh                               # = flutter run -d chrome --web-port 5300 (Windows: rodar.bat · VS Code: F5)
```
- **Porta fixa (5300):** o cache offline e a fila ficam no armazenamento do navegador, que é por endereço + porta.
  Abra **uma vez online** (a lista é salva) e só então teste offline.
- **Modo offline:** botão ✈️ na barra do topo (simulado) ou DevTools → Network → **Offline** (real).
- **Firebase:** o app já aponta para o meu projeto `filmes-flutter-a3` (`lib/firebase_options.dart`, config
  pública do app web). Para usar outro projeto, gere o arquivo com `flutterfire configure` (ou à mão, pelo
  console) e publique esta regra no Firestore:
  ```
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /favorites/meus-favoritos { allow read, write: if true; }
    }
  }
  ```
- **TMDB (opcional):** copie `.env.local.example` → `.env.local` com `TMDB_KEY=...` e rode `./rodar.sh`.
  Sem chave, o app usa a lista simulada (é ela que os testes usam).

## Como testar
```bash
flutter test                          # 31 testes: Ex1–Ex3, offline-first (TASKs 11–15) e checklist
flutter test test/offline_test.dart   # só offline-first (cada grupo = 1 TASK)
flutter analyze                       # sem issues
```
> ⚠️ Em macOS, se o caminho da pasta tiver acentos (ex.: `Aplicações Móveis`), o `flutter analyze` pode quebrar
> com `FormatException` dentro do próprio analisador — é bug da ferramenta, não do código. Rode a partir de um
> caminho sem acentos (o CI do GitHub não tem esse problema).

## O que foi feito
| TASK | Arquivo | Implementação |
|---|---|---|
| 1 | `lib/widgets/movie_card.dart` | `Card → Padding → Row(PosterArt · Column(título, ⭐ nota, ano))` |
| 2 | `lib/state/favorites.dart` | `FavoritesNotifier` (`Notifier<Set<int>>`) com `toggle`/`clear` e estado imutável |
| 4–6 | `movie_card.dart`, `home_screen.dart` | coração, contador `♥ n` e botão limpar — todos leem/escrevem o **mesmo** provider |
| 9 | `test/favorites_test.dart` | testes unitários com `ProviderContainer`: vazio → toggle → toggle → clear, imutabilidade e notificação de ouvintes |
| 3, 7 | `lib/firebase_options.dart`, `main.dart`, `favorites.dart` | `Firebase.initializeApp`; favoritos lidos de/gravados em `favorites/meus-favoritos` com **atualização otimista** |
| 10 | `lib/main.dart` | `persistenceEnabled: true` (na web vem desligada) |
| 11 | `lib/widgets/offline_banner.dart` | banner reativo ao `onlineProvider` |
| 12 | `lib/models/movie.dart` | `toJson`/`fromJson` (`rating` aceita `8` ou `8.0`; `posterPath` opcional sobrevive offline) |
| 13 | `lib/data/movie_repository.dart` | `watchMovies` **cache-first** (*stale-while-revalidate*): emite o cache, revalida, grava o fresco; offline com cache segue, sem cache falha |
| 14 | `lib/data/movie_repository.dart` | `cacheStatus()` (none/fresh/stale) com relógio injetado; cache fresco **não** chama a API |
| 15 | `lib/data/sync_queue.dart` | no máximo 1 operação por filme (mesma ação não duplica, oposta cancela); `flush` em ordem, persistindo a cada sucesso e parando no 1º erro |

TASK 8 (Remote Config) foi adiada pelo professor e não faz parte da entrega. A `SyncQueue` (TASK 15) está
implementada e testada, mas **não** foi ligada ao `favoritesProvider` (bônus opcional): no app, favoritos
alterados offline ficam na fila interna do próprio Firestore (TASK 10) e sincronizam quando a rede volta.

## Local × cloud × offline-first (trade-offs)
O estado **local** em memória (TASK 2) é o mais simples e rápido — a UI reage na hora e não depende de rede —,
mas é efêmero e preso ao dispositivo: some no F5 e não chega a outra aba ou aparelho. O estado **cloud** (TASK 7)
inverte isso: o Firestore vira a fonte de verdade, os favoritos sobrevivem ao reload e sincronizam entre
dispositivos, ao custo de latência, dependência de rede, regras de segurança e cota; para a UI não “travar”
esperando o servidor, o app faz **atualização otimista** (muda o `state` antes da escrita confirmar), aceitando
que, se a escrita falhar, local e nuvem divergem — e, como cada `set` sobrescreve o documento inteiro, duas abas
gravando ao mesmo tempo resolvem por *last-write-wins*. O **offline-first** (TASKs 10–15) é o meio-termo
deliberado: a tela sempre lê primeiro o que está **no aparelho** e trata a rede como sincronização em segundo
plano, o que exige decidir quando o dado envelhece (TTL — fresco demais desperdiça rede, velho demais mostra
informação desatualizada) e como resolver conflitos de escritas feitas sem conexão (a `SyncQueue` colapsa
add/remove do mesmo filme e envia em ordem, parando no primeiro erro para não perder nem reordenar
operações). Em troca de mais complexidade (cache, serialização, fila, idempotência), o app continua útil sem
internet e parece instantâneo mesmo com rede lenta.

## Evidências
**Favorito sobrevivendo ao refresh (Firestore):**

> 📌 _GIF a adicionar: `docs/favorito-f5.gif`_

**Modo offline (banner + lista vinda do cache):**

> 📌 _Print a adicionar: `docs/offline.png`_
