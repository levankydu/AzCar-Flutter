class CarModelType {
  String objectId;
  String brand;
  String category;
  List<dynamic> cars;
  String model;
  int year;

  CarModelType({
    required this.objectId,
    required this.brand,
    required this.category,
    required this.cars,
    required this.model,
    required this.year,
  });

  factory CarModelType.fromJson(Map<String, dynamic> json) {
    return CarModelType(
      objectId: json['objectId'],
      brand: json['brand'],
      category: json['category'],
      cars: json['cars'],
      model: json['model'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'brand': brand,
      'category': category,
      'cars': cars,
      'model': model,
      'year': year,
    };
  }
}
