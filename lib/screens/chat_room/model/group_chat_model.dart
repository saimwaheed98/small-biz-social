class GroupChatModel {
  GroupChatModel({
    required this.roomImage,
    required this.publishDate,
    required this.groupName,
    required this.groupId,
    required this.groupDescription,
    required this.groupAdmin,
    required this.groupMembers,
    required this.groupAdminName,
    required this.groupAdminImage,
  });
  late String roomImage;
  late int publishDate;
  late String groupName;
  late String groupId;
  late String groupDescription;
  late String groupAdmin;
  late List groupMembers;
  late String groupAdminName;
  late String groupAdminImage;

  GroupChatModel.fromJson(Map<String, dynamic> json) {
    roomImage = json['roomImage'].toString();
    publishDate = json['publishDate'];
    groupName = json['groupName'].toString();
    groupId = json['groupId'].toString();
    groupDescription = json['groupDescription'].toString();
    groupAdmin = json['groupAdmin'].toString();
    groupMembers = json['groupMembers'];
    groupAdminName = json['groupAdminName'].toString();
    groupAdminImage = json['groupAdminImage'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['roomImage'] = roomImage;
    data['publishDate'] = publishDate;
    data['groupName'] = groupName;
    data['groupId'] = groupId;
    data['groupDescription'] = groupDescription;
    data['groupAdmin'] = groupAdmin;
    data['groupMembers'] = groupMembers;
    data['groupAdminName'] = groupAdminName;
    data['groupAdminImage'] = groupAdminImage;
    return data;
  }
}
