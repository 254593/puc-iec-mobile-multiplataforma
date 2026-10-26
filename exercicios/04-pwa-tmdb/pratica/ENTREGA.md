# ENTREGA — Atividade 4 (PWA)

> Preencha e faça commit junto com o código. Esta parte vale 3 pts (avaliação manual no Canvas).

**Nome:** Evandro Junior · **GitHub:** 254593

---

## 1. Site comum × PWA — o que EU vi (3 diferenças)

Comparei o PWA do professor (`https://pwa-tmdb-aula4.vercel.app`) com o site do TMDB (`https://www.themoviedb.org/movie`), abrindo os dois, recarregando uma vez e depois recarregando **sem rede**.

| # | Site comum | PWA | Print/evidência |
|---|---|---|---|
| 1 | **Sem rede, não abre:** o reload cai na página de erro do navegador (`ERR_INTERNET_DISCONNECTED`, o dinossauro). | **Sem rede, abre normalmente:** o HTML/JS/CSS vêm do precache do Service Worker e a lista aparece com os dados guardados. | [site offline](evidencias/site-x-pwa-site-offline.png) · [PWA offline](evidencias/site-x-pwa-pwa-offline.png) |
| 2 | **Nenhum Service Worker controla a página** e o Cache Storage fica vazio. (O TMDB até publica um `manifest.json`, mas manifest sozinho não dá offline.) | **Service Worker ativo** controlando a página e cache `workbox-precache-v2-…` com o "app shell". | DevTools → Application → Service Workers / Cache Storage *(print a adicionar)* |
| 3 | **Não oferece instalação:** continua sendo uma aba do navegador, com barra de endereço. | **Instalável:** o app mostra "Instale o app / Instalar" (evento `beforeinstallprompt`). Instalado, abre em janela própria (`display: standalone`), sem barra de endereço. | [banner de instalação](evidencias/site-x-pwa-pwa-instalar.png) |

## 2. Prova do offline no SEU build

Tudo com `npm run build && npm run preview` (http://localhost:4173):

- [ ] Print do **DevTools → Application → Cache Storage** com `tmdb-api` e `tmdb-images` *(print a adicionar: `evidencias/07-cache-storage-devtools.png`)*
  - Conteúdo conferido por script (`caches.keys()` na página): `tmdb-api` com **1** item (`/3/movie/popular`), `tmdb-images` com **13** itens (`image.tmdb.org/t/p/w342/…`), e o precache do Workbox com 8 itens.
- [x] Print do app **sem rede** carregando a lista: [home offline](evidencias/03-home-offline.png). Página **e** Service Worker sem rede: os 20 filmes aparecem e os pôsteres respondem `200` vindos do SW (cache `tmdb-images`).
- [x] Aba **Favoritos** offline com o banner `📡 Offline — exibindo dados do cache`: [favoritos offline](evidencias/04-favoritos-offline.png)
- [x] Aviso **"App pronto para uso offline"** na 1ª visita: [offline ready](evidencias/01-offline-ready.png)
- [x] Aviso **"Nova versão disponível"**: [nova versão](evidencias/05-nova-versao.png). Reproduzido assim: com o preview aberto, mudei o título do cabeçalho para "Filmes Populares (v2)", rodei `npm run build` de novo e forcei a verificação do SW (o mesmo que *Application → Service Workers → Update*). Ao clicar **Atualizar** a página recarregou com o título novo: [depois de atualizar](evidencias/06-depois-atualizar.png). A mudança de título foi desfeita depois do teste.

## 3. Reflexão (5–8 linhas)

`autoUpdate` × `prompt`: qual você escolheria para um app de **checkout** e para um app de **notícias**, e por quê? O que pode dar errado em cada escolha?

Para o **checkout** eu escolheria `prompt`. Trocar o JS no meio de um pagamento (formulário preenchido, passo 3 de 4) pode recarregar a página e perder o carrinho/formulário, ou misturar o cliente antigo com uma API já nova. Com `prompt` o usuário termina a compra e atualiza quando quiser. O risco é ele clicar "Depois" sempre e ficar preso numa versão velha, o que pede uma regra de versão mínima (forçar a atualização quando a API deixar de aceitar a versão antiga). Para **notícias** eu escolheria `autoUpdate`. O conteúdo é de leitura, quase não há estado a perder, e o valor do app é estar sempre atualizado. O risco é recarregar enquanto a pessoa lê e ela perder a posição do texto. Por isso convém aplicar a atualização numa navegação ou quando o app volta do segundo plano, e não com um reload no meio da leitura.

## 4. Declaração de uso de IA

Usei o **Claude Code (Claude Opus 5.5)** como par de programação. Ele implementou os TODOs 1 a 5 seguindo a especificação dos comentários e do enunciado, criou um workflow de CI no meu fork (`npm test` + `npm run build`) e rodou o validador do professor localmente (12/12 automáticos). Também gerou os prints de `evidencias/` com um Chrome automatizado (puppeteer, sem interface), que fez estes passos: 1ª visita, offline real da página e do Service Worker, e ciclo build → "Nova versão" → Atualizar. Por fim, escreveu o rascunho deste arquivo. Eu revisei o código, os prints e o texto da reflexão. O print do DevTools (Cache Storage) e a instalação do app eu fiz/conferi manualmente.
