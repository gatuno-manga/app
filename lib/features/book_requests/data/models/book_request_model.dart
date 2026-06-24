import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/book_request_entity.dart';
import 'package:gatuno/shared/domain/value_objects/timestamp.dart';

part 'book_request_model.g.dart';

@JsonSerializable(explicitToJson: true)
class BookRequestModel {
  final String id;
  final String userId;
  final String title;
  final String url;
  final String? reason;
  final String status;
  final String? adminId;
  final String? rejectionMessage;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  BookRequestModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.url,
    this.reason,
    required this.status,
    this.adminId,
    this.rejectionMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookRequestModel.fromJson(Map<String, dynamic> json) => 
      _$BookRequestModelFromJson(json);
      
  Map<String, dynamic> toJson() => _$BookRequestModelToJson(this);

  BookRequestEntity toEntity() {
    return BookRequestEntity(
      id: RequestIdVO(id),
      userId: userId,
      title: RequestTitleVO(title),
      url: RequestUrlVO(url),
      reason: RequestReasonVO(reason),
      status: RequestStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == status.toLowerCase(),
        orElse: () => RequestStatus.pending,
      ),
      adminId: adminId,
      rejectionMessage: RequestRejectionMessageVO(rejectionMessage),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
