/// Result of asking the employee to verify their identity before showing the payslips (MA-64).
enum IdentityVerification {
  /// The employee was verified.
  verified,

  /// The employee cancelled or the check did not match.
  failed,

  /// The device has no biometrics set up; the password must be used.
  unavailable,
}

/// Port to verify the identity of the employee with the biometrics or the lock of the device.
///
/// The payslips stay unlocked until the app is closed, so the check is asked only once.
abstract class IdentityVerifier {
  /// True when the payslips were already unlocked in this session of the app.
  bool get isUnlocked;

  /// Asks for the fingerprint or face; with [allowDeviceCredential] the PIN or password of the device
  /// is accepted too ("Usar contraseña").
  Future<IdentityVerification> verify({required bool allowDeviceCredential});
}
