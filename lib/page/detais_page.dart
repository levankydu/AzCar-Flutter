import 'dart:convert';
import 'package:az_car_flutter_app/widgets/detailsPage/bookingWidget.dart';
import 'package:az_car_flutter_app/widgets/detailsPage/carDetailsWidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
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
  late TextEditingController fromDateController;
  late TextEditingController toDateController;
  late List<Province> provinces;

  @override
  void initState() {
    super.initState();
    fromDateController = TextEditingController();
    toDateController = TextEditingController();
    images = widget.car.images
        .map((image) =>
            '${ApiService.baseUrl}/home/availablecars/flutter/img/${image.urlImage.toString()}')
        .toList();
    provinces = [];
    fetchProvinceData();
  }

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  Future<void> fetchProvinceData() async {
    final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/cars/getProvinces'),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        provinces = data.map((json) => Province.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<District>> fetchDistrictData(String provinceCode) async {
    String url =
        '${ApiService.baseUrl}/api/cars/getDistricts?provinceCode=$provinceCode';
    final response = await http
        .get(headers: {'Content-Type': 'application/json'}, Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      List<District> districts =
          data.map((json) => District.fromJson(json)).toList();
      return districts;
    } else {
      throw Exception('Failed to load districts');
    }
  }

  Future<List<Ward>> fetchWardData(String districtCode) async {
    final response = await http.get(
        Uri.parse(
            '${ApiService.baseUrl}/api/cars/getWards?districtCode=$districtCode'),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      List<Ward> wards = data.map((json) => Ward.fromJson(json)).toList();
      return wards;
    } else {
      throw Exception('Failed to load ward data');
    }
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
            padding: EdgeInsets.only(left: size.width * 0.05),
            child: SizedBox(
              height: size.width * 0.1,
              width: size.width * 0.1,
              child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: themeData.cardColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Icon(
                    UniconsLine.multiply,
                    color: themeData.secondaryHeaderColor,
                    size: size.height * 0.025,
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
      body: Center(
        child: Container(
          height: size.height,
          width: size.height,
          decoration: BoxDecoration(
            color: themeData.colorScheme.background,
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Stack(
                children: [
                  ListView(
                    physics: const NeverScrollableScrollPhysics(),
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
                              return Builder(
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
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      CarDetailsWidget(
                          car: widget.car, size: size, themeData: themeData),
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
                                  builder: (context) => BookingWidget(car: widget.car),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              backgroundColor: themeData.secondaryHeaderColor,
                            ),
                            child: Text(
                              'Book This Car',
                              style: TextStyle(fontSize: 18.0, color: Colors.white), // Kích thước chữ
                            ),
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
    );
  }
}
