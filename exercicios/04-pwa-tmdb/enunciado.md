# Atividade 4 — PWA: filmes populares, instalável e offline (15 pts)

**Disciplina:** Arquitetura de Aplicações Móveis e Multiplataforma
**Entrega:** fork + PR no repositório da disciplina
**Valor:** 15 pontos

---

## Contexto

Você vai completar uma **Progressive Web App** de filmes (TMDB) que já vem com toda a base
funcionando — Service Worker (Workbox), IndexedDB, instalação (`InstallButton`), busca,
lazy loading. Faltam 3 pontos de lógica, marcados com `TODO` no código.

---

## Antes de começar

```bash
cd exercicios/04-pwa-tmdb/pratica

# Confirme que está no lugar certo
ls src/services
# → deve mostrar: tmdb.ts  db.ts
```

> **Windows:** `cd exercicios\04-pwa-tmdb\pratica` e `dir src\services`

```bash
npm install
cp .env.example .env.local        # Windows: copy .env.example .env.local
# Edite .env.local → coloque seu token em VITE_TMDB_TOKEN
# Gere em: https://www.themoviedb.org/settings/api  (Read Access Token)

npm run dev
# Abre http://localhost:5173
```

A tela mostra "Token TMDB não configurado" se o token não estiver configurado.

---

## Roteiro das tarefas

### Em aula com o professor (não avaliativo)

| Arquivo | O que fazemos juntos |
|---|---|
| [`src/__tests__/unit/01-MovieCard.test.tsx`](pratica/src/__tests__/unit/01-MovieCard.test.tsx) | 📘 MODELO — lemos os testes prontos, entendemos a estrutura |
| [`src/services/tmdb.ts`](pratica/src/services/tmdb.ts) | Vemos o stub com `throw` e entendemos o que o TODO 1 pede |

### Solo em casa (avaliativo)

| Ordem | Arquivo | O que implementar | Dificuldade |
|---|---|---|---|
| 1 | [`src/services/tmdb.ts`](pratica/src/services/tmdb.ts) | **TODO 1** — `fetchPopularMovies()` | FÁCIL |
| 2 | [`src/__tests__/unit/03-useFavorites.test.ts`](pratica/src/__tests__/unit/03-useFavorites.test.ts) | **TODO 2** — implemente os 3 casos `it.todo` (testes 3, 4 e 5) | MÉDIO |
| 3 | [`src/screens/HomeScreen.tsx`](pratica/src/screens/HomeScreen.tsx) + [`src/hooks/useOfflineStatus.ts`](pratica/src/hooks/useOfflineStatus.ts) | **TODO 3** — aba Favoritos (3 passos abaixo) | MÉDIO |

---

## TODO 1 — fetchPopularMovies

**Arquivo:** `src/services/tmdb.ts`

Implemente a função que está com `throw` como stub, usando o `tmdbClient` já configurado no
arquivo (axios com baseURL + Bearer token):

```typescript
export async function fetchPopularMovies(page = 1): Promise<MoviesResponse> {
  const { data } = await tmdbClient.get<MoviesResponse>('/movie/popular', {
    params: { language: 'pt-BR', page },
  });
  return data;
}
```

**Verificação:** `npm test` — os testes de `02-tmdb-service.test.ts` devem ficar verdes.

---

## TODO 2 — Testes de useFavorites

**Arquivo:** `src/__tests__/unit/03-useFavorites.test.ts`

Os casos 1 e 2 estão prontos como exemplo. Implemente os `it.todo()`:

- **3.** toggle duas vezes remove o favorito
- **4.** persiste favoritos no localStorage (desmonte e remonte o hook)
- **5.** chama `navigator.setAppBadge` com a contagem

Os comentários dentro de cada `it.todo()` descrevem o que fazer.

---

## TODO 3 — Aba Favoritos (3 passos)

**Passo 1** — em `HomeScreen.tsx`, no bloco `if (activeTab === 'favorites')`:
- Filtre `movies` por `isFavorite(m.id)` → `favMovies`
- Renderize `<MovieCard key={m.id} movie={m} isFavorite={true} onToggleFavorite={toggleFavorite} />` pra cada filme

