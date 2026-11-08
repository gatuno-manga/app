import '../value_objects/mfa_models.dart';

abstract class MfaRepository {
  Future<MfaStatus> status();
  Future<TotpSetup> setupTotp();
  Future<BackupCodes> verifyTotpSetup(String code);
  Future<void> disableTotp(String code);
}
