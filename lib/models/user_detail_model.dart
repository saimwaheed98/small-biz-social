class UserDetail {
  UserDetail({
    required this.firstName,
    required this.profilePicture,
    required this.uid,
    required this.lastName,
    required this.createdAt,
    required this.subscription,
    required this.pushToken,
    required this.email,
    required this.bio,
    required this.isOnline,
    required this.lastActive,
  });
  late String firstName;
  late String profilePicture;
  late String uid;
  late String lastName;
  late String createdAt;
  late bool subscription;
  late String pushToken;
  late String email;
  late String bio;
  late bool isOnline;
  late String lastActive;

  UserDetail.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'] ?? "";
    profilePicture = json['profilePicture'] ?? "";
    uid = json['uid'] ?? "";
    lastName = json['lastName'] ?? "";
    createdAt = json['createdAt'] ?? "";
    subscription = json['subscription'] ?? false;
    pushToken = json['pushToken'] ?? "";
    email = json['email'] ?? "";
    bio = json['bio'] ?? "";
    isOnline = json['isOnline'] ?? false;
    lastActive = json['lastActive'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['firstName'] = firstName;
    data['profilePicture'] = profilePicture;
    data['uid'] = uid;
    data['lastName'] = lastName;
    data['createdAt'] = createdAt;
    data['subscription'] = subscription;
    data['pushToken'] = pushToken;
    data['email'] = email;
    data['bio'] = bio;
    data['isOnline'] = isOnline;
    data['lastActive'] = lastActive;
    return data;
  }
}
