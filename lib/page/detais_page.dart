import 'dart:convert';
import 'package:az_car_flutter_app/data/OrderDetails.dart';
import 'package:az_car_flutter_app/widgets/detailsPage/bookingWidget.dart';
import 'package:az_car_flutter_app/widgets/detailsPage/carDetailsWidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicons/unicons.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:az_car_flutter_app/data/DIstrict.dart';
import 'package:az_car_flutter_app/data/Province.dart';
import 'package:az_car_flutter_app/data/Ward.dart';
import 'package:az_car_flutter_app/data/carModel.dart';
import 'package:az_car_flutter_app/services/get_api_services.dart';

class DetailsPage extends StatefulWidget {
  final CarModel car;

  const DetailsPage({
    Key? key,
    required this.car,
  }) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late List<String> images;
  late List<String> orderSetDates = [];

  @override
  void initState() {
    super.initState();
    images = widget.car.images
        .map((image) =>
            '${ApiService.baseUrl}/home/availablecars/flutter/img/${image.urlImage.toString()}')
        .toList();
    fetchOrderSetDates(widget.car.id.toString());
  }

  Future<void> fetchOrderSetDates(String carId) async {
    String? userId;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool checkValue = prefs.containsKey('id');
    if (checkValue) {
      userId = prefs.getString('id')!;
    }
    final response = await http.get(
        Uri.parse(
            '${ApiService.baseUrl}/api/cars/getOrderOfThisCar?carId=$carId&userId=$userId'),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        orderSetDates = data.map((json) {
          return '* From ${parseDateTime(json['fromDate'])} to ${parseDateTime(json['toDate'])}';
        }).toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  String parseDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
    return formattedDate;
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
            padding: EdgeInsets.only(left: size.width * 0.05, bottom: 7),
            child: SizedBox(
              height: size.width * 0.1,
              width: size.width * 0.1,
              child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: themeData.colorScheme.background,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Icon(
                    UniconsLine.arrow_circle_left,
                    color: themeData.secondaryHeaderColor,
                    size: size.height * 0.045,
                  ),
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
        ),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: themeData.colorScheme.background,
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 2.0,
                      child: Center(
                        child: CarouselSlider(
                          options: CarouselOptions(
                            aspectRatio: 16 / 9,
                            autoPlay: true,
                            enlargeCenterPage: true,
                          ),
                          items: images.map((url) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 1.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                    ),
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: CarDetailsWidget(
                          car: widget.car, size: size, themeData: themeData),
                    ),
                    if (orderSetDates.isNotEmpty)
                      SizedBox(
                        width: size.width * 0.9,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Booked Dates', // Tiêu đề
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff3b22a1),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200], // Màu nền của box
                                  borderRadius: BorderRadius.circular(8.0), // Bo góc của box
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: orderSetDates.map((date) {
                                    return Center(
                                      child: Text(
                                        date,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookingWidget(car: widget.car),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            backgroundColor: themeData.secondaryHeaderColor,
                          ),
                          child: Text(
                            'Book This Car',
                            style:
                                TextStyle(fontSize: 18.0, color: Colors.white),
                          ),
                        ),
                      ),
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
}
