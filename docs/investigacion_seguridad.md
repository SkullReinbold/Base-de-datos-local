# Almacenamiento seguro de tokens JWT

## Por qué no SharedPreferences / UserDefaults
Guardan los datos en texto plano. Un dispositivo con root/jailbreak o un
respaldo del sistema puede exponerlos.

## Flutter: flutter_secure_storage
Wrapper que usa el almacenamiento seguro nativo de cada plataforma:
Keystore/EncryptedSharedPreferences en Android y Keychain en iOS.

## Android: EncryptedSharedPreferences
Cifra las claves con AES-256-SIV y los valores con AES-256-GCM. La llave
maestra se guarda en el Android Keystore, respaldado por hardware cuando
el dispositivo lo permite.

## iOS: Keychain Services
Almacén cifrado del sistema, aislado por aplicación. El atributo
kSecAttrAccessibleAfterFirstUnlock permite leer el dato después del primer
desbloqueo del dispositivo, útil para tareas en segundo plano.

## Buenas prácticas
- Nunca guardar el token en código fuente ni en logs.
- Borrar el token al cerrar sesión.
- Usar tokens de vida corta y renovarlos con un refresh token.