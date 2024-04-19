import 'dart:convert';

import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicons/unicons.dart';

import '../data/carModel.dart';
import '../services/get_api_services.dart';
import '../widgets/homePage/car.dart';
import '../widgets/homePage/category.dart';
import 'detais_page.dart';

class AccordionPage extends StatefulWidget {
  static const headerStyle = TextStyle(
      color: Color(0xffffffff), fontSize: 18, fontWeight: FontWeight.bold);
  static const contentStyleHeader = TextStyle(
      color: Color(0xff999999), fontSize: 14, fontWeight: FontWeight.w700);
  static const contentStyle = TextStyle(
      color: Color(0xff999999), fontSize: 14, fontWeight: FontWeight.normal);
  static const loremIpsum =
      '''Lorem ipsum is typically a corrupted version of 'De finibus bonorum et malorum', a 1st century BC text by the Roman statesman and philosopher Cicero, with words altered, added, and removed to make it nonsensical and improper Latin.''';
  static const slogan =
      'Do not forget to play around with all sorts of colors, backgrounds, borders, etc.';

  @override
  State<AccordionPage> createState() => _AccordionPageState();
}

class _AccordionPageState extends State<AccordionPage> {
  List<CarModel>? _carsFuture;

  @override
  void initState() {
    super.initState();

    getCarsData();
  }

  Future<List<CarModel>?> getCarsData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final carList = await ApiService.getAllCarsByUser(prefs.getString('emailLogin')!);
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //check the size of device
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      body: Accordion(
        headerBorderColor: Colors.blueGrey,
        headerBorderColorOpened: Colors.transparent,
        // headerBorderWidth: 1,
        headerBackgroundColorOpened: Colors.green,
        contentBackgroundColor: Colors.white,
        contentBorderColor: Colors.green,
        contentBorderWidth: 2,
        contentHorizontalPadding: 0,
        scaleWhenAnimating: true,
        openAndCloseAnimation: true,
        headerPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
        sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
        sectionClosingHapticFeedback: SectionHapticFeedback.light,
        children: [
          AccordionSection(
            isOpen: true,
            leftIcon: const Icon(Icons.car_rental, color: Colors.white),
            header: const Text('My Registered Cars', style: AccordionPage.headerStyle),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: size.height * 0.001,
                    left: size.width * 0.05,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: size.height * 0.03,
                    right: size.width * 0.05,
                  ),
                ),
              ],
            ),
                Padding(
                  padding: EdgeInsets.only(
                    top: size.height * 0.01,
                    left: size.width * 0.03,
                    right: size.width * 0.03,
                  ),
                  child: SizedBox(
                    height: size.width * 0.55,
                    width: _carsFuture!.length * size.width * 0.5 * 1.03,
                    child: ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: _carsFuture?.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: size.width * 0.03,
                          ),
                          child: Center(
                            child: SizedBox(
                              height: size.width * 0.55,
                              width: size.width * 0.5,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: themeData.cardColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(
                                      20,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: size.width * 0.02,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(DetailsPage(
                                        car:  _carsFuture![i],
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
                                            child:
                                            AspectRatio(

                                              aspectRatio: 2.0,
                                              child: Image(
                                                image: NetworkImage(_carsFuture![i].images.isNotEmpty
                                                    ? '${ApiService.baseUrl}/home/availablecars/flutter/img/${_carsFuture![i].images[0].urlImage.toString()}'
                                                    : 'https://media.istockphoto.com/id/1300845620/vector/user-icon-flat-isolated-on-white-background-user-symbol-vector-illustration.jpg?s=612x612&w=0&k=20&c=yBeyba0hUkh14_jgv1OKqIH0CCSWU_4ckRkAoy2p73o='),
                                                fit: BoxFit.cover, // Adjust the fit as needed
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: size.height * 0.01,
                                          ),
                                          child: Text(
                                            _carsFuture![i].licensePlates,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              color: themeData.secondaryHeaderColor,
                                              fontSize: size.width * 0.05,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${_carsFuture![i].carmodel.model}-${_carsFuture![i].carmodel.year}',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            color: themeData.secondaryHeaderColor,
                                            fontSize: size.width * 0.03,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '\$${_carsFuture![i].discount > 0 ? (_carsFuture![i].price - (_carsFuture![i].discount * _carsFuture![i].price / 100)).toStringAsFixed(2) : _carsFuture![i].price}',
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
                                                    color: Color(0xff3b22a1),
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(
                                                        10,
                                                      ),
                                                    ),
                                                  ),
                                                  child: _carsFuture![i].discount > 0
                                                      ? Padding(
                                                    padding: const EdgeInsets.only(
                                                        left: 3, right: 3),
                                                    child: Text(
                                                      '${_carsFuture![i].discount}%',
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
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
