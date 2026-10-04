// lib/main.dart — ponto de entrada do app.
//
// ProviderScope = a "raiz" do Riverpod (deixa qualquer widget ler providers).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/key_value_store.dart';
import 'state/movies_provider.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

// TODO [TASK 3 + TASK 7]: descomente depois de rodar `flutterfire configure`
// (gera lib/firebase_options.dart — ver "Setup Firebase" no enunciado)
//
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // necessário p/ SharedPreferences (e p/ o Firebase)
  final prefs = await SharedPreferences.getInstance(); // o "armário" que sobrevive ao F5

  // TODO [TASK 3 + TASK 7]: descomente a linha abaixo
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // TODO [TASK 10 · 🧑‍🏫 EM AULA · fácil]: ligue a persistência OFFLINE do Firestore (logo depois do initializeApp):
  //   FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  // (precisa de: import 'package:cloud_firestore/cloud_firestore.dart';)
  // Efeito: escritas feitas sem rede ficam numa fila local do Firestore e sincronizam sozinhas na volta.

  runApp(ProviderScope(
    overrides: [storeProvider.overrideWithValue(SharedPrefsStore(prefs))],
    child: const MovieApp(),
  ));
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filmes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(), // tema pronto (dark premium) — você não precisa mexer
      home: const HomeScreen(),
    );
  }
}
