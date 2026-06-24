import 'package:json_annotation/json_annotation.dart';
import '../../domain/value_objects/request_title.dart';
import '../../domain/value_objects/request_url.dart';
import '../../domain/value_objects/request_reason.dart';

part 'create_book_request_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class CreateBookRequestDto {
  final RequestTitle title;
  final RequestUrl url;
  final RequestReason? reason;

  CreateBookRequestDto({
    required this.title,
    required this.url,
    this.reason,
  });

  factory CreateBookRequestDto.fromJson(Map<String, dynamic> json) => 
      _$CreateBookRequestDtoFromJson(json);
      
  Map<String, dynamic> toJson() => _$CreateBookRequestDtoToJson(this);
}
