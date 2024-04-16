class CarImage {
  int id;
  String name;
  String urlImage;
  int carId;

  CarImage({
    required this.id,
    required this.name,
    required this.urlImage,
    required this.carId,
  });

  factory CarImage.fromJson(Map<String, dynamic> json) {
    return CarImage(
      id: json['id'],
      name: json['name'],
      urlImage: json['urlImage'],
      carId: json['carId'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'urlImage': urlImage,
      'carId': carId,
    };
}}
