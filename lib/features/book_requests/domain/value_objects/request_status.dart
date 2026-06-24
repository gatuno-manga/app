enum RequestStatus {
  pending,
  approved,
  rejected;

  String toJson() => name;
  static RequestStatus fromJson(String json) => RequestStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == json.toLowerCase(),
        orElse: () => RequestStatus.pending,
      );
}
