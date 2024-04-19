class Ward {
  final String code;
  final String districtCode;
  final String name;
  final String nameEn;
  final String fullName;
  final String fullNameEn;
  final String codeName;

  Ward({
    required this.code,
    required this.districtCode,
    required this.name,
    required this.nameEn,
    required this.fullName,
    required this.fullNameEn,
    required this.codeName,
  });

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      code: json['code'],
      districtCode: json['district_code'],
      name: json['name'],
      nameEn: json['name_en'],
      fullName: json['full_name'],
      fullNameEn: json['full_name_en'],
      codeName: json['code_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'district_code': districtCode,
      'name': name,
      'name_en': nameEn,
      'full_name': fullName,
      'full_name_en': fullNameEn,
      'code_name': codeName,
    };
  }
}
