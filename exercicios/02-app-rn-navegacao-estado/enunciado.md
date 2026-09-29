# Atividade 2 — App de Feed: Favoritos + MMKV + Reanimated (15 pts)

**Disciplina:** Arquitetura de Aplicações Móveis e Multiplataforma
**Entrega:** ver Canvas
**Modalidade:** individual
**Tempo estimado:** **~2h** (estende app construído no hands-on da Aula 2)
**Dificuldade:** ⭐⭐⭐ Difícil — implementação RN com MMKV + Reanimated + Zustand; requer simulador iOS ou Android

---

## Por que essa atividade

Hands-on da Aula 2 te deixou com app rodando: Stack Navigator + Zustand counter + TanStack Query buscando filmes. **Esta atividade estende isso** com 3 conceitos centrais de RN production-grade:

1. **Zustand favorites store** — segundo store, agora com lista (array)
2. **MMKV persistência** — storage síncrono 30x mais rápido que AsyncStorage
3. **Reanimated não-trivial** — animação rodando direto na UI thread

> Saída: app real com data fetching + cache, estado global persistido, e animação fluida. Base sólida pra próximas atividades.

---

## Pré-requisito

Starter `aula-02` rodando localmente:

```bash
git clone https://github.com/SEU-USER/puc-iec-mobile-multiplataforma.git
cd puc-iec-mobile-multiplataforma/exercicios/02-app-rn-navegacao-estado/starter
npm install
cp .env.example .env  # editar com TMDB token
npx expo start
```

Arquitetura: `services/` (HTTP) + `queries/` (TanStack) + `store/` (Zustand) + `screens/` + `components/` + `routes/` + `contexts/` + `__tests__/`. Veja `README.md` do starter.

> Se você fez o hands-on da aula, sua versão do `counterStore` + `usePopularMovies` + `MovieList` já está preenchida. Senão, primeiro complete os Passos 3-5 do hands-on.

---

## Tarefa (5 passos em ~2h)

### 1. Zustand `useFavoritesStore` (~30min)
📁 `src/store/favoritesStore.ts`

Criar `src/store/favoritesStore.ts`:

```typescript
type FavoritesState = {
  ids: number[];
  add: (id: number) => void;
  remove: (id: number) => void;
  toggle: (id: number) => void;
  clear: () => void;
  isFavorite: (id: number) => boolean;
};
```

- `add`/`remove` mutam o array
- `toggle` adiciona se não estiver, remove se estiver
- `isFavorite` é seletor derivado

Na `MovieList`, cada item tem botão ❤️ que chama `toggle(movie.id)`. Cor do ❤️ muda se `isFavorite(movie.id)`.

### 2. Persistência com MMKV (~30min)
📁 `src/storage/mmkv.ts` + atualizar `src/store/favoritesStore.ts`

MMKV já vem instalado no starter (`package.json`).

Criar `src/storage/mmkv.ts`:
```typescript
import { MMKV } from 'react-native-mmkv';
export const storage = new MMKV();
```

Integrar com Zustand store via `persist` middleware OU manualmente em `subscribe`. Favoritos devem **sobreviver a reloads** do app.

> 💡 MMKV é **síncrono** (diferente de AsyncStorage). Por isso ~30x mais rápido. Funciona no JSI = sem bridge.

### 3. Animação Reanimated não-trivial (~45min)
📁 criar `src/components/HeartButton.tsx` + integrar em `src/components/MovieCard.tsx`

Escolha **1** (não precisa fazer as 3):

| Opção | O que faz |
|---|---|
| **A — Heart pop** | Tocar ❤️ → escala spring (1 → 1.4 → 1.0) + rotação leve. Worklet puro. |
| **B — Card swipe** | Swipe lateral em card de filme com `useAnimatedGestureHandler`. Threshold pra "favoritar" ou "descartar". |
| **C — Shared element** | Imagem do filme cresce com `withSpring` ao navegar pra `MovieDetail`. Tipo Apple Music. |

Deve usar `useSharedValue` + `useAnimatedStyle` + worklets. **Não vale `Animated` API legado**.

### 4. Testes com IA (~20min)
📁 `__tests__/counterStore.test.ts` + `__tests__/favoritesStore.test.ts`

Use IA pra gerar testes Jest. **Mínimo 6 testes verdes** (3 counter + 3 favorites) — CI GitHub Actions valida automático.

Prompts sugeridos:
```
Cole o conteúdo de counterStore.ts e peça:
"Adicione testes Jest pra cada action (decrement, reset) + edge cases.
Mantenha estilo dos testes existentes."
```

