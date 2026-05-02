import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'user_date_time.dart';

part 'user_ban_status.g.dart';

@JsonSerializable(explicitToJson: true)
class UserBanStatus extends Equatable {
  final bool isBanned;
  final UserDateTime suspendedUntil;
  final String? suspensionReason;

  const UserBanStatus({
    this.isBanned = false,
    required this.suspendedUntil,
    this.suspensionReason,
  });

  static final guest = UserBanStatus(
    suspendedUntil: UserDateTime.guest,
  );

  bool get isGuest => this == guest;

  bool get isActiveBan =>
      isBanned &&
      (suspendedUntil.isGuest ||
          suspendedUntil.value.isAfter(DateTime.now()));

  @override
  List<Object?> get props => [isBanned, suspendedUntil, suspensionReason];

  factory UserBanStatus.fromJson(Map<String, dynamic> json) => _$UserBanStatusFromJson(json);

  Map<String, dynamic> toJson() => _$UserBanStatusToJson(this);
}
