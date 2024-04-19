import 'package:az_car_flutter_app/data/user_model.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../data/carModel.dart';
import 'car.dart';
import 'category.dart';

Widget buildMostRented(Size size, ThemeData themeData, List<CarModel>? carList, UserModel? user) {
  return SizedBox(
    width: double.infinity, // Đảm bảo mở rộng ra full width của màn hình
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Đảm bảo các widgets con sẽ căn trái
      children: [
        buildCategory('Most Rented', size, themeData),
        SizedBox(
          child: ListView.builder(
            primary: false,
            shrinkWrap: true, // Co lại theo chiều dọc
            scrollDirection: Axis.vertical, // Cuộn theo chiều dọc
            itemCount: carList?.length ?? 0,
            itemBuilder: (context, i) {
              return buildCar(
                carList![i],
                size,
                themeData,
                user,
              );
            },
          ),
        ),
      ],
    ),
  );
}


