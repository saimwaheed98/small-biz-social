class NotificationModel {
  String senderId;
  String receiverId;
  String message;
  String title;
  bool isFriend;
  String senderImage;
  String sentAt;

  NotificationModel(
      {required this.senderId,
      required this.receiverId,
      required this.message,
      required this.title,
      required this.isFriend,
      required this.sentAt,
      required this.senderImage});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
        senderId: json['senderId'],
        receiverId: json['receiverId'],
        message: json['message'],
        title: json['title'],
        isFriend: json['isFriend'],
        sentAt: json['sentAt'],
        senderImage: json['senderImage']);

  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'title': title,
      'isFriend': isFriend,
      'senderImage': senderImage,
      'sentAt': sentAt

    };
  }
}
