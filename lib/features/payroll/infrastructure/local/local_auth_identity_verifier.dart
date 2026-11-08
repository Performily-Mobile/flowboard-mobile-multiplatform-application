import 'package:local_auth/local_auth.dart';
import 'package:flowboard/features/payroll/domain/repository/identity_verifier.dart';

/// Verifies the employee with Face ID / Touch ID / fingerprint, or the lock of the device, through
/// `local_auth` (MA-64, MA-06 of the user flow UF-03).
class LocalAuthIdentityVerifier implements IdentityVerifier {
  /// Creates the verifier.
  LocalAuthIdentityVerifier({LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;
  bool _unlocked = false;

  static const String _reason = 'Verifica tu identidad para ver tu remuneración y descargar tus boletas.';

  @override
  bool get isUnlocked => _unlocked;

  @override
  Future<IdentityVerification> verify({required bool allowDeviceCredential}) async {
    try {
      if (!await _auth.isDeviceSupported()) return IdentityVerification.unavailable;
      if (!allowDeviceCredential && !await _auth.canCheckBiometrics) return IdentityVerification.unavailable;
      final bool verified = await _auth.authenticate(
        localizedReason: _reason,
        biometricOnly: !allowDeviceCredential,
      );
      _unlocked = verified;
      return verified ? IdentityVerification.verified : IdentityVerification.failed;
    } catch (_) {
      // Cancelled, locked out or not set up: the screen offers to retry or to use the password.
      return IdentityVerification.failed;
    }
  }
}
