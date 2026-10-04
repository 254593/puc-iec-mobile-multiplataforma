// lib/data/key_value_store.dart — PRONTO (não precisa mexer).
//
// Um "armário" de chave → texto. O app guarda aqui o cache da lista e a fila de sincronização.
// Em produção usa SharedPreferences (no navegador vira localStorage e sobrevive ao F5);
// nos testes usa InMemoryStore (rápido e sem plugin).
import 'package:shared_preferences/shared_preferences.dart';

abstract class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> remove(String key);
}

class InMemoryStore implements KeyValueStore {
  final Map<String, String> _data = {};
  @override
  Future<String?> read(String key) async => _data[key];
  @override
  Future<void> write(String key, String value) async => _data[key] = value;
  @override
  Future<void> remove(String key) async => _data.remove(key);
}

class SharedPrefsStore implements KeyValueStore {
  final SharedPreferences _prefs;
  SharedPrefsStore(this._prefs);
  @override
  Future<String?> read(String key) async => _prefs.getString(key);
  @override
  Future<void> write(String key, String value) => _prefs.setString(key, value);
  @override
  Future<void> remove(String key) => _prefs.remove(key);
}
