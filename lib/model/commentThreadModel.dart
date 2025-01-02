class CommentThreadModel {
  final String title;
  final String content;
  final String uuid;
  final String status;
  final String postedBy;
  final AuthorDetails authorDetails;
  final int commentCount;
  final int likeCount;
  final String postedAt;

  CommentThreadModel({
    required this.title,
    required this.content,
    required this.uuid,
    required this.status,
    required this.postedBy,
    required this.authorDetails,
    required this.commentCount,
    required this.likeCount,
    required this.postedAt,
  });

  factory CommentThreadModel.fromJson(Map<String, dynamic> json) {
    return CommentThreadModel(
      title: json['title'],
      content: json['content'],
      uuid: json['uuid'],
      status: json['status'],
      postedBy: json['postedBy'],
      authorDetails: AuthorDetails.fromJson(json['authorDetails']),
      commentCount: json['commentCount'],
      likeCount: json['likeCount'],
      postedAt: json['postedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'uuid': uuid,
      'status': status,
      'postedBy': postedBy,
      'authorDetails': authorDetails.toJson(),
      'commentCount': commentCount,
      'likeCount': likeCount,
      'postedAt': postedAt,
    };
  }
}

class AuthorDetails {
  final String fullName;
  String? profilePicture;


  AuthorDetails( {
    required this.fullName,
    this.profilePicture,


  });

  factory AuthorDetails.fromJson(Map<String, dynamic> json) {
    return AuthorDetails(
      fullName: json['fullName'],
      profilePicture: json['profilePicture'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'profilePicture': profilePicture,

    };
  }
}
