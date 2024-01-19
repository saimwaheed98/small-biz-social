class MessageModel {
  MessageModel({
    required this.toId,
    required this.read,
    required this.type,
    required this.message,
    required this.fromId,
    required this.sent,
    required this.senderName,
    required this.receiverName,
  });
  late String toId;
  late String read;
  late Type type;
  late String message;
  late String fromId;
  late String sent;
  late String senderName;
  late String receiverName;

  MessageModel.fromJson(Map<String, dynamic> json) {
    toId = json['toId'].toString();
    read = json['read'].toString();
    type = json['type'].toString() == 'image'
        ? Type.image
        : json['type'].toString() == 'video'
            ? Type.video
            : json['type'].toString() == 'voice'
                ? Type.voice
                : Type.text;
    message = json['message'].toString();
    fromId = json['fromId'].toString();
    sent = json['sent'].toString();
    senderName = json['senderName'].toString();
    receiverName = json['receiverName'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toId'] = toId;
    data['read'] = read;
    data['type'] = type.name;
    data['message'] = message;
    data['fromId'] = fromId;
    data['sent'] = sent;
    data['senderName'] = senderName;
    data['receiverName'] = receiverName;
    return data;
  }
}

enum Type { text, image, video, voice }
