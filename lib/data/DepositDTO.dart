import 'dart:ffi';

class DepositDTO {
  final String userId;
  final double amount; // Giữ nguyên dưới dạng String để phù hợp với BigDecimal
  final String referenceNumber;
  final String paymentDate; // Thêm trường paymentDate để gửi ngày thanh toán

  DepositDTO({
    required this.userId,
    required this.amount,
    required this.referenceNumber,
    required this.paymentDate, // Yêu cầu tham số này khi khởi tạo
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'amount': amount,
      'referenceNumber': referenceNumber,
      'paymentDate': paymentDate, // Thêm paymentDate vào JSON
    };
  }
}
