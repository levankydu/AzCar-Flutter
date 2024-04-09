import 'package:flutter/material.dart';
import 'dart:ui';
import '../../data/carModel.dart';
import 'car.dart';
import 'category.dart';

Widget buildMostRented(Size size, ThemeData themeData, List<CarModel>? carList) {
  return Column(
    children: [
      buildCategory('Most Rented', size, themeData),
      Padding(
        padding: EdgeInsets.only(
          top: size.height * 0.015,
          left: size.width * 0.03,
          right: size.width * 0.03,
        ),
        child: SizedBox(
          height: size.width * 0.55,
          width: carList!.length * size.width * 0.5 * 1.03,
          child: ListView.builder(
            primary: false,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: carList.length,
            itemBuilder: (context, i) {
              return buildCar(
                carList[i],
                size,
                themeData,
              );
            },
          ),
        ),
      ),
    ],
  );
}
