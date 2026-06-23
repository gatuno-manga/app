import 'package:json_annotation/json_annotation.dart';

part 'create_book_request_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class CreateBookRequestDto {
  final String title;
  final String url;
  final String? reason;

  CreateBookRequestDto({
    required this.title,
    required this.url,
    this.reason,
  });

  factory CreateBookRequestDto.fromJson(Map<String, dynamic> json) => 
      _$CreateBookRequestDtoFromJson(json);
      
  Map<String, dynamic> toJson() => _$CreateBookRequestDtoToJson(this);
}
