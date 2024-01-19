class BussinessModel {
  BussinessModel({
    required this.firstName,
    required this.uid,
    required this.lastName,
    required this.createdAt,
    required this.bussinessName,
    required this.businessLink,
    required this.einNumber,
  });
  late String firstName;
  late String uid;
  late String lastName;
  late String createdAt;
  late String bussinessName;
  late String businessLink;
  late String einNumber;

  BussinessModel.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'] ?? "";
    uid = json['uid'] ?? "";
    lastName = json['lastName'] ?? "";
    createdAt = json['createdAt'] ?? "";
    businessLink = json['businessLink'] ?? "";
    bussinessName = json['bussinessName'] ?? "";
    einNumber = json['einNumber'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['firstName'] = firstName;
    data['businessLink'] = businessLink;
    data['uid'] = uid;
    data['lastName'] = lastName;
    data['createdAt'] = createdAt;
    data['bussinessName'] = bussinessName;
    data['einNumber'] = einNumber;
    return data;
  }
}
