class PostCommentModel {
  PostCommentModel(
      {required this.toId,
      required this.message,
      required this.fromId,
      required this.sent,
      required this.userName,
      required this.commentsLikes,
      required this.isReply,
      required this.userImage});
  late String toId;
  late String message;
  late String fromId;
  late String userImage;
  late String userName;
  late String sent;
  late List commentsLikes;
  late bool isReply;

  PostCommentModel.fromJson(Map<String, dynamic> json) {
    toId = json['toId'].toString();
    message = json['message'].toString();
    fromId = json['fromId'].toString();
    sent = json['sent'].toString();
    userImage = json['userImage'].toString();
    userName = json['userName'].toString();
    commentsLikes = json['commentsLikes'];
    isReply = json['isReply'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toId'] = toId;
    data['message'] = message;
    data['fromId'] = fromId;
    data['sent'] = sent;
    data['userImage'] = userImage;
    data['userName'] = userName;
    data['commentsLikes'] = commentsLikes;
    data['isReply'] = isReply;
    return data;
  }
}
