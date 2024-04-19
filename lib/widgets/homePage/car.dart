import 'dart:convert';
import 'package:az_car_flutter_app/data/user_model.dart';
import 'package:az_car_flutter_app/services/get_api_services.dart';
import 'package:az_car_flutter_app/widgets/detailsPage/heartButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicons/unicons.dart';
import 'dart:ui';
import '../../data/carModel.dart';
import '../../page/detais_page.dart';

Future<List<CarModel>> getCarsData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? encodedCarList = prefs.getString('carList');

  if (encodedCarList != null) {
    final List<dynamic> decodedCarList = json.decode(encodedCarList);
    final List<CarModel> carList =
        decodedCarList.map((carJson) => CarModel.fromJson(carJson)).toList();
    return carList;
  } else {
    return [];
  }
}

Padding buildCar(CarModel car, Size size, ThemeData themeData, UserModel? user) {
  return Padding(
    padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.03, vertical: size.height * 0.01),
    // Thêm khoảng cách ngang và dọc
    child: Center(
      child: SizedBox(
        child: Container(
          decoration: BoxDecoration(
            color: themeData.cardColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(
                20,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: size.width * 0.02,
              right: size.width * 0.02,
            ),
            child: InkWell(
              onTap: () {
                Get.to(DetailsPage(
                  car: car,
                ));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: size.height * 0.01,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: themeData.cardColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(13),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          // Border radius cho hình ảnh
                          child: AspectRatio(
                            aspectRatio: 2.0,
                            child: Image(
                              image: NetworkImage(
                                car.images.isNotEmpty
                                    ? '${ApiService.baseUrl}/home/availablecars/flutter/img/${car.images[0].urlImage.toString()}'
                                    : 'https://media.istockphoto.com/id/1300845620/vector/user-icon-flat-isolated-on-white-background-user-symbol-vector-illustration.jpg?s=612x612&w=0&k=20&c=yBeyba0hUkh14_jgv1OKqIH0CCSWU_4ckRkAoy2p73o=',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: size.height * 0.01,
                            ),
                            child: Text(
                              car.licensePlates,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: themeData.secondaryHeaderColor,
                                fontSize: size.width * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '${car.carmodel.model}-${car.carmodel.year}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: themeData.secondaryHeaderColor,
                              fontSize: size.width * 0.03,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if(user != null)
                      HeartButton(car, user),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '\$${car.discount > 0 ? (car.price - (car.price * car.discount / 100)).toStringAsFixed(2) : car.price}',
                        style: GoogleFonts.poppins(
                          color: themeData.secondaryHeaderColor,
                          fontSize: size.width * 0.06,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '/per day',
                        style: GoogleFonts.poppins(
                          color: themeData.primaryColor.withOpacity(0.8),
                          fontSize: size.width * 0.03,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: EdgeInsets.only(
                          right: size.width * 0.025,
                        ),
                        child: SizedBox(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.all(
                                Radius.circular(
                                  10,
                                ),
                              ),
                            ),
                            child: car.discount > 0
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left: 3, right: 3),
                                    child: Text(
                                      '-${car.discount}%',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: size.width * 0.04,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
