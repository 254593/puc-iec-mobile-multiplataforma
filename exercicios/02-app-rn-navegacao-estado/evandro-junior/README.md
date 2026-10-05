# README — Atividade 2 — Evandro Junior

## Identificação

- **Aluno:** Evandro Junior
- **Opção Reanimated escolhida:** A — heart pop
- **Bonus implementado:** nenhum
- **Repo (seu fork):** https://github.com/254593/puc-iec-mobile-multiplataforma/tree/entrega/atividade-2-evandro-junior/exercicios/02-app-rn-navegacao-estado/evandro-junior

## Como rodar

```bash
npm install
export TMDB_API_KEY=... # token/API key da TMDB (o .env lê dessa variável)
cp .env.example .env
npx expo start
```

> ⚠️ MMKV não roda em web nem no Expo Go (é módulo nativo). Use um development build no simulador iOS (`i`) ou Android (`a`).
> Em web (`npx expo start --web`) o app roda com polyfill de `localStorage` no lugar do MMKV.

Testes:

```bash
npm test   # 10 testes (4 counter + 6 favorites)
```

## O que o app faz

Lista os filmes populares da TMDB (TanStack Query com cache de 5 min) e abre o detalhe de cada filme. Cada filme tem um ❤️ que favorita/desfavorita via store Zustand (`useFavoritesStore`); os favoritos são persistidos no MMKV e sobrevivem ao reload do app. Ao tocar no ❤️, ele "pula" (escala 1 → 1.4 → 1 com mola + rotação leve) numa animação Reanimated que roda na UI thread.

## Screenshot

![Lista com favoritos](./screenshot.png)

## Screencast da animação

![Animação Reanimated](./screencast.gif)

## Arquitetura

```
src/
├── routes/
│   └── RootStack.tsx
├── screens/
│   ├── MovieList.tsx         ← FlatList de MovieCard
│   └── MovieDetail.tsx       ← também tem o HeartButton
├── components/
│   ├── MovieCard.tsx
│   └── HeartButton.tsx       ← animação Reanimated
├── store/
│   ├── counterStore.ts
│   └── favoritesStore.ts     ← Zustand + persist manual (subscribe) + MMKV
├── queries/
│   └── movies/               ← TanStack Query
├── services/
│   └── api.ts                ← axios + token TMDB
└── storage/
    └── mmkv.ts               ← MMKV (nativo) / localStorage (web)
```

## Decisões técnicas

- **Reanimated opção A (heart pop):** é a que dá feedback direto na ação principal da tela (favoritar). `useSharedValue` + `useAnimatedStyle` mantêm a animação na UI thread; a JS thread só dispara o `withSequence(withTiming, withSpring)`.
- **MMKV em vez de AsyncStorage:** a leitura é síncrona, então o store já nasce com os favoritos carregados (`loadInitial()`), sem hidratação assíncrona nem "piscar" de lista vazia. Escrita via `subscribe` a cada mudança de `ids`.
- **Atualizações imutáveis no store:** `add`/`remove`/`toggle` criam um array novo em vez de mutar `ids`, pois o React detecta mudança por referência. `add` não duplica ids.
- **Trade-off:** MMKV exige development build (não roda no Expo Go). Dependências alinhadas ao Expo SDK 54 com `npx expo install --fix` (Reanimated 4.1 + `react-native-worklets`).

## Referência

- Reanimated — documentação oficial. Software Mansion. https://docs.swmansion.com/react-native-reanimated/
- react-native-mmkv — documentação oficial. https://github.com/mrousavy/react-native-mmkv

---

## 🎁 Bonus implementado (opcional)

- [ ] **Bottom Tabs com aba Favoritos filtrada — +2pt**
- [ ] Deep link `expo://detail/<id>` — +1pt
- [ ] 2 das 3 opções Reanimated (A/B/C) — +1pt
- [ ] TanStack Query `staleTime` + `prefetchQuery` — +1pt
- [ ] Hermes habilitado (verificar `app.json`) — +0.5pt
- [ ] CI GitHub Actions verde — +0.5pt
