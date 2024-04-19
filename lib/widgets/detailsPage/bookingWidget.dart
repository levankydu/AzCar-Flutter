import 'dart:convert';

import 'package:az_car_flutter_app/data/DIstrict.dart';
import 'package:az_car_flutter_app/data/Province.dart';
import 'package:az_car_flutter_app/data/Ward.dart';
import 'package:az_car_flutter_app/data/carModel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:az_car_flutter_app/services/get_api_services.dart';

class BookingWidget extends StatefulWidget {
  final CarModel car;

  const BookingWidget({super.key, required this.car});

  @override
  State<BookingWidget> createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController fromDateController = TextEditingController();
  late TextEditingController toDateController = TextEditingController();
  late TextEditingController houseNo = TextEditingController();
  late TextEditingController street = TextEditingController();
  late List<Province> provinces = [];
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
  void initState() {
    super.initState();
    fetchProvinceData();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Booking'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: fromDateController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'From Date',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'From Date cannot be empty';
                  }
                  return null;
                },
                onTap: () async {
                  DateTime initialDate = fromDateController.text.isNotEmpty
                      ? DateFormat('dd-MM-yyyy HH:mm:ss.S')
                          .parse('${fromDateController.text} 00:00:00.000')
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
                    DateTime toDate = fromDate.add(Duration(days: 1));
                    String formattedFromDate =
                        DateFormat('dd-MM-yyyy').format(fromDate);
                    String formattedToDate =
                        DateFormat('dd-MM-yyyy').format(toDate);
                    fromDateController.text = formattedFromDate;
                    toDateController.text = formattedToDate;
                    setState(() {});
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: toDateController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'To Date',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'To Date cannot be empty';
                  }
                  return null;
                },
                onTap: () async {
                  DateTime initialDate = toDateController.text.isNotEmpty
                      ? DateFormat('dd-MM-yyyy HH:mm:ss.S')
                          .parse('${toDateController.text} 00:00:00.000')
                      : (fromDateController.text.isNotEmpty
                          ? DateFormat('dd-MM-yyyy')
                              .parse(fromDateController.text)
                          : DateTime.now());
                  DateTime firstSelectableDate = DateTime.now();
                  if (fromDateController.text.isNotEmpty) {
                    firstSelectableDate =
                        DateFormat('dd-MM-yyyy').parse(fromDateController.text);
                  }
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: firstSelectableDate,
                    lastDate: DateTime(2026),
                    selectableDayPredicate: (DateTime date) {
                      if (fromDateController.text.isNotEmpty) {
                        DateTime fromDate = DateFormat('dd-MM-yyyy')
                            .parse(fromDateController.text);
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
                        DateFormat('dd-MM-yyyy').format(pickedDate);
                    toDateController.text = formattedDate;
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
              TextFormField(
                controller: houseNo,
                decoration: InputDecoration(labelText: 'House No'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'House No cannot be empty';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: street,
                decoration: InputDecoration(labelText: 'Street Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Street Name cannot be empty';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Province cannot be empty';
                  }
                  return null;
                },
                value: selectedProvince.isNotEmpty ? selectedProvince : null,
                hint: Text('Province'),
                onChanged: (String? newValue) async {
                  if (newValue != null) {
                    final districts = await fetchDistrictData(newValue);
                    setState(() {
                      selectedProvince = newValue;
                      this.districts = districts;
                      selectedDistrict = '';
                    });
                  }
                },
                items: provinces.map((Province province) {
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'District cannot be empty';
                    }
                    return null;
                  },
                  value: selectedDistrict.isNotEmpty ? selectedDistrict : null,
                  hint: Text('District'),
                  onChanged: (String? newValue) async {
                    final wards = await fetchWardData(newValue!);
                    setState(() {
                      selectedDistrict = newValue;
                      this.wards = wards;
                      selectedWard = '';
                    });
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ward cannot be empty';
                    }
                    return null;
                  },
                  value: selectedWard.isNotEmpty ? selectedWard : null,
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
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        prefs = await SharedPreferences.getInstance();
                        final String email = prefs.getString('emailLogin')!;
                        final String id = prefs.getString('id')!;
                        Province province = provinces
                            .firstWhere((i) => i.code == selectedProvince);
                        District district = districts
                            .firstWhere((i) => i.code == selectedDistrict);
                        Ward ward =
                            wards.firstWhere((i) => i.code == selectedWard);
                        final response = await http.post(
                          Uri.parse(
                              '${ApiService.baseUrl}/api/cars/postOrderDetails'),
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                          },
                          body: jsonEncode(<String, String>{
                            'fromDate': fromDateController.text,
                            'toDate': toDateController.text,
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
                              backgroundColor: response.body == message
                                  ? Colors.green
                                  : Colors.amber,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          if (response.body == message) {
                            setState(() {
                              fromDateController.text = '';
                              toDateController.text = '';
                              houseNo.text = '';
                              street.text = '';
                              selectedProvince = '';
                              selectedDistrict = '';
                              selectedWard = '';
                            });
                          }
                          Navigator.pop(context);
                        } else {
                          await Fluttertoast.showToast(
                            msg: 'Something happened, please try again',
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
                    }
                  },
                  child: isLoading
                      ? CircularProgressIndicator()
                      : Text('Book Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