**Passo 2** — ainda em `HomeScreen.tsx`, estado vazio:
- Se `favMovies.length === 0`, mostre um `<p>` com:
  - `isEmpty === true` → `'Nenhum filme carregado ainda.'`
  - `isEmpty === false` → `'Nenhum favorito ainda — toque ★ em um filme.'`

**Passo 3** — em `src/hooks/useOfflineStatus.ts`:
- `useState` com valor inicial `navigator.onLine`
- `useEffect` com listeners `window.addEventListener('online'/'offline', ...)` + cleanup
- Use `isOnline` (já importado em `HomeScreen`) pra mostrar o banner offline

**Verificação manual (demo em aula):** DevTools → Network → Throttling → "Offline" — o banner
"📡 Offline — exibindo dados do cache" deve aparecer na aba Favoritos.

---

## Teste a instalação também no desktop

O botão "Instalar" (`InstallButton`) já vem pronto e funciona em **desktop** (Chrome/Edge), não só
mobile — o navegador dispara o mesmo evento `beforeinstallprompt` nas duas plataformas. Depois de
rodar `npm run dev`, testa nos dois:

- **Mobile:** abre no celular (mesma rede) ou emula pelo DevTools → botão "Instalar" no banner
- **Desktop:** Chrome/Edge → ícone de instalação na barra de endereço (ou o banner customizado) → "Instalar"

Não precisa mudar nada de código pra isso funcionar — é só confirmar que os dois caminhos abrem o
app como janela standalone (sem barra de endereço).

---

## 🎁 Bônus (não pontua)

- **`window-controls-overlay`**: troca `display: 'standalone'` por `display: 'window-controls-overlay'`
  no manifest (`vite.config.ts`) pra um visual mais nativo em desktop (conteúdo ocupa até embaixo da
  barra de título). Teste com `navigator.windowControlsOverlay` — [doc](https://developer.mozilla.org/en-US/docs/Web/API/WindowControlsOverlay).

---

## Como rodar os testes

```bash
cd exercicios/04-pwa-tmdb/pratica
npm test              # roda uma vez
npm run test:watch    # modo watch
```

---

## Entrega

```bash
git checkout -b feat/a4-pwa
git add exercicios/04-pwa-tmdb/pratica/src/services/tmdb.ts
git add exercicios/04-pwa-tmdb/pratica/src/__tests__/unit/03-useFavorites.test.ts
git add exercicios/04-pwa-tmdb/pratica/src/screens/HomeScreen.tsx
git add exercicios/04-pwa-tmdb/pratica/src/hooks/useOfflineStatus.ts
git commit -m "feat(a4-pwa): implementa TODO 1, 2 e 3"
git push origin feat/a4-pwa
```

Abra PR com título: `feat(a4-pwa): <seu-github-login>`.

O bot comenta a nota mínima automática a cada commit.

---

## Critérios de avaliação

| Critério | Pts |
|---|---|
| TODO 1 — `fetchPopularMovies` chama `tmdbClient.get()` e retorna os dados | 4 |
| TODO 2 — testes 3, 4 e 5 de `useFavorites` implementados com asserções reais | 4 |
| TODO 3 Passo 1 — aba Favoritos filtra e renderiza a lista | 3 |
| TODO 3 Passo 2 — estado vazio (com/sem filme carregado) | 2 |
| TODO 3 Passo 3 — hook `useOfflineStatus` com listeners + cleanup, usado na tela | 2 |
| **Total** | **15** |

> Nota mínima automática vem do bot no PR (checklist estrutural). Qualidade de código entra na
> nota final lançada no Canvas.

---

## Links úteis

- [TMDB API — Movie Popular](https://developer.themoviedb.org/reference/movie-popular-list)
- [axios.get docs](https://axios-http.com/docs/req_config)
- [MDN — Online/offline events](https://developer.mozilla.org/pt-BR/docs/Web/API/Navigator/onLine)
- [Workbox Strategies](https://developer.chrome.com/docs/workbox/caching-strategies-overview/)
- [MDN — Service Worker API](https://developer.mozilla.org/pt-BR/docs/Web/API/Service_Worker_API)
