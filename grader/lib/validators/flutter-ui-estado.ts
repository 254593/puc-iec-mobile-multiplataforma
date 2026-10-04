/**
 * Validator — Atividade 3 — App Flutter: UI + Estado + Firebase (Arquitetura).
 *
 * RUBRICA REAL do enunciado (15 pts = 12 automáticos + 3 manuais):
 *  M. App compila/roda + `flutter analyze` limpo               — 2pts [MANUAL · eliminatório]
 *  1. Ex1 · MovieCard compõe título + nota (⭐) + ano           — 1pt
 *  2. Ex2 · favoritar (local) reflete no card + contador + limpar — 1pt
 *  3. Ex3 · teste autoral do provider local (favorites_test)   — 1pt
 *  4. Ex4 · Firestore — favoritos persistem após reload        — 1,5pt
 *  5. Ex5 · Remote Config — banner busca valor remoto          — 1pt
 *  6. T10 · persistência offline do Firestore (main.dart)      — 0,5pt
 *  7. T11 · OfflineBanner                                      — 1pt
 *  8. T12 · Movie.toJson / fromJson                            — 1pt
 *  9. T13 · repositório cache-first (stale-while-revalidate)   — 1,5pt
 * 10. T14 · validade do cache (TTL)                            — 1pt
 * 11. T15 · SyncQueue (conflitos + flush)                      — 1,5pt  (difícil)
 *  R. README + parágrafo (local vs cloud)                      — 1pt  [MANUAL]
 *
 * ESTRUTURAL: só LÊ os .dart da entrega (nunca executa código do aluno, nunca acessa
 * o Firestore/Remote Config real do aluno) — seguro sob pull_request_target. **Ignora
 * linhas comentadas** (os scaffolds trazem o modelo em comentários; sem stripping daria
 * falso-positivo). Firestore/Remote Config são checados por PADRÃO DE CÓDIGO (import +
 * chamada da API) — não provam que funciona de verdade (isso é a correção manual +
 * print/GIF pedido no README). Piso = auto.
 */

import { readFileSync, writeFileSync } from 'node:fs';
import { basename } from 'node:path';
import {
  type GradeCriterion,
  type GradeResult,
  buildBreakdowns,
  computeScore,
  computeAuto,
  passThreshold,
} from '../compute-score.js';
import { parseArgs, findFiles } from '../utils.js';

function read(path: string): string {
  try {
    return readFileSync(path, 'utf8');
  } catch {
    return '';
  }
}
// remove linhas comentadas (// ...) — os scaffolds têm a solução em comentário
function stripComments(s: string): string {
  return s
    .split('\n')
    .filter((l) => !l.trimStart().startsWith('//'))
    .join('\n');
}

