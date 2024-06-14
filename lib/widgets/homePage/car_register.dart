import 'dart:convert';
import 'dart:io';
import 'package:az_car_flutter_app/data/CarModelType.dart';
import 'package:az_car_flutter_app/data/DIstrict.dart';
import 'package:az_car_flutter_app/data/Province.dart';
import 'package:az_car_flutter_app/data/Ward.dart';
import 'package:az_car_flutter_app/services/get_api_services.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/user_model.dart';
import '../../page/home_page.dart';
import '../../page/login_register_page.dart';

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
  late String selectedFuelType = 'Gasoline';
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
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final _dialogTitleController = TextEditingController();
  final _initialDirectoryController = TextEditingController();
  final _fileExtensionController = TextEditingController();
  String? _fileName;
  String? _saveAsFileName;
  List<PlatformFile>? _paths;
  String? _directoryPath;
  String? _extension;
  bool _isLoading = false;
  bool _lockParentWindow = false;
  bool _userAborted = false;
  bool _multiPick = false;
  FileType _pickingType = FileType.any;
  String emailLogin = '';
  UserModel? user;
  Map<String, bool> serviceValues = {
    'map-service': false,
    'bluetooth-service': false,
    'camera360-service': false,
    'reverseCamera-service': false,
    'dashCamera-service': false,
    'parkingCamera-service': false,
    'impactSensor-service': false,
    'tireSensor-service': false,
    'headUp-service': false,
    'babySeat-service': false,
    'gps-service': false,
    'usb-service': false,
    'sunRoof-service': false,
    'spareTire-service': false,
    'dvd-service': false,
    'airBags-service': false,
    'etc-service': false,
    'bonnet-service': false,
  };

  @override
  void initState() {
    super.initState();
    fetchProvinceData();
    fetchBrandData();
    _fileExtensionController
        .addListener(() => _extension = _fileExtensionController.text);
    getUserData();
  }

  String hintPrice(String string) {
    int options = string.split('').where((c) => c == ',').length;
    if (options == 0) {
      return 'Recommended price: 100.000-399.000 VND/day';
    }
    if (options == 1) {
      return 'Recommended price: 400.000-699.000 VND/day';
    }
    if (options == 2) {
      return 'Recommended price : 700.000-999.000 VND/day';
    }
    if (options == 3) {
      return 'Recommended price : 1.000.000-1.500.000 VND/day ';
    }
    return 'Default Price';
  }

  String? checkPrice(String string, String price) {
    int options = string.split('').where((c) => c == ',').length;
    int priceCheck = int.parse(price);
    if (options == 0) {
      if (priceCheck > 399000 || priceCheck < 100000) {
        return 'Recommended price: 100.000-399.000 VND/day';
      }
    }
    if (options == 1) {
      if (priceCheck > 699000 || priceCheck < 400000) {
        return 'Recommended price: 400.000-699.000 VND/day';
      }
    }
    if (options == 2) {
      if (priceCheck > 999000 || priceCheck < 700000) {
        return 'Recommended price : 700.000-999.000 VND/day';
      }
    }
    if (options == 3) {
      if (priceCheck > 1500000 || priceCheck < 1000000) {
        return 'Recommended price : 1.000.000-1.500.000 VND/day ';
      }
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
        setState(() {
          user = model;
        });
        setState(() {
          _isLoading = true;
        });
        await Future.delayed(Duration(seconds: 2));
        setState(() {
          _isLoading = false;
        });
      }
      return null;
    }
    return null;
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
        'address':
            '${houseNo.text}, ${street.text}, ${ward.fullName}, ${district.fullName}, ${province.fullName}',
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

  Future<void> _sendData() async {
    if (_paths == null || _paths!.isEmpty || _paths!.length != 5) {
      print('Chưa chọn ảnh');
      Fluttertoast.showToast(
          msg: 'Images Error',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String email = prefs.getString('emailLogin')!;
    final String id = prefs.getString('id')!;
    Province province = provinces.firstWhere((i) => i.code == selectedProvince);
    District district = districts.firstWhere((i) => i.code == selectedDistrict);
    Ward ward = wards.firstWhere((i) => i.code == selectedWard);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiService.baseUrl}/api/auth/upload3'),
    );
    print('paths img count${_paths!.length}');
    var frontImg =
        await http.MultipartFile.fromPath('frontImg', _paths![0].path!);
    var insideImg =
        await http.MultipartFile.fromPath('insideImg', _paths![1].path!);
    var rightImg =
        await http.MultipartFile.fromPath('rightImg', _paths![2].path!);
    var leftImg =
        await http.MultipartFile.fromPath('leftImg', _paths![3].path!);
    var behindImg =
        await http.MultipartFile.fromPath('behindImg', _paths![4].path!);
    List<String> selectedServices = serviceValues.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    print('Selected Services: $selectedServices');
    request.files.add(frontImg);
    request.files.add(insideImg);
    request.files.add(rightImg);
    request.files.add(leftImg);
    request.files.add(behindImg);
    request.fields['data'] = jsonEncode({
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
      'address':
          '${houseNo.text}, ${street.text}, ${ward.fullName}, ${district.fullName}, ${province.fullName}',
      'deliveryFee': deliveryFee.text,
      'cleaningFee': cleaningFee.text,
      'decorationFee': decorationFee.text,
      'rules': rules.text,
      'userEmail': email,
      'userId': id,
      'services': selectedServices.toString(),
    });

    print(selectedBrand);
    print(selectedCarSampleModel);
    print(selectedYear);
    print(selectedCategory);
    print(seatQty.text);
    print(selectedFuelType);

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        String message = 'Great, your car is register successfully!';
        await Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
        Navigator.pop(context);
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
        // Handle your response data here if needed
      } else {
        print('Upload failed with status: ${response.statusCode}');
        // Handle error here
      }
      await response.stream.drain();
    } catch (e) {
      print('Exception during upload: $e');
      // Handle exception here
    }
  }

  void _pickFiles() async {
    _resetState();
    try {
      _directoryPath = null;
      _paths = (await FilePicker.platform.pickFiles(
        compressionQuality: 30,
        type: _pickingType,
        allowMultiple: true,
        onFileLoading: (FilePickerStatus status) => print(status),
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '').split(',')
            : null,
        dialogTitle: _dialogTitleController.text,
        initialDirectory: _initialDirectoryController.text,
        lockParentWindow: _lockParentWindow,
      ))
          ?.files;
    } on PlatformException catch (e) {
      _logException('Unsupported operation$e');
    } catch (e) {
      _logException(e.toString());
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _fileName =
          _paths != null ? _paths!.map((e) => e.name).toString() : '...';
      _userAborted = _paths == null;
      print(_paths);
    });
  }

  void _clearCachedFiles() async {
    _resetState();
    try {
      bool? result = await FilePicker.platform.clearTemporaryFiles();
      _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            (result!
                ? 'Temporary files removed with success.'
                : 'Failed to clean temporary files'),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    } on PlatformException catch (e) {
      _logException('Unsupported operation$e');
    } catch (e) {
      _logException(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _logException(String message) {
    print(message);
    _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _resetState() {
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
      _directoryPath = null;
      _fileName = null;
      _paths = null;
      _saveAsFileName = null;
      _userAborted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
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
              child: GestureDetector(
                onTap: () {
                  Get.to(() => HomePage());
                },
                child: Icon(
                  CommunityMaterialIcons.arrow_left_bold_circle,
                  color: themeData.secondaryHeaderColor,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leadingWidth: size.width * 0.15,
        title: Image.asset(
          alignment: Alignment.bottomCenter,
          themeData.brightness == Brightness.dark
              ? 'assets/images/logo-azcar.png'
              : 'assets/images/logo-azcar.png',
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
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                children: [
                  LoadingAnimationWidget.horizontalRotatingDots(
                    color: themeData.secondaryHeaderColor,
                    size: 100,
                  ),
                  Text('Your submit is on processing,'),
                  Text('Thank you for choosing Az Car'),
                ],
              ),
            )
          : user == null
              ? Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: size.height * 0.02,
                        left: size.width * 0.06,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Welcome to AzCar, ',
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: AnimatedButton(
                            height: 70,
                            width: MediaQuery.of(context).size.width / 2,
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
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: licenseController,
                          decoration: InputDecoration(
                            labelText: 'License Plate',
                            hintText: 'Example: 12A-12345',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'License Plate cannot be empty';
                            }
                            RegExp platePattern = RegExp(r'^\d{2}[A-Z]-\d{5}$');
                            if (!platePattern.hasMatch(value)) {
                              return 'Invalid License Plate format';
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
                          value:
                              selectedBrand.isNotEmpty ? selectedBrand : null,
                          hint: Text('Brand'),
                          onChanged: (String? newValue) async {
                            if (newValue != null) {
                              final carCates =
                                  await fetchCategoryData(newValue);
                              setState(() {
                                selectedBrand = newValue;
                                carCategories = carCates;
                                selectedCategory = '';
                              });
                            }
                          },
                          items: carBrands.map<DropdownMenuItem<String>>(
                              (String brandName) {
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
                            value: selectedCategory.isNotEmpty
                                ? selectedCategory
                                : null,
                            hint: Text('Category'),
                            onChanged: (String? newValue) async {
                              final carModels = await fetchCarSampleModelData(
                                  selectedBrand, newValue!);
                              setState(() {
                                selectedCategory = newValue;
                                carSampleModels = carModels;
                                selectedCarSampleModel = '';
                              });
                            },
                            items: carCategories.map<DropdownMenuItem<String>>(
                                (String brandName) {
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
                                .map<DropdownMenuItem<String>>(
                                    (String brandName) {
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
                            value:
                                selectedYear.isNotEmpty ? selectedYear : null,
                            hint: Text('Year'),
                            onChanged: (String? newValue) async {
                              setState(() {
                                selectedYear = newValue!;
                              });
                            },
                            items: carYears.map<DropdownMenuItem<String>>(
                                (String brandName) {
                              return DropdownMenuItem<String>(
                                value: brandName,
                                child: Text(brandName),
                              );
                            }).toList(),
                          ),
                        TextFormField(
                          controller: seatQty,
                          decoration: InputDecoration(
                            labelText: 'Seat Quantity',
                            hintText: 'Enter a number between 2 and 8',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Seat quantity cannot be empty';
                            }
                            RegExp numberPattern = RegExp(r'^[2-8]$');
                            if (!numberPattern.hasMatch(value)) {
                              return 'Please enter a number between 2 and 8';
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
                          decoration: InputDecoration(
                            labelText: 'Description',
                            hintText: 'Enter description',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Description cannot be empty';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: defaultPrice,
                          decoration: InputDecoration(
                              labelText: 'Default Price',
                              hintText: hintPrice(selectedCategory)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Default Price cannot be empty';
                            } else {
                              return checkPrice(selectedCategory, value);
                            }
                            // double? price = double.tryParse(value);
                            //
                            // if (price == null || price < 0) {
                            //   return 'Please enter a price greater than 0';
                            // }
                            // return null;
                          },
                        ),
                        TextFormField(
                          controller: discount,
                          decoration: InputDecoration(
                            labelText: 'Discount',
                            hintText: 'Enter a discount between 0 and 99',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Default Discount cannot be empty';
                            }
                            int? discountValue = int.tryParse(value);

                            if (discountValue == null ||
                                discountValue < 0 ||
                                discountValue > 99) {
                              return 'Please enter a discount between 0 and 99';
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
                              return 'Province must be selected';
                            }
                            return null;
                          },
                          value: selectedProvince.isNotEmpty
                              ? selectedProvince
                              : null,
                          hint: Text('Province'),
                          onChanged: (String? newValue) async {
                            if (newValue != null) {
                              final districts =
                                  await fetchDistrictData(newValue);
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
                            value: selectedDistrict.isNotEmpty
                                ? selectedDistrict
                                : null,
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
                            value:
                                selectedWard.isNotEmpty ? selectedWard : null,
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
                        DropdownButtonFormField<String>(
                          value: '0',
                          decoration: InputDecoration(
                            labelText: 'Delivery Fee',
                            hintText: 'Select a percentage',
                          ),
                          items: ['0', '10', '20', '30', '40', '50']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                  '$value%: ${double.parse(value) * double.parse(defaultPrice.text != '' ? defaultPrice.text : '0') / 100} VND'), // Hiển thị giá trị kèm dấu %
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            deliveryFee.text = newValue!;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a percentage';
                            }
                            return null;
                          },
                        ),
                        DropdownButtonFormField<String>(
                          value: '0',
                          decoration: InputDecoration(
                            labelText: 'Cleaning Fee',
                            hintText: 'Select a percentage',
                          ),
                          items: ['0', '10', '20', '30', '40', '50']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                  '$value%: ${double.parse(value) * double.parse(defaultPrice.text != '' ? defaultPrice.text : '0') / 100} VND'), // Hiển thị giá trị kèm dấu %
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            cleaningFee.text = newValue!;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a percentage';
                            }
                            return null;
                          },
                        ),
                        DropdownButtonFormField<String>(
                          value: '0',
                          decoration: InputDecoration(
                            labelText: 'Decoration Fee',
                            hintText: 'Select a percentage',
                          ),
                          items: ['0', '10', '20', '30', '40', '50']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                  '$value%: ${double.parse(value) * double.parse(defaultPrice.text != '' ? defaultPrice.text : '0') / 100} VND'), // Hiển thị giá trị kèm dấu %
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            decorationFee.text = newValue!;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a percentage';
                            }
                            return null;
                          },
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
                        for (var item in serviceValues.entries) ...{
                          CheckboxListTile(
                            title: Text(item.key),
                            value: serviceValues[item.key] ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                                serviceValues[item.key] = value ?? false;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        },
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                          child: SingleChildScrollView(
                            padding:
                                const EdgeInsets.only(left: 15.0, right: 15.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20.0, bottom: 20.0),
                                  child: Wrap(
                                    spacing: 10.0,
                                    runSpacing: 10.0,
                                    children: <Widget>[
                                      SizedBox(
                                        width: 200,
                                        child: FloatingActionButton.extended(
                                            onPressed: () => _pickFiles(),
                                            label: Text(_multiPick
                                                ? 'Choose  Car\'s Image'
                                                : 'Choose  Car\'s Image'),
                                            icon:
                                                const Icon(Icons.description)),
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: FloatingActionButton.extended(
                                          onPressed: () => _clearCachedFiles(),
                                          label:
                                              const Text('Clear all Images '),
                                          icon:
                                              const Icon(Icons.delete_forever),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Text(
                                  'Image Picker Info',
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                // Builder(
                                //   builder: (BuildContext context) => _isLoading
                                //       ? Row(
                                //           children: [
                                //             Expanded(
                                //               child: Center(
                                //                 child: Padding(
                                //                   padding: const EdgeInsets
                                //                       .symmetric(
                                //                     vertical: 40.0,
                                //                   ),
                                //                   child:
                                //                       const CircularProgressIndicator(),
                                //                 ),
                                //               ),
                                //             ),
                                //           ],
                                //         )
                                //       : _userAborted
                                //           ? Row(
                                //               children: [
                                //                 Expanded(
                                //                   child: Center(
                                //                     child: SizedBox(
                                //                       width: 300,
                                //                       child: ListTile(
                                //                         leading: Icon(
                                //                           Icons.error_outline,
                                //                         ),
                                //                         contentPadding:
                                //                             EdgeInsets
                                //                                 .symmetric(
                                //                                     vertical:
                                //                                         40.0),
                                //                         title: const Text(
                                //                           'User has aborted the dialog',
                                //                         ),
                                //                       ),
                                //                     ),
                                //                   ),
                                //                 ),
                                //               ],
                                //             )
                                //           : _directoryPath != null
                                //               ? ListTile(
                                //                   title: const Text(
                                //                       'Directory path'),
                                //                   subtitle:
                                //                       Text(_directoryPath!),
                                //                 )
                                //               : _paths != null
                                //                   ? Container(
                                //                       padding: const EdgeInsets
                                //                           .symmetric(
                                //                         vertical: 20.0,
                                //                       ),
                                //                       height:
                                //                           MediaQuery.of(context)
                                //                                   .size
                                //                                   .height *
                                //                               0.50,
                                //                       child: Scrollbar(
                                //                           child: ListView
                                //                               .separated(
                                //                         itemCount: _paths !=
                                //                                     null &&
                                //                                 _paths!
                                //                                     .isNotEmpty
                                //                             ? _paths!.length
                                //                             : 1,
                                //                         itemBuilder:
                                //                             (BuildContext
                                //                                     context,
                                //                                 int index) {
                                //                           final bool
                                //                               isMultiPath =
                                //                               _paths != null &&
                                //                                   _paths!
                                //                                       .isNotEmpty;
                                //                           final String name = 'File $index: ${isMultiPath
                                //                                   ? _paths!
                                //                                           .map((e) => e
                                //                                               .name)
                                //                                           .toList()[
                                //                                       index]
                                //                                   : _fileName ??
                                //                                       '...'}';
                                //                           final path = kIsWeb
                                //                               ? null
                                //                               : _paths!
                                //                                   .map((e) =>
                                //                                       e.path)
                                //                                   .toList()[
                                //                                       index]
                                //                                   .toString();
                                //
                                //                           return ListTile(
                                //                             title: Text(
                                //                               name,
                                //                             ),
                                //                             subtitle: Text(
                                //                                 path ?? ''),
                                //                           );
                                //                         },
                                //                         separatorBuilder:
                                //                             (BuildContext
                                //                                         context,
                                //                                     int index) =>
                                //                                 const Divider(),
                                //                       )),
                                //                     )
                                //                   : _saveAsFileName != null
                                //                       ? ListTile(
                                //                           title: const Text(
                                //                               'Save file'),
                                //                           subtitle: Text(
                                //                               _saveAsFileName!),
                                //                         )
                                //                       : const SizedBox(),
                                // ),
                          Builder(
                            builder: (BuildContext context) => _isLoading
                                ? Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 40.0,
                                      ),
                                      child: const CircularProgressIndicator(),
                                    ),
                                  ),
                                ),
                              ],
                            )
                                : _userAborted
                                ? Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: SizedBox(
                                      width: 300,
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.error_outline,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 40.0,
                                        ),
                                        title: const Text(
                                          'User has aborted the dialog',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                                : _directoryPath != null
                                ? ListTile(
                              title: const Text('Directory path'),
                              subtitle: Text(_directoryPath!),
                            )
                                : _paths != null
                                ? Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                              ),
                              height: MediaQuery.of(context).size.height * 0.50,
                              child: Scrollbar(
                                child: ListView.separated(
                                  itemCount: _paths != null && _paths!.isNotEmpty
                                      ? _paths!.length
                                      : 1,
                                  itemBuilder: (BuildContext context, int index) {
                                    if (_paths == null || _paths!.isEmpty) {
                                      return Center(child: Text('No files selected'));
                                    }

                                    final String fileName = _paths![index].name;
                                    final String filePath = _paths![index].path ?? '';

                                    // Kiểm tra nếu đường dẫn là null (đối với web)
                                    if (filePath.isEmpty) {
                                      return ListTile(
                                        title: Text('File $index: $fileName'),
                                        subtitle: Text('No local path'),
                                      );
                                    }

                                    // Hiển thị hình ảnh nếu đường dẫn hợp lệ
                                    if (fileName.toLowerCase().endsWith('.jpg') ||
                                        fileName.toLowerCase().endsWith('.jpeg') ||
                                        fileName.toLowerCase().endsWith('.png')) {
                                      return ListTile(
                                        title: Text('Image $index: $fileName'),
                                        subtitle: Image.file(File(filePath)),
                                      );
                                    }

                                    // Hiển thị thông tin tệp cho các tệp khác
                                    return ListTile(
                                      title: Text('File $index: $fileName'),
                                      subtitle: Text(filePath),
                                    );
                                  },
                                  separatorBuilder: (BuildContext context, int index) =>
                                  const Divider(),
                                ),
                              ),
                            )
                                : _saveAsFileName != null
                                ? ListTile(
                              title: const Text('Save file'),
                              subtitle: Text(_saveAsFileName!),
                            )
                                : const SizedBox(),
                          ),

                          SizedBox(
                                  height: 40.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: FloatingActionButton.extended(
                            label: const Text('Submit this Car'),
                            icon: const Icon(Icons.upgrade_outlined),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });
                                try {
                                  _sendData();
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                            },
                            // child: isLoading
                            //     ? CircularProgressIndicator()
                            //     : Text('Registration Submit'),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
    );
  }
}
