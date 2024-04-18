import 'dart:convert';
import 'dart:ui';
import 'package:az_car_flutter_app/data/carModel.dart';
import 'package:az_car_flutter_app/page/user_page.dart';
import 'package:az_car_flutter_app/widgets/homePage/car_register.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicons/unicons.dart';

import '../data/user_model.dart';
import '../services/get_api_services.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/homePage/most_rented.dart';
import '../widgets/homePage/top_brands.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? user;
  String emailLogin = '';
  List<CarModel>? _carsFuture;

  @override
  void initState() {
    super.initState();
    getUserData();
    getCarsData();
  }

  Future<List<CarModel>?> getCarsData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final carList = await ApiService.getCarsExceptUserCar(prefs.getString('emailLogin')!);
    if (carList!.isNotEmpty) {
      final List<Map<String, dynamic>> jsonList =
          carList.map((car) => car.toJson()).toList();
      final String encodedCarList = json.encode(jsonList);

      await prefs.setString('carList', encodedCarList);
      setState(() {
        _carsFuture = carList;
      });
    }
    return null;
  }

  Future<UserModel?> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool checkValue = prefs.containsKey('emailLogin');
    if (checkValue) {
      final String action = prefs.getString('emailLogin')!;
      var model = await ApiService.getUserByEmail(action);
      if (model != null) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('id', model.id.toString());
        setState(() {
          user = model;
        });
        await Future.delayed(Duration(seconds: 2));
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //check the size of device
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0), //appbar size
        child: AppBar(
          bottomOpacity: 0.0,
          elevation: 0.0,
          shadowColor: Colors.transparent,
          backgroundColor: themeData.colorScheme.background,
          leading: Padding(
            padding: EdgeInsets.only(
              left: size.width * 0.05,
            ),
            child: SizedBox(
              height: size.height * 0.1,
              width: size.width * 0.1,
              child: Container(
                decoration: BoxDecoration(
                  color: themeData.colorScheme.background.withOpacity(0.03),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Icon(
                  UniconsLine.bars,
                  color: themeData.secondaryHeaderColor,
                  size: size.height * 0.025,
                ),
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          leadingWidth: size.width * 0.15,
          title: Image.asset(
            themeData.brightness == Brightness.dark
                ? 'assets/images/logo-azcar.png'
                : 'assets/images/logo-azcar.png',
            alignment: Alignment.bottomCenter,
            height: size.height * 0.05,
            width: size.width * 0.35,
          ),
          centerTitle: true,
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                right: size.width * 0.05,
              ),
              child: SizedBox(
                height: size.width * 0.1,
                width: size.width * 0.1,
                child: Container(
                  decoration: BoxDecoration(
                    color: themeData.colorScheme.background.withOpacity(0.03),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => MyProfileScreen());
                    },
                    child: ClipOval(
                      child: Image(
                        image: NetworkImage(user != null
                            ? '${ApiService.baseUrl}/user/profile/flutter/avatar/${user?.image}'
                            : 'https://media.istockphoto.com/id/1300845620/vector/user-icon-flat-isolated-on-white-background-user-symbol-vector-illustration.jpg?s=612x612&w=0&k=20&c=yBeyba0hUkh14_jgv1OKqIH0CCSWU_4ckRkAoy2p73o='),
                        fit: BoxFit.cover, // Adjust the fit as needed
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: buildBottomNavBar(1, size, themeData),
      backgroundColor: themeData.colorScheme.background,
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: size.height * 0.02,
                left: size.width * 0.05,
                right: size.width * 0.05,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15),
                  ),
                  color: themeData.cardColor, //section bg color
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: size.height * 0.02,
                      ),
                      child: Align(
                        child: Text(
                          'With Corporate Difference',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: themeData.secondaryHeaderColor,
                            fontSize: size.width * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: size.height * 0.01,
                        bottom: size.height * 0.05,
                      ),
                      child: Align(
                        child: Text(
                          'Enjoy the fun driving in Enterprise',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: themeData.secondaryHeaderColor,
                            fontSize: size.width * 0.035,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            buildTopBrands(size, themeData),
            buildMostRented(size, themeData, _carsFuture),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CarRegister(),
                  ),
                );
              },
              child: Text('Register Car'),
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder textFieldBorder() {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(15.0)),
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.5),
        width: 1.0,
      ),
    );
  }
}
