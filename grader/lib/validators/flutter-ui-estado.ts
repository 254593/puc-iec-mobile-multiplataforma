/**
 * Validator — Atividade 3 — App Flutter: UI + Estado + Firebase (Arquitetura).
 *
 * RUBRICA REAL do enunciado (15 pts):
 *  1. App compila/roda + `flutter analyze` limpo               — 2pts [MANUAL · eliminatório]
 *  2. Ex1 · MovieCard compõe título + nota (⭐) + ano           — 2pts
 *  3. Ex2 · favoritar (local) reflete no card + contador + limpar — 2pts
 *  4. Ex4 · Firestore — favoritos persistem após reload        — 4pts
 *  5. Ex5 · Remote Config — banner busca valor remoto          — 2pts
 *  6. Ex3 · teste autoral do provider local (favorites_test)   — 2pts
 *  7. README + parágrafo (local vs cloud)                      — 1pt  [MANUAL]
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
    weight: 2,
    earned: bits >= 6 ? 2 : bits >= 4 ? 1.5 : bits >= 2 ? 1 : 0,
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
    weight: 2,
    earned: Math.round((ex2Signals / 4) * 2 * 100) / 100,
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
    weight: 4,
    earned: Math.round((firestoreSignals / 4) * 4 * 100) / 100,
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
    weight: 2,
    earned: Math.round((rcSignals / 4) * 2 * 100) / 100,
    publicNote: `import=${rcImport} · fetchAndActivate=${rcFetch} · getString=${rcGet} · usado no HomeScreen=${rcUsedInHome}`,
  });

  // ---- 6. Ex3 — teste autoral do provider local (2) ----
  const hasTest = /\btest\s*\(/.test(favTest);
  const usesProvider = /favoritesProvider/.test(favTest);
  criteria.push({
    id: 'ex3-teste',
    description: 'Ex3 · teste autoral do provider local (test/favorites_test.dart)',
    weight: 2,
    earned: hasTest && usesProvider ? 2 : hasTest || usesProvider ? 1 : 0,
    publicNote:
      hasTest && usesProvider
        ? 'teste do provider escrito (test() usando favoritesProvider)'
        : 'favorites_test.dart sem um test() de verdade usando favoritesProvider',
  });

  // ---- 7. README + parágrafo — MANUAL ----
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