CI workflow já vem em `.github/workflows/test.yml`. Push pro seu fork dispara teste automático. Verde no Actions = pontos.

### 5. Entrega

Push pro seu fork → abre PR. CI valida automático (autograder lê o código, sem exigir README/screencast).

---

## Critérios de avaliação

| Critério | Pontos |
|---|---|
| App roda sem erro (`npm install && npx expo start`) | 2 |
| `useFavoritesStore` Zustand funcional (toggle, isFavorite, add, remove, clear) | 4 |
| MMKV persistindo favoritos entre reloads | 3 |
| Reanimated não-trivial rodando na UI thread (worklets) | 4 |
| **CI GitHub Actions verde** (≥ 6 testes Jest verdes, gerados com auxílio de IA) | 2 |

**Total: 15 pts**

> 🎁 **Bonus** (não conta pra máxima, considerado em arredondamento):
> - Deep link funcionando (`expo://detail/<id>`)
> - 2 das 3 opções Reanimated (A/B/C) = +1pt
> - **Bottom Tabs** com aba `Favoritos` mostrando lista persistida = +2pt
> - Hermes habilitado (verificar em `app.json`)
> - TanStack Query com `staleTime` configurado + `prefetchQuery` antes do detail = +1pt
> - **Paginação infinita** na lista de filmes (`onEndReached` + `useInfiniteQuery`, ou incrementar `page` manualmente) — TMDB já devolve `page`/`total_pages` na resposta

---

## O que você NÃO precisa fazer

- Não precisa app **bonito** (foco em fluxo, animação, persistência)
- Não precisa Bottom Tabs (bonus opcional)
- Não precisa testar (próxima disciplina foca em testes)
- Não precisa rodar em device físico (web é suficiente, mas Reanimated em web tem limitações — preferir simulador iOS/Android)

---

## Recomendado: use IA pra acelerar

```
"Crie store Zustand useFavoritesStore com array ids + actions toggle(id),
add(id), remove(id), clear() e seletor isFavorite(id). Persistir com
MMKV via subscribe — síncrono. TypeScript tipado."
```

```
"Worklet Reanimated 3 que escala um Animated.View de 1.0 → 1.4 → 1.0
com withSpring quando tap no ❤️. useSharedValue + useAnimatedStyle.
TypeScript."
```

> ⚠️ **IA é ajudante.** Cola código sem entender → perde nota na arguição. Reanimated tem armadilhas (`runOnJS`, `worklet` directive) que IA às vezes esquece.

---

## Entrega via GitHub (fork + PR)

Ver [`COMO_ENTREGAR.md`](https://github.com/jacksonsmith/puc-iec-mobile-multiplataforma/blob/main/COMO_ENTREGAR.md) na raiz do repo público.

Resumo:
1. Fork do repo público
2. Branch `entrega/atividade-2-<seu-nome>`
3. Pasta `exercicios/02-app-rn-navegacao-estado/<seu-nome>/` no SEU fork
4. Código do app + README.md (comando de rodar + referência)
5. Commit + push + link no Canvas

---

## Material de apoio (todos no GitHub público)

- **[Starter `aula-02`](https://github.com/jacksonsmith/puc-iec-mobile-multiplataforma/tree/main/exercicios/02-app-rn-navegacao-estado/starter)** — base obrigatória (com TODOs guiados, CI configurado, testes prontos pra preencher)
- **[guia-passo-a-passo.md](https://github.com/jacksonsmith/puc-iec-mobile-multiplataforma/blob/main/exercicios/02-app-rn-navegacao-estado/guia-passo-a-passo.md)** — comandos + código exemplo
- **[template-relatorio.md](https://github.com/jacksonsmith/puc-iec-mobile-multiplataforma/blob/main/exercicios/02-app-rn-navegacao-estado/template-relatorio.md)** — README modelo
- **[Material aula 2](https://github.com/jacksonsmith/puc-iec-mobile-multiplataforma/tree/main/material-de-apoio/aula-02)** (Meta New Arch, Hermes, Reanimated)
- **[Slide aula 2](https://github.com/jacksonsmith/puc-iec-mobile-multiplataforma/blob/main/slides/aula-02/aula-02-react-native-new-architecture.pdf)**
- **[Zustand docs](https://github.com/pmndrs/zustand)** + **[TanStack Query](https://tanstack.com/query/latest)** + **[Reanimated](https://docs.swmansion.com/react-native-reanimated/)** + **[MMKV](https://github.com/mrousavy/react-native-mmkv)**
