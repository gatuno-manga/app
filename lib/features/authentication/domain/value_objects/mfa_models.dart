class MfaStatus {
  final bool totpEnabled;
  final int backupCodesRemaining;

  const MfaStatus({
    required this.totpEnabled,
    required this.backupCodesRemaining,
  });

  factory MfaStatus.fromJson(Map<String, dynamic> json) {
    final enabled = json['totpEnabled'];
    final remaining = json['backupCodesRemaining'];
    if (enabled is! bool || remaining is! num) {
      throw const FormatException('Invalid MFA status response');
    }
    return MfaStatus(
      totpEnabled: enabled,
      backupCodesRemaining: remaining.toInt(),
    );
  }
}

class TotpSetup {
  final String secret;
  final String otpauthUri;

  const TotpSetup({required this.secret, required this.otpauthUri});

  factory TotpSetup.fromJson(Map<String, dynamic> json) {
    final secret = json['secret'];
    final uri = json['otpauthUri'];
    if (secret is! String || uri is! String) {
      throw const FormatException('Invalid TOTP setup response');
    }
    return TotpSetup(secret: secret, otpauthUri: uri);
  }
}

/// Plaintext backup codes. Returned by the backend exactly once and never
/// persisted or logged by the app.
class BackupCodes {
  final List<String> codes;

  const BackupCodes(this.codes);

  factory BackupCodes.fromJson(Map<String, dynamic> json) {
    final raw = json['backupCodes'];
    if (raw is! List || !raw.every((e) => e is String)) {
      throw const FormatException('Invalid backup codes response');
    }
    return BackupCodes(List<String>.unmodifiable(raw));
  }

  @override
  String toString() => 'BackupCodes(${codes.length})';
}
