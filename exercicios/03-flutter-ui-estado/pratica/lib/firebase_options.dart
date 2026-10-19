// lib/firebase_options.dart — config do app WEB do projeto Firebase `filmes-flutter-a3`
// (criado pelo console — "Plano B" do enunciado, equivalente ao `flutterfire configure`).
//
// Não é segredo: a apiKey do Firebase web só IDENTIFICA o projeto; quem protege os dados são as
// regras do Firestore. O enunciado permite commitar este arquivo (projeto pessoal, plano Spark).
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: 'AIzaSyCxnfONT81aAUBvR9ZsA60Hv7HQu6AYctU',
    appId: '1:367908232480:web:69bfb436fd8c765b344b45',
    messagingSenderId: '367908232480',
    projectId: 'filmes-flutter-a3',
    authDomain: 'filmes-flutter-a3.firebaseapp.com',
    storageBucket: 'filmes-flutter-a3.firebasestorage.app',
    measurementId: 'G-5ZEY49XMTP',
  );
}
