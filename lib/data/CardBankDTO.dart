class CardBankDTO {
  int id;
  String bankName;
  String bankNumber;
  String beneficiaryName;
  String addressbank;
  String active;
  dynamic user;  // dynamic here since user is null in JSON

  CardBankDTO({
    required this.id,
    required this.bankName,
    required this.bankNumber,
    required this.beneficiaryName,
    required this.addressbank,
    required this.active,
    this.user,
  });

  factory CardBankDTO.fromJson(Map<String, dynamic> json) {
    return CardBankDTO(
      id: json['id'],
      bankName: json['bankName'],
      bankNumber: json['bankNumber'],
      beneficiaryName: json['beneficiaryName'],
      addressbank: json['addressbank'],
      active: json['active'],
      user: json['user'],
    );
  }

  static List<CardBankDTO> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => CardBankDTO.fromJson(json)).toList();
  }
}
