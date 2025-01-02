class Comment {
  String comment;
  String author;
  String uuid;
  String commentedBy;
  DateTime createdAt;

  Comment({
    required this.comment,
    required this.author,
    required this.uuid,
    required this.commentedBy,
    required this.createdAt,
  });

  // Factory method to create a Comment object from JSON
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      comment: json['comment'],
      author: json['author'],
      uuid: json['uuid'],
      commentedBy: json['commentedBy'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Method to convert a Comment object to JSON
  Map<String, dynamic> toJson() {
    return {
      'comment': comment,
      'author': author,
      'uuid': uuid,
      'commentedBy': commentedBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
