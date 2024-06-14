import 'dart:convert';

import 'package:az_car_flutter_app/data/OrderDetailsRaw.dart';
import 'package:az_car_flutter_app/data/carModel.dart';
import 'package:az_car_flutter_app/services/get_api_services.dart';
import 'package:az_car_flutter_app/widgets/detailsPage/bookingWidget.dart';
import 'package:az_car_flutter_app/widgets/detailsPage/carDetailsWidget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailsPage extends StatefulWidget {
  final CarModel car;

  const DetailsPage({
    super.key,
    required this.car,
  });

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late bool isLogin = false;
  late bool isPopLoading = false;
  late bool isOwner = false;
  late List<String> images;
  late List<String> orderSetDates = [];
  late List<OrderDetailsRaw> orderListOfThisCar = [];

  @override
  void initState() {
    super.initState();
    images = widget.car.images.map((image) => '${ApiService.baseUrl}/home/availablecars/flutter/img/${image.urlImage.toString()}').toList();
    fetchOrderSetDates(widget.car.id.toString());
    fetchOrderList(widget.car.id.toString());
    isOwnerFunc();
  }

  Future<void> fetchOrderSetDates(String carId) async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/api/cars/getOrderOfThisCar?carId=$carId'), headers: {'Content-Type': 'application/json'});
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

  Future<void> fetchOrderList(String carId) async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/api/cars/getOrderOfThisCar?carId=$carId'), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        orderListOfThisCar = data.map((json) => OrderDetailsRaw.fromMap(json)).toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> isLoginCheck() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('id')!;
    if (userId != '') {
      setState(() {
        isLogin = true;
      });
    }
  }

  Future<void> isOwnerFunc() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('id')!;
    setState(() {
      isOwner = widget.car.carOwnerId.toString() == userId;
    });
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
                                    margin: EdgeInsets.symmetric(horizontal: 1.0),
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
                      child: CarDetailsWidget(car: widget.car, size: size, themeData: themeData),
                    ),
                    if (orderSetDates.isNotEmpty)
                      SizedBox(
                        width: size.width * 0.9,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                                  child: Text(
                                    'Booked Dates', // Tiêu đề
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xff3b22a1),
                                    ),
                                  ),
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
                    isLogin && !isOwner
                        ? Padding(
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
                            style: TextStyle(fontSize: 18.0, color: Colors.white),
                          ),
                        ),
                      ),
                    )
                        : Column(children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Text(
                          'Orders of [${widget.car.carmodel.brand}] - ${widget.car.carmodel.model}', // Tiêu đề
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff3b22a1),
                          ),
                        ),
                      ),
                      orderListOfThisCar.isEmpty
                          ? Container(
                          decoration: BoxDecoration(
                            color: themeData.cardColor,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.05,
                              vertical: size.height * 0.015,
                            ),
                            child: Text(
                              'No orders currently',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: themeData.primaryColor,
                                fontSize: size.width * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ))
                          : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: orderListOfThisCar.length,
                        itemBuilder: (context, index) {
                          OrderDetailsRaw order = orderListOfThisCar[index];
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 25.0),
                                  title: Text('Order ID: ${order.id}'),
                                  subtitle: Text('[${widget.car.carmodel.brand}] ${widget.car.carmodel.model}'),
                                  trailing: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        order.statusOnView,
                                        style: TextStyle(
                                          color: order.statusOnView == 'DECLINED' || order.statusOnView == 'RENTOR DECLINED'
                                              ? Colors.red
                                              : (order.statusOnView == 'ACCEPTED' || order.statusOnView == 'OWNER TRIP DONE' ? Colors.green : Colors.orange),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'From: ${order.fromDate}',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        'To: ${order.toDate}',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8),
                                order.status == 'waiting_for_accept'
                                    ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                                        backgroundColor: themeData.secondaryHeaderColor,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Confirmation'),
                                              content: Text('Are you sure you want to proceed?'),
                                              actions: [
                                                if (isPopLoading)
                                                  CircularProgressIndicator()
                                                else
                                                  Row(
                                                    children: [
                                                      TextButton(
                                                        onPressed: () async {
                                                          setState(() {
                                                            isPopLoading = true;
                                                          });
                                                          final response = await http.get(Uri.parse('${ApiService.baseUrl}/api/cars/ownerAccepted?orderId=${order.id}'),
                                                              headers: {'Content-Type': 'application/json'});
                                                          Navigator.of(context).pop();
                                                          if (response.statusCode == 200) {
                                                            await Fluttertoast.showToast(
                                                                msg: 'Successfully accept rental',
                                                                toastLength: Toast.LENGTH_LONG,
                                                                gravity: ToastGravity.TOP,
                                                                timeInSecForIosWeb: 5,
                                                                backgroundColor: Colors.green,
                                                                textColor: Colors.white,
                                                                fontSize: 16.0);
                                                            setState(() {
                                                              isPopLoading = false;
                                                            });
                                                          } else {
                                                            await Fluttertoast.showToast(
                                                                msg: 'Failed, try again',
                                                                toastLength: Toast.LENGTH_LONG,
                                                                gravity: ToastGravity.TOP,
                                                                timeInSecForIosWeb: 5,
                                                                backgroundColor: Colors.red,
                                                                textColor: Colors.white,
                                                                fontSize: 16.0);
                                                          }
                                                        },
                                                        child: Text('Yes'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                        child: Text('No'),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Text(
                                        'Accept Order',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Confirmation'),
                                              content: Text('Are you sure you want to proceed?'),
                                              actions: [
                                                if (isPopLoading)
                                                  CircularProgressIndicator()
                                                else
                                                  Row(
                                                    children: [
                                                      TextButton(
                                                        onPressed: () async {
                                                          setState(() {
                                                            isPopLoading = true;
                                                          });
                                                          final response = await http.get(Uri.parse('${ApiService.baseUrl}/api/cars/ownerDeclined?orderId=${order.id}'),
                                                              headers: {'Content-Type': 'application/json'});
                                                          Navigator.of(context).pop();
                                                          if (response.statusCode == 200) {
                                                            await Fluttertoast.showToast(
                                                                msg: 'Successfully cancel order',
                                                                toastLength: Toast.LENGTH_LONG,
                                                                gravity: ToastGravity.TOP,
                                                                timeInSecForIosWeb: 5,
                                                                backgroundColor: Colors.green,
                                                                textColor: Colors.white,
                                                                fontSize: 16.0);
                                                            setState(() {
                                                              isPopLoading = false;
                                                            });
                                                            Navigator.pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => DetailsPage(car: widget.car),
                                                              ),
                                                            );
                                                          } else {
                                                            await Fluttertoast.showToast(
                                                                msg: 'Failed, try again',
                                                                toastLength: Toast.LENGTH_LONG,
                                                                gravity: ToastGravity.TOP,
                                                                timeInSecForIosWeb: 5,
                                                                backgroundColor: Colors.red,
                                                                textColor: Colors.white,
                                                                fontSize: 16.0);
                                                          }
                                                        },
                                                        child: Text('Yes'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                        child: Text('No'),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Text(
                                        'Cancel Order',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                )
                                    : order.status == 'rentor_trip_done'
                                    ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                                    backgroundColor: themeData.secondaryHeaderColor,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Confirmation'),
                                          content: Text('Are you sure you want to proceed?'),
                                          actions: [
                                            if (isPopLoading)
                                              CircularProgressIndicator()
                                            else
                                              Row(
                                                children: [
                                                  TextButton(
                                                    onPressed: () async {
                                                      setState(() {
                                                        isPopLoading = true;
                                                      });
                                                      String carId = widget.car.id.toString();
                                                      String orderId = order.id.toString();
                                                      bool smellCheck = true;
                                                      bool cleanCheck = true;
                                                      String description = "Very good";
                                                      final response = await http.get(
                                                          Uri.parse(
                                                              '${ApiService.baseUrl}/api/cars/ownerFinishReview?cleanCheck=$cleanCheck&smellCheck=$smellCheck&description=$description&carId=$carId&orderId=$orderId'),
                                                          headers: {'Content-Type': 'application/json'});
                                                      Navigator.of(context).pop();
                                                      if (response.statusCode == 200) {
                                                        await Fluttertoast.showToast(
                                                            msg: 'Successfully send review',
                                                            toastLength: Toast.LENGTH_LONG,
                                                            gravity: ToastGravity.TOP,
                                                            timeInSecForIosWeb: 5,
                                                            backgroundColor: Colors.green,
                                                            textColor: Colors.white,
                                                            fontSize: 16.0);
                                                        setState(() {
                                                          isPopLoading = false;
                                                        });
                                                        Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => DetailsPage(car: widget.car),
                                                          ),
                                                        );
                                                      } else {
                                                        await Fluttertoast.showToast(
                                                            msg: 'Failed, try again',
                                                            toastLength: Toast.LENGTH_LONG,
                                                            gravity: ToastGravity.TOP,
                                                            timeInSecForIosWeb: 5,
                                                            backgroundColor: Colors.red,
                                                            textColor: Colors.white,
                                                            fontSize: 16.0);
                                                      }
                                                    },
                                                    child: Text('Yes'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Text('No'),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    'Rental Review',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                                    : SizedBox(),
                              ],
                            ),
                          );
                        },
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
                    ]),
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