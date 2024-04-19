class Province {
  final String code;
  final String name;
  final String nameEn;
  final String fullName;
  final String fullNameEn;
  final String codeName;

  Province({
    required this.code,
    required this.name,
    required this.nameEn,
    required this.fullName,
    required this.fullNameEn,
    required this.codeName,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      code: json['code'],
      name: json['name'],
      nameEn: json['name_en'],
      fullName: json['full_name'],
      fullNameEn: json['full_name_en'],
      codeName: json['code_name'],
    );
  }
}
