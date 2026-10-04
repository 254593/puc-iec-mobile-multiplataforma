# Grader — Arquitetura Mobile Multiplataforma (autograder CI)

Auto-correção das atividades práticas via GitHub Actions. Aluno faz **fork → commit → PR**; a cada commit o bot (J.A.R.V.I.S.) **descobre a pasta da entrega**, roda o validator, e **comenta no PR** uma **nota mínima** + o porquê. A nota **final** é lançada pelo prof **no Canvas**.

## Atividades cobertas

| # | Atividade | Validator | Status |
|---|-----------|-----------|--------|
| A2 | App RN: Favoritos + MMKV + Reanimated | `rn-app.ts` | **calibrado (rubrica real)** |
| A3 | App Flutter: UI + Estado + Firebase + Offline-first | `flutter-ui-estado.ts` | **calibrado (rubrica real: 12 auto + 3 manual)** |
| A4 | PWA offline-first | `pwa-lighthouse.ts` | a calibrar |
| A5 | GraphQL + Auth | `graphql-auth.ts` | a calibrar |

> "a calibrar" = workflow já tem trigger + discover robusto; o validator ainda precisa bater com a rubrica real do `enunciado.md` antes de virar gate.

## Como funciona

1. Aluno faz fork e implementa **em qualquer path** sob `exercicios/<NN>-<atividade>/` (`aluno-<login>/`, `<nome>/`, `starter/` in-place… o discover acha).
2. Abre PR pra `main` do upstream.
3. `grade-atividade-NN.yml` dispara em **`pull_request_target`** (fork roda + bot comenta) **a cada commit**.
4. **Discover** acha a entrega pelos arquivos mudados (dir do `package.json` → subpasta mais mudada → raiz).
5. Validator (leitura **estática**, sem `npm install` da entrega) gera `grade.json`.
6. Bot comenta: **nota MÍNIMA automática** (piso) + breakdown ✅/⚠️/❌ por critério com o motivo + itens `📝` de avaliação manual.
7. `grade.json` completo sobe como **artifact privado** (só prof — tem `privateNote`).
8. Status check pass/fail (≥ 60%). Merge: prof revisa + aprova.

## Nota mínima (piso), não final

O bot só pontua o **auto-verificável** (estrutural). Critérios subjetivos — qualidade de README, screenshot, screencast, referência, profundidade — são marcados **`manual: true`** no validator: aparecem no breakdown como `📝 avaliação manual (Canvas)` mas **não entram no número**. Assim `autoScore ≤ nota manual` sempre, e a final no Canvas **só sobe** a partir do piso.

Helpers em `lib/compute-score.ts`: `computeScore` (rubrica cheia) · `computeAuto` (piso, ignora `manual`) · `buildBreakdowns` (markdown público/privado) · `passThreshold`.

## Estrutura

```
grader/
├── package.json
├── tsconfig.json
├── lib/
│   ├── compute-score.ts            # tipos + helpers (rubrica → score, piso auto/manual)
│   └── validators/
│       ├── rn-app.ts               # A2 (calibrado)
│       ├── native-module.ts        # A3
│       ├── pwa-lighthouse.ts       # A4
│       └── graphql-auth.ts         # A5
└── README.md
```

## Rodar localmente (smoke test do prof)

```bash
cd grader && npm install

# 1 entrega real (qualquer path) — aponte --entrega pra pasta descoberta
npx tsx lib/validators/rn-app.ts \
  --entrega ../exercicios/02-app-rn-navegacao-estado/aluno-fulano \
  --output /tmp/grade.json --student-login fulano --commit-sha local

# validar contra PRs reais: gh pr checkout <n> num clone separado e rode o validator,
# conferindo autoScore <= nota manual (piso) e que o discover acerta a pasta.
```

## Adicionar/calibrar um validator

1. `lib/validators/<tipo>.ts` com `main()` que escreve `grade.json` (use `computeAuto` p/ o piso).
2. Critérios = pontos do `enunciado.md`; marque os subjetivos com `manual: true`.
3. Workflow `grade-atividade-NN.yml`: só mude os `env` `EXERCISE`/`VALIDATOR`/`ATIVIDADE` (corpo é igual).
4. Valide: `autoScore ≤ nota manual` nas entregas reais · entrega vazia → FAIL · `tsc --noEmit` limpo.

## Privacidade

- **Comentário público**: nota mínima + status + breakdown público (`publicNote`).
- **Artifact privado** (`grade.json`): breakdown completo + `privateNote`; só prof baixa.
- **Nota final**: só no Canvas (boletim interno em `turmas/notas/`, nunca público).

## Autoria

Material didático autoral. © 2026 Jackson Smith Moisés Matias.
