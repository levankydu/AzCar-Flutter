import 'package:az_car_flutter_app/data/user_model.dart';
import 'package:az_car_flutter_app/page/home_page.dart';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicons/unicons.dart';

import '../constant_user_profile_screen.dart';
import '../services/get_api_services.dart';
import '../widgets/bottom_nav_bar.dart';
import 'demo_accodian.dart';
import 'login_register_page.dart';

class MyPlanScreen extends StatefulWidget {
  const MyPlanScreen({Key? key}) : super(key: key);
  static String routeName = 'MyProfileScreen';

  @override
  State<MyPlanScreen> createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends State<MyPlanScreen> {
  String emailLogin = '';
  UserModel? user;
  bool _isLoading = true; // Đặt giá trị ban đầu của _isLoading là true để hiển thị tiến trình đang tải

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool checkValue = prefs.containsKey('emailLogin');
    if (checkValue) {
      final String action = prefs.getString('emailLogin')!;
      var model = await ApiService.getUserByEmail(action);
      if (model != null) {
        setState(() {
          user = model;
          _isLoading = false; // Khi dữ liệu đã được tải xong, đặt _isLoading thành false để ẩn tiến trình đang tải
        });
      }
    } else {
      setState(() {
        _isLoading = false; // Trong trường hợp không có dữ liệu để tải, đặt _isLoading thành false để ẩn tiến trình đang tải
      });
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                await Future.delayed(Duration(seconds: 2));
                final SharedPreferences prefs =
                await SharedPreferences.getInstance();
                await prefs.clear();
                Get.to(() => HomePage());
              },
              child: Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
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
            themeData.brightness == Brightness.dark ? 'assets/images/logo-azcar.png' : 'assets/images/logo-azcar.png',
            alignment: Alignment.bottomCenter,
            height: size.height * 0.05,
            width: size.width * 0.35,
          ),
          centerTitle: true,
        ),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: Container(
        color: themeData.colorScheme.background,
        child: buildBottomNavBar(1, size, themeData),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(), // Hiển thị tiến trình đang tải
      )
          : (user == null
          ? Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: size.height * 0.02,
              left: size.width * 0.06,
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Text(
                      'Chào mừng đến với AzCar, ',
                      style: GoogleFonts.poppins(
                        color: themeData.secondaryHeaderColor,
                        fontSize: size.width * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: size.height * 0.01,
              left: size.width * 0.06,
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Click SigIn to continue',
                textAlign: TextAlign.left,
                style: GoogleFonts.poppins(
                  color: themeData.secondaryHeaderColor,
                  fontSize: size.width * 0.035,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: size.height * 0.03,
              left: size.width * 0.04,
              bottom: size.height * 0.025,
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 30),
                child: AnimatedButton(
                  height: 70,
                  width: MediaQuery.of(context).size.width,
                  text: 'Log in',
                  isReverse: true,
                  selectedTextColor: Colors.black,
                  transitionType: TransitionType.LEFT_TO_RIGHT,
                  backgroundColor: themeData.secondaryHeaderColor,
                  borderColor: themeData.secondaryHeaderColor,
                  borderRadius: 50,
                  borderWidth: 2,
                  onPress: () {
                    Get.to(() => LoginSignupScreen());
                  },
                ),
              ),
            ],
          ),
        ],
      )
          : SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: kOtherColor,
          child: Column(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: size.height * 0.02,
                      left: size.width * 0.06,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Welcome back, ',
                        textAlign: TextAlign.left,
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
                      left: size.width * 0.06,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        user!.email,
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                          color: themeData.secondaryHeaderColor,
                          fontSize: size.width * 0.035,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(child: AccordionPage())
            ],
          ),
        ),
      )),
    );
  }
}
