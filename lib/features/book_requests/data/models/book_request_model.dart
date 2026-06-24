import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/book_request_entity.dart';
import 'package:gatuno/shared/domain/value_objects/timestamp.dart';
import 'package:gatuno/features/users/domain/value_objects/user_id.dart';

import '../../domain/value_objects/request_id.dart';
import '../../domain/value_objects/request_title.dart';
import '../../domain/value_objects/request_url.dart';
import '../../domain/value_objects/request_reason.dart';
import '../../domain/value_objects/request_status.dart';
import '../../domain/value_objects/request_rejection_message.dart';

part 'book_request_model.g.dart';

@JsonSerializable(explicitToJson: true)
class BookRequestModel extends BookRequestEntity {
  const BookRequestModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.url,
    required super.reason,
    required super.status,
    super.adminId,
    required super.rejectionMessage,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BookRequestModel.fromJson(Map<String, dynamic> json) => 
      _$BookRequestModelFromJson(json);
      
  Map<String, dynamic> toJson() => _$BookRequestModelToJson(this);

  BookRequestEntity toEntity() => this;
}
