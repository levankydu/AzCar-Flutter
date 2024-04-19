import 'dart:ffi';

class WithdrawDTO {
  final String userId;
  final double withdraw; // Giữ nguyên dưới dạng String để phù hợp với BigDecimal
  final String referenceNumber;
  final String paymentDate; // Thêm trường paymentDate để gửi ngày thanh toán

  WithdrawDTO({
    required this.userId,
    required this.withdraw,
    required this.referenceNumber,
    required this.paymentDate, // Yêu cầu tham số này khi khởi tạo
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'withdraw': withdraw,
      'referenceNumber': referenceNumber,
      'paymentDate': paymentDate, // Thêm paymentDate vào JSON
    };
  }
}