async function main() {
  const args = parseArgs();
  const criteria: GradeCriterion[] = [];

  const dartFiles = findFiles(args.entrega, ['.dart']);
  const byName = (n: string) =>
    stripComments(dartFiles.filter((f) => basename(f) === n).map(read).join('\n'));
  const card = byName('movie_card.dart');
  const favorites = byName('favorites.dart');
  const home = byName('home_screen.dart');
  const remoteConfig = byName('remote_config.dart');
  const favTest = byName('favorites_test.dart');
  const main_ = byName('main.dart');
  const bannerCode = byName('offline_banner.dart');
  const movieCode = byName('movie.dart');
  const repoCode = byName('movie_repository.dart');
  const queueCode = byName('sync_queue.dart');

  // ---- 1. Compila/analyze — MANUAL (eliminatório) ----
  criteria.push({
    id: 'compila',
    description: 'App compila/roda e `flutter analyze` limpo (eliminatório)',
    weight: 2,
    manual: true,
    earned: 0,
    publicNote: 'Conferido na correção (flutter analyze / flutter run)',
  });

  // ---- 2. Ex1 — MovieCard compõe (2) ----
  const bits = ['Card', 'Column', 'Row', 'Icon', 'movie.rating', 'movie.year'].filter((b) =>
    card.includes(b),
  ).length;
  criteria.push({
    id: 'ex1-ui',
    description: 'Ex1 · MovieCard compõe título + nota (⭐) + ano',
    weight: 1,
    earned: bits >= 6 ? 1 : bits >= 4 ? 0.75 : bits >= 2 ? 0.5 : 0,
    publicNote: `${bits}/6 elementos no card (Card/Column/Row/Icon/rating/ano)`,
  });

  // ---- 3. Ex2 — favoritar local + contador + limpar, tudo junto (2) ----
  const providerOk =
    /NotifierProvider|StateNotifierProvider|ChangeNotifierProvider/.test(favorites) &&
    /\btoggle\b/.test(favorites);
  const cardConsumer =
    /ConsumerWidget/.test(card) && /ref\.watch\(\s*favoritesProvider/.test(card) && /toggle/.test(card);
  const headerCount = /ref\.watch\(\s*favoritesProvider/.test(home) && /\.length/.test(home);
  const clearInProvider = /\bclear\b/.test(favorites);
  const clearButton = /delete_outline/.test(home) || /\.notifier\)\s*\.clear\(\)/.test(home);
  const ex2Signals = [providerOk, cardConsumer, headerCount, clearInProvider && clearButton].filter(
    Boolean,
  ).length;
  criteria.push({
    id: 'ex2-fav-local',
    description: 'Ex2 · favoritar (local) reflete no card + contador + limpar',
    weight: 1,
    earned: Math.round((ex2Signals / 4) * 1 * 100) / 100,
    publicNote: `provider+toggle=${providerOk} · card=${cardConsumer} · contador=${headerCount} · limpar=${clearInProvider && clearButton}`,
  });

  // ---- 4. Ex4 — Firestore (4): import + init no main + leitura + escrita no provider ----
  const firestoreImport = /from\s+['"]cloud_firestore['"]|import\s+['"]package:cloud_firestore/.test(
    favorites,
  );
  const firebaseInitialized = /Firebase\.initializeApp/.test(main_);
  const firestoreRead = /FirebaseFirestore\.instance/.test(favorites) && /\.get\s*\(\s*\)/.test(favorites);
  const firestoreWrite =
    /FirebaseFirestore\.instance/.test(favorites) && (/\.set\s*\(/.test(favorites) || /\.update\s*\(/.test(favorites));
  const firestoreSignals = [firestoreImport, firebaseInitialized, firestoreRead, firestoreWrite].filter(
    Boolean,
  ).length;
  criteria.push({
    id: 'ex4-firestore',
    description: 'Ex4 · Firestore — favoritos persistem após reload',
    weight: 1.5,
    earned: Math.round((firestoreSignals / 4) * 1.5 * 100) / 100,
    publicNote: `import=${firestoreImport} · Firebase.initializeApp no main=${firebaseInitialized} · leitura=${firestoreRead} · escrita=${firestoreWrite} (persistência real conferida na leitura manual + print/GIF do README)`,
  });

  // ---- 5. Ex5 — Remote Config (2): import + fetchAndActivate + getString + usado no home ----
  const rcImport = /firebase_remote_config/.test(remoteConfig);
  const rcFetch = /fetchAndActivate\s*\(\s*\)/.test(remoteConfig);
  const rcGet = /getString\s*\(/.test(remoteConfig);
  const rcUsedInHome = /fetchBannerMessage/.test(home);
  const rcSignals = [rcImport, rcFetch, rcGet, rcUsedInHome].filter(Boolean).length;
  criteria.push({
    id: 'ex5-remote-config',
    description: 'Ex5 · Remote Config — banner busca valor remoto',
    weight: 1,
    earned: Math.round((rcSignals / 4) * 1 * 100) / 100,
    publicNote: `import=${rcImport} · fetchAndActivate=${rcFetch} · getString=${rcGet} · usado no HomeScreen=${rcUsedInHome}`,
  });

  // ---- 6. Ex3 — teste autoral do provider local (2) ----
  const hasTest = /\btest\s*\(/.test(favTest);
  const usesProvider = /favoritesProvider/.test(favTest);
  criteria.push({
    id: 'ex3-teste',
    description: 'Ex3 · teste autoral do provider local (test/favorites_test.dart)',
    weight: 1,
    earned: hasTest && usesProvider ? 1 : hasTest || usesProvider ? 0.5 : 0,
    publicNote:
      hasTest && usesProvider
        ? 'teste do provider escrito (test() usando favoritesProvider)'
        : 'favorites_test.dart sem um test() de verdade usando favoritesProvider',
  });

  // ---- 6. T10 — persistência offline do Firestore (0,5) ----
  const persistOn = /persistenceEnabled\s*:\s*true/.test(main_);
  criteria.push({
    id: 't10-persistencia',
    description: 'T10 · persistência offline do Firestore ligada (main.dart)',
    weight: 0.5,
    earned: persistOn ? 0.5 : 0,
    publicNote: persistOn
      ? 'Settings(persistenceEnabled: true) encontrado no main.dart'
      : 'falta `FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true)` no main.dart',
  });

  // ---- 7. T11 — OfflineBanner (1) ----
  const bannerConsumer = /ConsumerWidget/.test(bannerCode) && /ref\.watch\(\s*onlineProvider/.test(bannerCode);
  const bannerText = /Você está offline — mostrando dados salvos/.test(bannerCode);
  const bannerCond = /online\s*\?|!\s*online|if\s*\(\s*online|if\s*\(\s*!\s*online/.test(bannerCode);
  const bannerSignals = [bannerConsumer, bannerText, bannerCond].filter(Boolean).length;
  criteria.push({
    id: 't11-banner',
    description: 'T11 · OfflineBanner mostra o aviso só quando offline',
    weight: 1,
    earned: Math.round((bannerSignals / 3) * 1 * 100) / 100,
    publicNote: `ConsumerWidget+onlineProvider=${bannerConsumer} · texto exato=${bannerText} · condição online/offline=${bannerCond}`,
  });

  // ---- 8. T12 — serialização (1) ----
  const toJsonDone = !/toJson\(\)\s*=>\s*throw/.test(movieCode) && /toJson\(\)/.test(movieCode) && /'title'/.test(movieCode);
  const fromJsonDone =
    !/Movie\.fromJson\([^)]*\)\s*=>\s*throw/.test(movieCode) && /Movie\.fromJson/.test(movieCode) && /toDouble\(\)/.test(movieCode);
  criteria.push({
    id: 't12-serializacao',
    description: 'T12 · Movie.toJson e Movie.fromJson',
    weight: 1,
    earned: (toJsonDone ? 0.5 : 0) + (fromJsonDone ? 0.5 : 0),
    publicNote: `toJson=${toJsonDone} · fromJson (com toDouble p/ rating inteiro)=${fromJsonDone}`,
  });

  // ---- 9/10. T13 + T14 — repositório ----
  const watchIdx = repoCode.indexOf('watchMovies');
  const watchBody = watchIdx >= 0 ? repoCode.slice(watchIdx) : '';
  const yields = (watchBody.match(/\byield\b/g) ?? []).length;
  const cacheFirst = /readCache\(\)/.test(watchBody) && yields >= 2;
  const writesFresh = /writeCache\(/.test(watchBody);
  const offlineSafe = /OfflineException|catch\s*\(/.test(watchBody) && /rethrow/.test(watchBody);
  const t13Signals = [cacheFirst, writesFresh, offlineSafe].filter(Boolean).length;
  criteria.push({
    id: 't13-cache-first',
    description: 'T13 · repositório cache-first (emite o cache, revalida, tolera offline)',
    weight: 1.5,
    earned: Math.round((t13Signals / 3) * 1.5 * 100) / 100,
    publicNote: `cache primeiro (readCache + 2 yields)=${cacheFirst} · grava o fresco=${writesFresh} · offline com cache segue / sem cache falha=${offlineSafe}`,
  });

  const statusIdx = repoCode.indexOf('cacheStatus()');
  const statusBody = statusIdx >= 0 ? repoCode.slice(statusIdx, watchIdx > statusIdx ? watchIdx : undefined) : '';
  const statusImpl = /\bttl\b/.test(statusBody) && /now\(\)/.test(statusBody) && /CacheStatus\.(fresh|stale)/.test(statusBody);
  const ttlUsed = /cacheStatus\(\)/.test(watchBody);
  criteria.push({
    id: 't14-ttl',
    description: 'T14 · validade do cache (TTL): cacheStatus + não buscar quando fresco',
    weight: 1,
    earned: (statusImpl ? 0.5 : 0) + (ttlUsed ? 0.5 : 0),
    publicNote: `cacheStatus com ttl e now()=${statusImpl} · usado no watchMovies=${ttlUsed}`,
  });

  // ---- 11. T15 — SyncQueue (1,5) ----
  const enqIdx = queueCode.indexOf('enqueue(');
  const flushIdx = queueCode.indexOf('flush(');
  const enqBody = enqIdx >= 0 ? queueCode.slice(enqIdx, flushIdx > enqIdx ? flushIdx : undefined) : '';
  const flushBody = flushIdx >= 0 ? queueCode.slice(flushIdx) : '';
  const conflicts =
    /movieId\s*==\s*op\.movieId/.test(enqBody) &&
    /\.add\s*(==|!=)\s*op\.add/.test(enqBody) &&
    /removeAt|removeWhere|\.remove\(/.test(enqBody);
  const flushOk = /\bsend\(/.test(flushBody) && /break|return\s+sent/.test(flushBody) && /_save\(/.test(flushBody);
  criteria.push({
    id: 't15-fila',
    description: 'T15 · SyncQueue: regras de conflito no enqueue + flush na ordem, parando no 1º erro',
    weight: 1.5,
    earned: (conflicts ? 0.75 : 0) + (flushOk ? 0.75 : 0),
    publicNote: `conflitos (mesma ação / ação oposta)=${conflicts} · flush (send + parar no erro + persistir a cada sucesso)=${flushOk}`,
  });

  // ---- R. README + parágrafo — MANUAL ----
  criteria.push({
    id: 'readme',
    description: 'README — como rodar + parágrafo (local vs cloud) + print/GIF do Firestore',
    weight: 1,
    manual: true,
    earned: 0,
    publicNote: 'Lido na correção (Canvas)',
  });

  const { total } = computeScore(criteria);
  const { autoScore, autoTotal, manualTotal } = computeAuto(criteria);
  const minimo = passThreshold(total, 60);
  const { publicBreakdown, privateBreakdown } = buildBreakdowns(criteria);

  const result: GradeResult = {
    atividade: 'MOBILE-A3-Flutter-UI-Estado',
    total,
    score: autoScore,
    autoScore,
    autoTotal,
    manualTotal,
    minimo,
    pass: autoScore >= minimo,
    criteria,
    publicBreakdown,
    privateBreakdown,
    metadata: {
      studentLogin: args.studentLogin,
      entregaPath: args.entrega,
      timestamp: new Date().toISOString(),
      commitSha: args.commitSha,
    },
  };

  writeFileSync(args.output, JSON.stringify(result, null, 2));
  console.log(`Grade: ${result.score}/${result.total} (min ${result.minimo}) — ${result.pass ? 'PASS' : 'FAIL'}`);
  process.exit(result.pass ? 0 : 1);
}

main().catch((e) => {
  console.error('Validator error:', e);
  process.exit(2);
});
