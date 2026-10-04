# Atividade 3 — App Flutter: UI + Estado + Firebase + Offline-first

Catálogo de filmes em **Flutter**: você compõe a UI (`MovieCard`), gerencia **estado compartilhado com Riverpod**, persiste na nuvem com **Firebase** (Firestore + Remote Config) e faz o app funcionar **sem internet** (cache, TTL e fila de sincronização). Começa em aula e termina neste projeto.

- 📄 **[enunciado.md](enunciado.md)** — objetivos, exercícios, tempo estimado e rubrica (15 pts)
- 🪜 **[guia-passo-a-passo.md](guia-passo-a-passo.md)** — as TASKs passo a passo (mesma numeração do enunciado)
- 📁 **[pratica/](pratica/)** — o projeto Flutter (já roda; complete os scaffolds)

## Em 1 minuto
```bash
cd exercicios/03-flutter-ui-estado/pratica
ls lib                              # prova de que você está no lugar certo (dir lib no Windows)
flutter pub get
flutter run -d chrome               # app abre (lista de filmes) — sem emulador
flutter test                        # começa VERMELHO — deixe tudo verde
flutter test test/offline_test.dart # só as TASKs de offline-first (11–15)
```

**Entrega:** fork + PR (prazo: **ver Canvas**). O J.A.R.V.I.S. comenta uma **nota mínima** estrutural no PR; **o `flutter test` é você quem roda**.

> Bridging nativo (Platform Channel / KMP) é a **Aula 4/5** — aqui o foco é **UI + estado + nuvem + offline**.
