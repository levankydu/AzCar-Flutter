class District {
  final String code;
  final String provinceCode;
  final String name;
  final String nameEn;
  final String fullName;
  final String fullNameEn;
  final String codeName;

  District({
    required this.code,
    required this.provinceCode,
    required this.name,
    required this.nameEn,
    required this.fullName,
    required this.fullNameEn,
    required this.codeName,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      code: json['code'],
      provinceCode: json['province_code'],
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
      'province_code': provinceCode,
      'name': name,
      'name_en': nameEn,
      'full_name': fullName,
      'full_name_en': fullNameEn,
      'code_name': codeName,
    };
  }
}
