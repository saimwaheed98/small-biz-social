class PostModel {
  PostModel({
    required this.uid,
    required this.postType,
    required this.publishDate,
    required this.description,
    required this.profileImage,
    required this.postId,
    required this.likes,
    required this.stars,
    required this.username,
    required this.postData,
    required this.postTitle,
    required this.comments,
  });
  late String uid;
  late PostType postType;
  late int publishDate;
  late String description;
  late String profileImage;
  late String postId;
  late List likes;
  late List stars;
  late List comments;
  late String username;
  late String postData;
  late String postTitle;

  PostModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    postType = _getPostTypeFromString(json['postType']);
    publishDate = json['publishDate'];
    description = json['description'];
    profileImage = json['profileImage'];
    postId = json['postId'];
    likes = json['likes'];
    username = json['username'];
    postData = json['postData'];
    postTitle = json['postTitle'];
    stars = json['stars'];
    comments = json['comments'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['postType'] = postType.toString().split('.').last;
    data['publishDate'] = publishDate;
    data['description'] = description;
    data['profileImage'] = profileImage;
    data['postId'] = postId;
    data['likes'] = likes;
    data['username'] = username;
    data['postData'] = postData;
    data['postTitle'] = postTitle;
    data['stars'] = stars;
    data['comments'] = comments;
    return data;
  }

  PostType _getPostTypeFromString(String value) {
    switch (value) {
      case 'text':
        return PostType.text;
      case 'image':
        return PostType.image;
      case 'video':
        return PostType.video;
      default:
        return PostType.text;
    }
  }
}

enum PostType { text, image, video }
