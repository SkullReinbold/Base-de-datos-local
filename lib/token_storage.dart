import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  static const _key = 'jwt_token';

  static Future<void> guardar(String token) =>
      _storage.write(key: _key, value: token);

  static Future<String?> leer() => _storage.read(key: _key);

  static Future<void> borrar() => _storage.delete(key: _key);
}