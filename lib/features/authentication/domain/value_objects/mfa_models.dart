class MfaStatus {
  final bool totpEnabled;
  final int backupCodesRemaining;

  const MfaStatus({
    required this.totpEnabled,
    required this.backupCodesRemaining,
  });

  factory MfaStatus.fromJson(Map<String, dynamic> json) => MfaStatus(
    totpEnabled: json['totpEnabled'] == true,
    backupCodesRemaining: (json['backupCodesRemaining'] as num?)?.toInt() ?? 0,
  );
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
    if (raw is! List) {
      throw const FormatException('Invalid backup codes response');
    }
    return BackupCodes(raw.map((e) => e.toString()).toList(growable: false));
  }

  @override
  String toString() => 'BackupCodes(${codes.length})';
}
