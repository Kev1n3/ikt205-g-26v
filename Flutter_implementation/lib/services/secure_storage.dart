import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecureSupabaseStorage extends LocalStorage {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  Future<String?> accessToken() async {
    return null;
  }

  @override
  Future<bool> hasAccessToken() async {
    return false;
  }

  @override
  Future<void> initialize() async {
  }

  @override
  Future<String?> read(String key) async {
    return await _secureStorage.read(key: key);
  }

  @override
  Future<void> write(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  @override
  Future<void> remove(String key) async {
    await _secureStorage.delete(key: key);
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _secureStorage.write(
      key: 'supabase.auth.session',
      value: persistSessionString,
    );
  }

  @override
  Future<void> removePersistedSession() async {
    await _secureStorage.delete(key: 'supabase.auth.session');
  }
}