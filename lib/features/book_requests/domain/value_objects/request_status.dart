import 'package:json_annotation/json_annotation.dart';

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum RequestStatus {
  pending,
  approved,
  rejected;
}
