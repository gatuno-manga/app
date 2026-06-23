import 'package:equatable/equatable.dart';

class RequestIdVO extends Equatable {
  final String value;
  const RequestIdVO._(this.value);
  
  factory RequestIdVO(String input) {
    if (input.trim().isEmpty) throw ArgumentError('Request ID cannot be empty');
    return RequestIdVO._(input.trim());
  }
  
  @override
  List<Object?> get props => [value];
}

class RequestTitleVO extends Equatable {
  final String value;
  const RequestTitleVO._(this.value);
  
  factory RequestTitleVO(String input) {
    if (input.trim().isEmpty) throw ArgumentError('Title cannot be empty');
    return RequestTitleVO._(input.trim());
  }
  
  @override
  List<Object?> get props => [value];
}

class RequestUrlVO extends Equatable {
  final String value;
  const RequestUrlVO._(this.value);
  
  factory RequestUrlVO(String input) {
    if (input.trim().isEmpty) throw ArgumentError('URL cannot be empty');
    return RequestUrlVO._(input.trim());
  }
  
  @override
  List<Object?> get props => [value];
}

class RequestReasonVO extends Equatable {
  final String? value;
  const RequestReasonVO(this.value);
  
  @override
  List<Object?> get props => [value];
}

class RequestRejectionMessageVO extends Equatable {
  final String? value;
  const RequestRejectionMessageVO(this.value);
  
  @override
  List<Object?> get props => [value];
}

enum RequestStatus {
  pending,
  approved,
  rejected,
}

class BookRequestEntity extends Equatable {
  final RequestIdVO id;
  final String userId;
  final RequestTitleVO title;
  final RequestUrlVO url;
  final RequestReasonVO reason;
  final RequestStatus status;
  final String? adminId;
  final RequestRejectionMessageVO rejectionMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

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
