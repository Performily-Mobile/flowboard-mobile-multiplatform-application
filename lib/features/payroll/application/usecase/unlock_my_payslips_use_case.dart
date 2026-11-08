import 'package:flowboard/features/payroll/domain/repository/identity_verifier.dart';

/// Unlocks the payslips of the employee after verifying their identity (MA-64, US41).
class UnlockMyPayslipsUseCase {
  /// Creates the use case.
  const UnlockMyPayslipsUseCase({required this.verifier});

  final IdentityVerifier verifier;

  /// True when the payslips were already unlocked in this session.
  bool get isUnlocked => verifier.isUnlocked;

  /// Verifies with biometrics, or with the device password when [withPassword] is true.
  Future<IdentityVerification> execute({required bool withPassword}) =>
      verifier.verify(allowDeviceCredential: withPassword);
}
