import 'dart:convert';

import 'package:az_car_flutter_app/data/CarModelType.dart';
import 'package:az_car_flutter_app/data/DIstrict.dart';
import 'package:az_car_flutter_app/data/Province.dart';
import 'package:az_car_flutter_app/data/Ward.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:az_car_flutter_app/services/get_api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarRegister extends StatefulWidget {
  const CarRegister({super.key});

  @override
  State<CarRegister> createState() => _CarRegisterState();
}

class _CarRegisterState extends State<CarRegister> {
  final _formKey = GlobalKey<FormState>();
  late List<CarModelType> carModelType = [];
  late List<Province> provinces = [];
  late String selectedProvince = '';
  late List<District> districts = [];
  late String selectedDistrict = '';
  late List<Ward> wards = [];
  late String selectedWard = '';
  late List<String> carBrands = [];
  late String selectedBrand = '';
  late List<String> carCategories = [];
  late String selectedCategory = '';
  late List<String> carSampleModels = [];
  late String selectedCarSampleModel = '';
  late List<String> carYears = [];
  late String selectedYear = '';
  late TextEditingController licenseController = TextEditingController();
  late TextEditingController seatQty = TextEditingController();
  static const List<String> fuelType = ['Gasoline', 'Diesel Oil', 'Electric'];
  late String selectedFuelType = '';
  late TextEditingController description = TextEditingController();
  late TextEditingController defaultPrice = TextEditingController();
  late TextEditingController discount = TextEditingController();
  late TextEditingController houseNo = TextEditingController();
  late TextEditingController street = TextEditingController();
  late TextEditingController deliveryFee = TextEditingController();
  late TextEditingController cleaningFee = TextEditingController();
  late TextEditingController decorationFee = TextEditingController();
  late TextEditingController rules = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchProvinceData();
    fetchBrandData();
  }

  Future<void> fetchBrandData() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/api/cars/getBrands'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        carBrands = data.cast<String>();
      });
    } else {
      throw Exception('Failed to load Brand');
    }
  }

  Future<List<String>> fetchCategoryData(String brandName) async {
    String url =
        '${ApiService.baseUrl}/api/cars/getCategoryListByBrand?brandName=$brandName';
    final response = await http
        .get(headers: {'Content-Type': 'application/json'}, Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return carCategories = data.cast<String>();
    } else {
      throw Exception('Failed to load Category');
    }
  }

  Future<List<String>> fetchCarSampleModelData(
      String brandName, String cateName) async {
    String url =
        '${ApiService.baseUrl}/api/cars/getModelListByCateAndBrand?brandName=$brandName&cateName=$cateName';
    final response = await http
        .get(headers: {'Content-Type': 'application/json'}, Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return carSampleModels = data.cast<String>();
    } else {
      throw Exception('Failed to load CarSampleModel');
    }
  }

  Future<List<String>> fetchCarYearData(
      String brandName, String cateName, String modelName) async {
    String url =
        '${ApiService.baseUrl}/api/cars/getYearList?brandName=$brandName&cateName=$cateName&modelName=$modelName';
    final response = await http
        .get(headers: {'Content-Type': 'application/json'}, Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return carYears = data.cast<String>();
    } else {
      throw Exception('Failed to load CarSampleModel');
    }
  }

  Future<void> fetchProvinceData() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/api/cars/getProvinces'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      List<Province> fetchedProvinces =
          data.map((json) => Province.fromJson(json)).toList();
      setState(() {
        provinces = fetchedProvinces;
      });
    } else {
      throw Exception('Failed to load Province');
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

  Future<void> submitFunction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String email = prefs.getString('emailLogin')!;
    final String id = prefs.getString('id')!;
    Province province = provinces.firstWhere((i) => i.code == selectedProvince);
    District district = districts.firstWhere((i) => i.code == selectedDistrict);
    Ward ward = wards.firstWhere((i) => i.code == selectedWard);
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/api/cars/postCarRegister'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'licensePlate': licenseController.text,
        'brand': selectedBrand,
        'category': selectedCategory,
        'model': selectedCarSampleModel,
        'year': selectedYear,
        'seatQty': seatQty.text,
        'fuelType': selectedFuelType,
        'description': description.text,
        'defaultPrice': defaultPrice.text,
        'discount': discount.text,
        'ward': ward.fullName,
        'district': district.fullName,
        'province': province.fullName,
        'houseNo': houseNo.text,
        'street': street.text,
        'deliveryFee': deliveryFee.text,
        'cleaningFee': cleaningFee.text,
        'decorationFee': decorationFee.text,
        'rules': rules.text,
        'userEmail': email,
        'userId': id,
      }),
    );
    if (response.statusCode == 200) {
      print(response.statusCode);
      print(response.body);
      String message = 'Great, your car is signed up successfully!';
      await Fluttertoast.showToast(
          msg: response.body,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 5,
          backgroundColor:
              response.body == message ? Colors.green : Colors.amber,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.pop(context);
      if (response.body == message) {
        setState(() {
          carModelType = [];
          provinces = [];
          selectedProvince = '';
          districts = [];
          selectedDistrict = '';
          wards = [];
          selectedWard = '';
          carBrands = [];
          selectedBrand = '';
          carCategories = [];
          selectedCategory = '';
          carSampleModels = [];
          selectedCarSampleModel = '';
          carYears = [];
          selectedYear = '';
          selectedFuelType = '';
        });
      }
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Register'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: licenseController,
                decoration: InputDecoration(labelText: 'License Plate'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'License Plate cannot be empty';
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
                    return 'Brand must be select';
                  }
                  return null;
                },
                value: selectedBrand.isNotEmpty ? selectedBrand : null,
                hint: Text('Brand'),
                onChanged: (String? newValue) async {
                  if (newValue != null) {
                    final carCates = await fetchCategoryData(newValue);
                    setState(() {
                      selectedBrand = newValue;
                      carCategories = carCates;
                      selectedCategory = '';
                    });
                  }
                },
                items:
                    carBrands.map<DropdownMenuItem<String>>((String brandName) {
                  return DropdownMenuItem<String>(
                    value: brandName,
                    child: Text(brandName),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              if (carCategories.isNotEmpty)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Category must be select';
                    }
                    return null;
                  },
                  value: selectedCategory.isNotEmpty ? selectedCategory : null,
                  hint: Text('Category'),
                  onChanged: (String? newValue) async {
                    final carModels =
                        await fetchCarSampleModelData(selectedBrand, newValue!);
                    setState(() {
                      selectedCategory = newValue;
                      carSampleModels = carModels;
                      selectedCarSampleModel = '';
                    });
                  },
                  items: carCategories
                      .map<DropdownMenuItem<String>>((String brandName) {
                    return DropdownMenuItem<String>(
                      value: brandName,
                      child: Text(brandName),
                    );
                  }).toList(),
                ),
              SizedBox(height: 20),
              if (carSampleModels.isNotEmpty)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Model must be select';
                    }
                    return null;
                  },
                  value: selectedCarSampleModel.isNotEmpty
                      ? selectedCarSampleModel
                      : null,
                  hint: Text('Model'),
                  onChanged: (String? newValue) async {
                    final carYears = await fetchCarYearData(
                        selectedBrand, selectedCategory, newValue!);
                    setState(() {
                      selectedCarSampleModel = newValue;
                      this.carYears = carYears;
                      selectedYear = '';
                    });
                  },
                  items: carSampleModels
                      .map<DropdownMenuItem<String>>((String brandName) {
                    return DropdownMenuItem<String>(
                      value: brandName,
                      child: Text(brandName),
                    );
                  }).toList(),
                ),
              SizedBox(height: 20),
              if (carYears.isNotEmpty)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Year must be select';
                    }
                    return null;
                  },
                  value: selectedYear.isNotEmpty ? selectedYear : null,
                  hint: Text('Year'),
                  onChanged: (String? newValue) async {
                    setState(() {
                      selectedYear = newValue!;
                    });
                  },
                  items: carYears
                      .map<DropdownMenuItem<String>>((String brandName) {
                    return DropdownMenuItem<String>(
                      value: brandName,
                      child: Text(brandName),
                    );
                  }).toList(),
                ),
              TextFormField(
                controller: seatQty,
                decoration: InputDecoration(labelText: 'Seat Quantity'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seat quantity cannot be empty';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: fuelType[0],
                onChanged: (newValue) {
                  setState(() {
                    selectedFuelType = newValue!;
                  });
                },
                items: fuelType.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Fuel Type'),
              ),
              TextFormField(
                controller: description,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description cannot be empty';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: defaultPrice,
                decoration: InputDecoration(labelText: 'Default Price'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Default Price cannot be empty';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: discount,
                decoration: InputDecoration(labelText: 'Discount'),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Province must be selected';
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
                      return 'District must be selected';
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
                      return 'Ward must be selected';
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
              TextFormField(
                controller: deliveryFee,
                decoration: InputDecoration(labelText: 'Delivery Fee'),
              ),
              TextFormField(
                controller: cleaningFee,
                decoration: InputDecoration(labelText: 'Cleaning Fee'),
              ),
              TextFormField(
                controller: decorationFee,
                decoration: InputDecoration(labelText: 'Decoration Fee'),
              ),
              TextFormField(
                controller: rules,
                decoration: InputDecoration(labelText: 'Rules'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Rules cannot be empty';
                  }
                  return null;
                },
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
                        // await submitFunction();
                        // chỗ này là submit nè thầy dự, thầy đợi tui rảnh thì tui làm dùm, còn không thì thêm tiền thì tui rảnh liền
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  },
                  child: isLoading
                      ? CircularProgressIndicator()
                      : Text('Registration Submit'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
