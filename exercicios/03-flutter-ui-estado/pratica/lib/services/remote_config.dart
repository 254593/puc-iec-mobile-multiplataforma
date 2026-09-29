// lib/services/remote_config.dart
//
// Ex5 (TASK 8): busca o parâmetro `banner_message` do Firebase Remote Config.
//
// Pré-requisito: TASK 3 feito (projeto Firebase configurado) + parâmetro
// `banner_message` criado no console (Build → Remote Config).

// TODO [TASK 8]: descomente o import abaixo
// import 'package:firebase_remote_config/firebase_remote_config.dart';

const _defaultBannerMessage = 'Bem-vindo ao app de filmes!';

// ── Ex5 · TASK 8 — implemente fetchBannerMessage() · 🧑‍💻 EM CASA (sozinho) ──────────────────────
// Modelo:
//
//   Future<String> fetchBannerMessage() async {
//     final remoteConfig = FirebaseRemoteConfig.instance;
//     await remoteConfig.setConfigSettings(RemoteConfigSettings(
//       fetchTimeout: const Duration(seconds: 10),
//       minimumFetchInterval: Duration.zero, // sem cache — sempre busca de novo (didático)
//     ));
//     remoteConfig.setDefaults({'banner_message': _defaultBannerMessage});
//     await remoteConfig.fetchAndActivate();
//     return remoteConfig.getString('banner_message');
//   }
//
// 👉 Teste você mesmo: muda o valor de `banner_message` no console do Firebase,
// dá refresh no app (F5) — o texto muda sem recompilar nada.

// 👇 Apague o stub abaixo e implemente a função acima.
Future<String> fetchBannerMessage() async => _defaultBannerMessage;
