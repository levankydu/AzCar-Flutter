import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
                    ],
                  ),
                  SelectDateAndLocationWidget(
                    car: widget.car,
                    size: size,
                    fromDateController: fromDateController,
                    toDateController: toDateController,
                    provinces: provinces,
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
              '${(car.price - (car.price * car.discount / 100)).toStringAsFixed(2)}\$',
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

class SelectDateAndLocationWidget extends StatefulWidget {
  final CarModel car;
  final Size size;
  final TextEditingController fromDateController;
  final TextEditingController toDateController;
  final List<Province> provinces;
  final Future<List<District>> Function(String) fetchDistrictData;
  final Future<List<Ward>> Function(String) fetchWardData;

  SelectDateAndLocationWidget({
    super.key,
    required this.size,
    required this.fromDateController,
    required this.toDateController,
    required this.provinces,
    required this.fetchDistrictData,
    required this.fetchWardData,
    required this.car,
  });

  @override
  State<SelectDateAndLocationWidget> createState() =>
      _SelectDateAndLocationWidgetState();
}

class _SelectDateAndLocationWidgetState
    extends State<SelectDateAndLocationWidget> {
  late String provinceFullName = '';
  late String districtFullName = '';
  late String wardFullName = '';
  late List<District> districts = [];
  late String selectedDistrict = '';
  late List<Ward> wards = [];
  late String selectedWard = '';
  late String selectedProvince = '';
  late SharedPreferences prefs;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: widget.size.height * 0.01,
        ),
        child: SizedBox(
          height: widget.size.height * 0.07,
          width: widget.size.width,
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
                                  controller: widget.fromDateController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'From Date',
                                  ),
                                  onTap: () async {
                                    DateTime initialDate = widget
                                            .fromDateController.text.isNotEmpty
                                        ? DateFormat('dd-MM-yyyy HH:mm:ss.S')
                                            .parse(
                                                '${widget.fromDateController.text} 00:00:00.000')
                                        : DateTime.now();
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: initialDate,
                                      firstDate: DateTime.now(),
                                      // Disable dates before today
                                      lastDate: DateTime(2026),
                                    );
                                    if (pickedDate != null) {
                                      DateTime fromDate = pickedDate;
                                      DateTime toDate =
                                          fromDate.add(Duration(days: 1));
                                      String formattedFromDate =
                                          DateFormat('dd-MM-yyyy')
                                              .format(fromDate);
                                      String formattedToDate =
                                          DateFormat('dd-MM-yyyy')
                                              .format(toDate);
                                      widget.fromDateController.text =
                                          formattedFromDate;
                                      widget.toDateController.text =
                                          formattedToDate;
                                      setState(() {});
                                      FocusScope.of(context).unfocus();
                                    }
                                  },
                                ),
                                SizedBox(height: 20),
                                TextField(
                                  controller: widget.toDateController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'To Date',
                                  ),
                                  onTap: () async {
                                    DateTime initialDate = widget
                                            .toDateController.text.isNotEmpty
                                        ? DateFormat('dd-MM-yyyy HH:mm:ss.S')
                                            .parse(
                                                '${widget.toDateController.text} 00:00:00.000')
                                        : (widget.fromDateController.text
                                                .isNotEmpty
                                            ? DateFormat('dd-MM-yyyy').parse(
                                                widget.fromDateController.text)
                                            : DateTime.now());
                                    DateTime firstSelectableDate =
                                        DateTime.now();
                                    if (widget
                                        .fromDateController.text.isNotEmpty) {
                                      firstSelectableDate =
                                          DateFormat('dd-MM-yyyy').parse(
                                              widget.fromDateController.text);
                                    }
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: initialDate,
                                      firstDate: firstSelectableDate,
                                      lastDate: DateTime(2026),
                                      selectableDayPredicate: (DateTime date) {
                                        if (widget.fromDateController.text
                                            .isNotEmpty) {
                                          DateTime fromDate =
                                              DateFormat('dd-MM-yyyy').parse(
                                                  widget
                                                      .fromDateController.text);
                                          if (date.isBefore(fromDate) ||
                                              date.isAtSameMomentAs(fromDate)) {
                                            return false; // Disable dates before or same as from date
                                          }
                                        } else {
                                          if (date.isBefore(DateTime.now())) {
                                            return false; // Disable dates before today if from date is not set
                                          }
                                        }
                                        return true; // Enable other dates
                                      },
                                    );
                                    if (pickedDate != null) {
                                      String formattedDate =
                                          DateFormat('dd-MM-yyyy')
                                              .format(pickedDate);
                                      widget.toDateController.text =
                                          formattedDate;
                                      FocusScope.of(context).unfocus();
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
                                    if (newValue != null) {
                                      final districts = await widget
                                          .fetchDistrictData(newValue);
                                      setState(() {
                                        selectedProvince = newValue;
                                        this.districts = districts;
                                        selectedDistrict = '';
                                      });
                                      Navigator.pop(context, districts);
                                    }
                                  },
                                  items:
                                      widget.provinces.map((Province province) {
                                    return DropdownMenuItem<String>(
                                      value: province.code,
                                      child: Text(province.fullName),
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
                                      final wards =
                                          await widget.fetchWardData(newValue!);
                                      setState(() {
                                        selectedDistrict = newValue;
                                        this.wards = wards;
                                        selectedWard = '';
                                      });
                                      Navigator.pop(context, wards);
                                    },
                                    items: districts.map((District district) {
                                      return DropdownMenuItem<String>(
                                        value: district.code,
                                        child: Text(district.fullName),
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
                                      selectedWard = newValue!;
                                    },
                                    items: wards.map((Ward ward) {
                                      return DropdownMenuItem<String>(
                                        value: ward.code,
                                        child: Text(ward.fullName),
                                      );
                                    }).toList(),
                                  ),
                                SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      isLoading =
                                          true; // Hiển thị loader khi nhấn vào nút
                                    });
                                    try {
                                      prefs =
                                          await SharedPreferences.getInstance();
                                      final String email =
                                          prefs.getString('emailLogin')!;
                                      final String id = prefs.getString('id')!;
                                      Province province = widget.provinces
                                          .firstWhere((i) =>
                                              i.code == selectedProvince);
                                      District district = districts.firstWhere(
                                          (i) => i.code == selectedDistrict);
                                      Ward ward = wards.firstWhere(
                                          (i) => i.code == selectedWard);
                                      final response = await http.post(
                                        Uri.parse(
                                            '${ApiService.baseUrl}/api/cars/postOrderDetails'),
                                        headers: <String, String>{
                                          'Content-Type':
                                              'application/json; charset=UTF-8',
                                        },
                                        body: jsonEncode(<String, String>{
                                          'fromDate':
                                              widget.fromDateController.text,
                                          'toDate':
                                              widget.toDateController.text,
                                          'ward': ward.fullName,
                                          'district': district.fullName,
                                          'province': province.fullName,
                                          'carId': widget.car.id.toString(),
                                          'userEmail': email,
                                          'userId': id,
                                        }),
                                      );
                                      if (response.statusCode == 200) {
                                        print(response.statusCode);
                                        print(response.body);
                                        String message =
                                            'Great, your order is signed up successfully!';
                                        await Fluttertoast.showToast(
                                            msg: response.body,
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.TOP,
                                            timeInSecForIosWeb: 5,
                                            backgroundColor:
                                                response.body == message
                                                    ? Colors.green
                                                    : Colors.amber,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                        Navigator.pop(context);
                                        if (response.body == message) {
                                          setState(() {
                                            widget.fromDateController.text = '';
                                            widget.toDateController.text = '';
                                            selectedProvince = '';
                                            selectedDistrict = '';
                                            selectedWard = '';
                                          });
                                        }
                                      } else {
                                        await Fluttertoast.showToast(
                                          msg:
                                              'Something happened, please try again',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.TOP,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      }
                                    } finally {
                                      setState(() {
                                        isLoading =
                                            false; // Ẩn loader khi nhận được phản hồi từ máy chủ
                                      });
                                    }
                                  },
                                  child: isLoading
                                      ? CircularProgressIndicator()
                                      : Text('Book Now'),
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
                  'Book',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: widget.size.width * 0.05,
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
