import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<bool> isBiometricAvailable() async {
    try {
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate = await _localAuth.isDeviceSupported();
      return canAuthenticateWithBiometrics && canAuthenticate;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access CareHub',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> saveCredentials(String email, String password) async {
    await _secureStorage.write(key: 'email', value: email);
    await _secureStorage.write(key: 'password', value: password);
  }

  Future<Map<String, String?>> getCredentials() async {
    final email = await _secureStorage.read(key: 'email');
    final password = await _secureStorage.read(key: 'password');
    return {'email': email, 'password': password};
  }

  Future<void> deleteCredentials() async {
    await _secureStorage.delete(key: 'email');
    await _secureStorage.delete(key: 'password');
  }

  Future<bool> hasStoredCredentials() async {
    final credentials = await getCredentials();
    return credentials['email'] != null && credentials['password'] != null;
  }
}
