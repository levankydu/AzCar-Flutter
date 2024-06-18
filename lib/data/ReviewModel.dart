class ReviewModel {
  final int id;
  final String status;
  final int rating;
  final String comment;
  final DateTime reviewDate;
  final String userName;
  final String carName;

  ReviewModel({
    required this.id,
    required this.status,
    required this.rating,
    required this.comment,
    required this.reviewDate,
    required this.userName,
    required this.carName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['content'] ?? '',  // Assuming 'content' is the field name in your JSON for the comment
      reviewDate: json['reviewDate'] != null
          ? DateTime.parse(json['reviewDate'])
          : DateTime.now(),  // Use current date if null
      userName: json['userName'] ?? '',  // Add userName
      carName: json['carName'] ?? '',  // Add carName
    );
  }
}
