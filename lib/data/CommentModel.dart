class CommentModel {
  final int id;
  final String content;
  final String userName;
  final DateTime reviewDate;

  CommentModel({
    required this.id,
    required this.content,
    required this.userName,
    required this.reviewDate,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      userName: json['user_name'] ?? '', // Chỉnh sửa từ 'userName' thành 'user_name'
      reviewDate: json['reviewDate'] != null
          ? DateTime.parse(json['reviewDate'])
          : DateTime.now(),
    );
  }
}
