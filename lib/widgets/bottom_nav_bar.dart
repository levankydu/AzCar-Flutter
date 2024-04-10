import 'package:az_car_flutter_app/page/my_plan.dart';
import 'package:az_car_flutter_app/page/user_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';
import 'bottom_nav_item.dart';
import 'dart:ui';
Widget buildBottomNavBar(int currIndex, Size size, ThemeData themeData) {
  return BottomNavigationBar(
    iconSize: size.width * 0.07,
    elevation: 0,
    selectedLabelStyle: const TextStyle(fontSize: 0),
    unselectedLabelStyle: const TextStyle(fontSize: 0),
    currentIndex: currIndex,
    backgroundColor: const Color(0x00ffffff),
    type: BottomNavigationBarType.fixed,
    selectedItemColor: themeData.brightness == Brightness.dark
        ? Colors.indigoAccent
        : Colors.black,
    unselectedItemColor: const Color(0xff3b22a1),
    onTap: (value) {
      switch (value) {
        case 0:
          print(value);
          break;
        case 1:
          print(value);
          break;
        case 2:
          print(value);
          break;
        case 3:
          print(value);
          Get.to(()=>MyPlanScreen());
          break;
        case 4:
          print(value);
          Get.to(()=>MyProfileScreen());
          break;

        default:
          break;
      }
    },
    items: [
      buildBottomNavItem(UniconsLine.bell, themeData, size),
      buildBottomNavItem(
        UniconsLine.map_marker,
        themeData,
        size,
      ),
      buildBottomNavItem(UniconsLine.user, themeData, size),
      buildBottomNavItem(UniconsLine.car_sideview, themeData, size),
      buildBottomNavItem(
        UniconsLine.user_check,
        themeData,
        size,
      ),
    ],
  );
}
