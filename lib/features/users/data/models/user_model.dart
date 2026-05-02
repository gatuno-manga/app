import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/user_email.dart';
import '../../domain/value_objects/user_name.dart';
import '../../domain/value_objects/user_display_name.dart';
import '../../domain/value_objects/user_roles.dart';
import '../../domain/value_objects/sensitive_content_weight.dart';
import '../../domain/value_objects/user_image.dart';
import '../../domain/value_objects/user_ban_status.dart';
import '../../domain/value_objects/user_date_time.dart';

class UserModel {
  final UserId id;
  final UserEmail email;
  final UserRoles roles;
  final SensitiveContentWeight maxWeightSensitiveContent;

  final UserName? userName;
  final UserDisplayName? name;
  final UserImage? profilePicture;
  final UserImage? profileBanner;
  final UserBanStatus? banStatus;
  final UserDateTime? createdAt;
  final UserDateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.roles,
    required this.maxWeightSensitiveContent,
    this.userName,
    this.name,
    this.profilePicture,
    this.profileBanner,
    this.banStatus,
    this.createdAt,
    this.updatedAt,
  });

  static final guest = UserModel(
    id: UserId.guest,
    email: UserEmail.guest,
    roles: UserRoles.guest,
    maxWeightSensitiveContent: SensitiveContentWeight.guest,
    userName: UserName.guest,
    name: UserDisplayName.guest,
    profilePicture: UserImage.guest,
    profileBanner: UserImage.guest,
    banStatus: UserBanStatus.guest,
    createdAt: UserDateTime.guest,
    updatedAt: UserDateTime.guest,
  );

  bool get isGuest => id.isGuest;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Mapping flattened image fields from /me response
    final profilePicture = json['profileImagePath'] != null 
      ? UserImage(
          path: json['profileImagePath'] as String,
          metadata: json['profileImageMetadata'] as Map<String, dynamic>?,
        )
      : null;
    
    final profileBanner = json['profileBannerPath'] != null
      ? UserImage(
          path: json['profileBannerPath'] as String,
          metadata: json['profileBannerMetadata'] as Map<String, dynamic>?,
        )
      : null;

    final banStatus = json['isBanned'] != null
      ? UserBanStatus(
          isBanned: json['isBanned'] as bool? ?? false,
          suspendedUntil: json['suspendedUntil'] != null 
            ? UserDateTime.fromJson(json['suspendedUntil'] as String)
            : UserDateTime.guest,
          suspensionReason: json['suspensionReason'] as String?,
        )
      : null;

    return UserModel(
      id: UserId.fromJson(json['sub'] as String? ?? json['id'] as String? ?? ''),
      email: UserEmail.fromJson(json['email'] as String?),
      roles: UserRoles.fromJson(json['roles'] as List<dynamic>?),
      maxWeightSensitiveContent: SensitiveContentWeight.fromJson(json['maxWeightSensitiveContent'] as int?),
      userName: json['username'] != null || json['userName'] != null
        ? UserName.fromJson(json['username'] as String? ?? json['userName'] as String?)
        : null,
      name: json['name'] != null ? UserDisplayName.fromJson(json['name'] as String?) : null,
      profilePicture: profilePicture,
      profileBanner: profileBanner,
      banStatus: banStatus,
      createdAt: json['createdAt'] != null ? UserDateTime.fromJson(json['createdAt'] as String?) : null,
      updatedAt: json['updatedAt'] != null ? UserDateTime.fromJson(json['updatedAt'] as String?) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id.toJson(),
    'email': email.toJson(),
    'roles': roles.toJson(),
    'maxWeightSensitiveContent': maxWeightSensitiveContent.toJson(),
    'username': userName?.toJson(),
    'name': name?.toJson(),
    'profilePicture': profilePicture?.toJson(),
    'profileBanner': profileBanner?.toJson(),
    'banStatus': banStatus?.toJson(),
    'createdAt': createdAt?.toJson(),
    'updatedAt': updatedAt?.toJson(),
  };
factory UserModel.fromJwt(Map<String, dynamic> payload) {
  final sub = payload['sub'] as String? ?? '';
  final email = payload['email'] as String? ?? '';
  final roles = payload['roles'] as List<dynamic>?;

  if (sub.isEmpty || email.isEmpty || roles == null) {
    throw const FormatException(
      'Invalid JWT payload: missing required fields or empty values (sub, email, or roles)',
    );
  }

  final maxWeight = payload['maxWeightSensitiveContent'] as int? ?? 0;

  return UserModel(
    id: UserId(sub),
    email: UserEmail(email),
    roles: UserRoles.fromJson(roles),
    maxWeightSensitiveContent: SensitiveContentWeight(maxWeight),
    userName: payload['username'] != null ? UserName.fromJson(payload['username'] as String) : null,
    name: payload['name'] != null ? UserDisplayName.fromJson(payload['name'] as String) : null,
    profilePicture: null,
    profileBanner: null,
    banStatus: null,
    createdAt: null,
    updatedAt: null,
  );
}


  String get displayName => name?.value ?? userName?.value ?? email.value.split('@')[0];
}
