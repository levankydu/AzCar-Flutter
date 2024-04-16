import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
  String selectedProvince = '';
  bool isProvinceDataLoaded = false;
  late List<District> districts;
  String selectedDistrict = '';
  bool isDistrictDataLoaded = false;
  late List<Ward> wards;
  String selectedWard = '';
  bool isWardDataLoaded = false;

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
    districts = [];
    wards = [];
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
        isProvinceDataLoaded = true;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<District>> fetchDistrictData(String provinceCode) async {
    final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/cars/getDistricts?$provinceCode'),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      districts = data.map((json) => District.fromJson(json)).toList();
      isDistrictDataLoaded = true;
      return districts;
    } else {
      throw Exception('Failed to load districts');
    }
  }

  Future<List<Ward>> fetchWardData(String districtCode) async {
    final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/cars/getWards?$districtCode'),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      wards = data.map((json) => Ward.fromJson(json)).toList();
      isWardDataLoaded = true;
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
                    ],
                  ),
                  SelectDateAndLocationWidget(
                    size: size,
                    fromDateController: fromDateController,
                    toDateController: toDateController,
                    updateUI: () => setState(() {}),
                    provinces: provinces,
                    selectedProvince: selectedProvince,
                    isProvinceDataLoaded: isProvinceDataLoaded,
                    districts: districts,
                    selectedDistrict: selectedDistrict,
                    wards: wards,
                    selectedWard: selectedWard,
                    fetchDistrictData: fetchDistrictData,
                    fetchWardData: fetchWardData,
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

class CarDetailsWidget extends StatelessWidget {
  final CarModel car;
  final Size size;
  final ThemeData themeData;

  const CarDetailsWidget({
    Key? key,
    required this.car,
    required this.size,
    required this.themeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discount :${car.discount}%',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: themeData.primaryColor,
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.star,
                color: Colors.yellow[800],
                size: size.width * 0.06,
              ),
              Text(
                car.licensePlates,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.yellow[800],
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Text(
              '${car.carmodel.model}-${car.carmodel.year}',
              textAlign: TextAlign.left,
              style: GoogleFonts.poppins(
                color: themeData.primaryColor,
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${car.price}\$',
              style: GoogleFonts.poppins(
                color: themeData.primaryColor,
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '/per day',
              style: GoogleFonts.poppins(
                color: themeData.primaryColor.withOpacity(0.8),
                fontSize: size.width * 0.025,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: size.height * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildStat(
                UniconsLine.dashboard,
                '${car.fuelType} ',
                'Power',
                size,
                themeData,
              ),
              buildStat(
                UniconsLine.users_alt,
                'People',
                '( ${car.seatQty} )',
                size,
                themeData,
              ),
              buildStat(
                UniconsLine.car,
                'Engine',
                ' ${car.engineInformationTranmission ? 'Auto' : 'Manual'} ',
                size,
                themeData,
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.03,
          ),
          child: Text(
            'Car Location',
            style: GoogleFonts.poppins(
              color: themeData.primaryColor,
              fontSize: size.width * 0.055,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: SizedBox(
            height: size.height * 0.15,
            width: size.width * 0.9,
            child: Container(
              decoration: BoxDecoration(
                color: themeData.cardColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.015,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          UniconsLine.map_marker,
                          color: const Color(0xff3b22a1),
                          size: size.height * 0.05,
                        ),
                        Text(
                          car.address
                              .split(', ')
                              .sublist(car.address.split(', ').length - 2)
                              .join(', '),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: themeData.primaryColor,
                            fontSize: size.width * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          car.address
                              .split(', ')
                              .sublist(0, car.address.split(', ').length - 2)
                              .join(', '),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: themeData.primaryColor.withOpacity(0.6),
                            fontSize: size.width * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Padding buildStat(
    IconData icon,
    String title,
    String desc,
    Size size,
    ThemeData themeData,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.015,
      ),
      child: SizedBox(
        height: size.width * 0.32,
        width: size.width * 0.25,
        child: Container(
          decoration: BoxDecoration(
            color: themeData.cardColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: size.width * 0.03,
              left: size.width * 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: const Color(0xff3b22a1),
                  size: size.width * 0.08,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: size.width * 0.02,
                  ),
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: themeData.primaryColor,
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    color: themeData.primaryColor.withOpacity(0.7),
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SelectDateAndLocationWidget extends StatelessWidget {
  final Size size;
  final TextEditingController fromDateController;
  final TextEditingController toDateController;
  final Function updateUI;
  final List<Province> provinces;
  final String selectedProvince;
  final bool isProvinceDataLoaded;
  final List<District> districts;
  final String selectedDistrict;
  final List<Ward> wards;
  final String selectedWard;
  final Future<List<District>> Function(String) fetchDistrictData;
  final Future<List<Ward>> Function(String) fetchWardData;

  const SelectDateAndLocationWidget({
    Key? key,
    required this.size,
    required this.fromDateController,
    required this.toDateController,
    required this.updateUI,
    required this.provinces,
    required this.selectedProvince,
    required this.isProvinceDataLoaded,
    required this.districts,
    required this.selectedDistrict,
    required this.wards,
    required this.selectedWard,
    required this.fetchDistrictData,
    required this.fetchWardData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: size.height * 0.01,
        ),
        child: SizedBox(
          height: size.height * 0.07,
          width: size.width,
          child: InkWell(
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return SingleChildScrollView(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.95,
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 20,
                                    top: 10,
                                    left: 200,
                                    right: 50,
                                  ),
                                  child: Text('Order Booking'),
                                ),
                                TextField(
                                  controller: fromDateController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'From Date',
                                  ),
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2024),
                                      lastDate: DateTime(2026),
                                    );
                                    if (pickedDate != null) {
                                      String formattedDate =
                                          DateFormat('dd-MM-yyyy')
                                              .format(pickedDate);
                                      fromDateController.text = formattedDate;
                                      updateUI();
                                      Future.delayed(
                                        Duration(milliseconds: 100),
                                        () {
                                          FocusScope.of(context).unfocus();
                                        },
                                      );
                                    }
                                  },
                                ),
                                SizedBox(height: 20),
                                TextField(
                                  controller: toDateController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'To Date',
                                  ),
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2024),
                                      lastDate: DateTime(2026),
                                    );
                                    if (pickedDate != null) {
                                      String formattedDate =
                                          DateFormat('dd-MM-yyyy')
                                              .format(pickedDate);
                                      toDateController.text = formattedDate;
                                      updateUI();
                                      Future.delayed(
                                        Duration(milliseconds: 100),
                                        () {
                                          FocusScope.of(context).unfocus();
                                        },
                                      );
                                    }
                                  },
                                ),
                                SizedBox(height: 20),
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  value: selectedProvince.isNotEmpty
                                      ? selectedProvince
                                      : null,
                                  hint: Text('Province'),
                                  onChanged: (String? newValue) async {
                                    final state =
                                        context.findAncestorStateOfType<
                                            _DetailsPageState>();
                                    if (state != null) {
                                      state.setState(() {
                                        state.selectedProvince = newValue!;
                                      });
                                      final districts = await state
                                          .fetchDistrictData(newValue!);
                                      state.setState(() {
                                        state.districts = districts;
                                      });
                                    }
                                  },
                                  items: provinces.map((Province province) {
                                    return DropdownMenuItem<String>(
                                      value: province.code,
                                      child: Text(province.name),
                                    );
                                  }).toList(),
                                ),
                                SizedBox(height: 20),
                                if (districts.isNotEmpty)
                                  DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                    value: selectedDistrict.isNotEmpty
                                        ? selectedDistrict
                                        : null,
                                    hint: Text('District'),
                                    onChanged: (String? newValue) async {
                                      final state =
                                          context.findAncestorStateOfType<
                                              _DetailsPageState>();
                                      if (state != null) {
                                        state.setState(() {
                                          state.selectedDistrict = newValue!;
                                        });
                                        final wards = await state
                                            .fetchWardData(newValue!);
                                        state.setState(() {
                                          state.wards = wards;
                                        });
                                      }
                                    },
                                    items: districts.map((District district) {
                                      return DropdownMenuItem<String>(
                                        value: district.code,
                                        child: Text(district.name),
                                      );
                                    }).toList(),
                                  ),
                                SizedBox(height: 20),
                                if (wards.isNotEmpty)
                                  DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                    value: selectedWard.isNotEmpty
                                        ? selectedWard
                                        : null,
                                    hint: Text('Ward'),
                                    onChanged: (String? newValue) {
                                      final state =
                                          context.findAncestorStateOfType<
                                              _DetailsPageState>();
                                      if (state != null) {
                                        state.setState(() {
                                          state.selectedWard = newValue!;
                                        });
                                      }
                                    },
                                    items: wards.map((Ward ward) {
                                      return DropdownMenuItem<String>(
                                        value: ward.code,
                                        child: Text(ward.name),
                                      );
                                    }).toList(),
                                  ),
                                SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    // Handle booking logic here
                                  },
                                  child: Text('Book Now'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xff3b22a1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Select Date',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * 0.05,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
