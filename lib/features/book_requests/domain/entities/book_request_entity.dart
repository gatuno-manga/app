import 'package:equatable/equatable.dart';
import 'package:gatuno/shared/domain/value_objects/timestamp.dart';
import 'package:gatuno/features/users/domain/value_objects/user_id.dart';

import '../value_objects/request_id.dart';
import '../value_objects/request_title.dart';
import '../value_objects/request_url.dart';
import '../value_objects/request_reason.dart';
import '../value_objects/request_status.dart';
import '../value_objects/request_rejection_message.dart';

class BookRequestEntity extends Equatable {
  final RequestId id;
  final UserId userId;
  final RequestTitle title;
  final RequestUrl url;
  final RequestReason reason;
  final RequestStatus status;
  final UserId? adminId;
  final RequestRejectionMessage rejectionMessage;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const BookRequestEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.url,
    required this.reason,
    required this.status,
    this.adminId,
    required this.rejectionMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, userId, title, url, reason, status, adminId, rejectionMessage, createdAt, updatedAt];
}
