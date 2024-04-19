import 'dart:convert';
import 'package:az_car_flutter_app/data/OrderDetailsRaw.dart';
import 'package:az_car_flutter_app/widgets/detailsPage/bookingWidget.dart';
import 'package:az_car_flutter_app/widgets/detailsPage/carDetailsWidget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  late bool isPopLoading = false;
  late bool isOwner = false;
  late List<String> images;
  late List<String> orderSetDates = [];
  late List<OrderDetailsRaw> orderListOfThisCar = [];

  @override
  void initState() {
    super.initState();
    images = widget.car.images
        .map((image) =>
            '${ApiService.baseUrl}/home/availablecars/flutter/img/${image.urlImage.toString()}')
        .toList();
    fetchOrderSetDates(widget.car.id.toString());
    fetchOrderList(widget.car.id.toString());
    isOwnerFunc();
  }

  Future<void> fetchOrderSetDates(String carId) async {
    final response = await http.get(
        Uri.parse(
            '${ApiService.baseUrl}/api/cars/getOrderOfThisCar?carId=$carId'),
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

  Future<void> fetchOrderList(String carId) async {
    final response = await http.get(
        Uri.parse(
            '${ApiService.baseUrl}/api/cars/getOrderOfThisCar?carId=$carId'),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        orderListOfThisCar =
            data.map((json) => OrderDetailsRaw.fromMap(json)).toList();
      });
    } else {
      throw Exception('Failed to load data');
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
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Bo góc của box
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
                    !isOwner
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
                                      builder: (context) =>
                                          BookingWidget(car: widget.car),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  backgroundColor:
                                      themeData.secondaryHeaderColor,
                                ),
                                child: Text(
                                  'Book This Car',
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: orderListOfThisCar.length,
                                itemBuilder: (context, index) {
                                  OrderDetailsRaw order =
                                      orderListOfThisCar[index];
                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 20.0),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 15.0, horizontal: 25.0),
                                          title: Text('Order ID: ${order.id}'),
                                          subtitle: Text(
                                              '[${widget.car.carmodel.brand}] ${widget.car.carmodel.model}'),
                                          // Add other details here based on your requirements
                                          trailing: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                order.statusOnView,
                                                style: TextStyle(
                                                  color: order.statusOnView ==
                                                              'DECLINED' ||
                                                          order.statusOnView ==
                                                              'RENTOR DECLINED'
                                                      ? Colors.red
                                                      : (order.statusOnView ==
                                                                  'ACCEPTED' ||
                                                              order.statusOnView ==
                                                                  'OWNER TRIP DONE'
                                                          ? Colors.green
                                                          : Colors
                                                              .orange), // Màu chữ
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              // Add some spacing between status and date
                                              Text(
                                                'From: ${order.fromDate}',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize:
                                                      12, // Adjust font size as needed
                                                ),
                                              ),
                                              Text(
                                                'To: ${order.toDate}',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize:
                                                      12, // Adjust font size as needed
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        // Add some spacing before the button
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            order.statusOnView ==
                                                    'WAITING FOR ACCEPTED'
                                                ? ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 10.0,
                                                              horizontal: 15),
                                                      backgroundColor: themeData
                                                          .secondaryHeaderColor,
                                                    ),
                                                    onPressed: () {
                                                      // Hiển thị popup yes/no
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                                'Confirmation'),
                                                            content: Text(
                                                                'Are you sure you want to proceed?'),
                                                            actions: [
                                                              isPopLoading
                                                                  ? CircularProgressIndicator()
                                                                  : Row(
                                                                      children: [
                                                                        TextButton(
                                                                          onPressed:
                                                                              () async {
                                                                            setState(() {
                                                                              isPopLoading = true;
                                                                            });
                                                                            final response =
                                                                                await http.get(Uri.parse('${ApiService.baseUrl}/api/cars/ownerAccepted?orderId=${order.id}'), headers: {
                                                                              'Content-Type': 'application/json'
                                                                            });
                                                                            Navigator.of(context).pop();
                                                                            if (response.statusCode ==
                                                                                200) {
                                                                              await Fluttertoast.showToast(msg: 'Successfully accept rental', toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 5, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
                                                                              setState(() {
                                                                                isPopLoading = false;
                                                                              });
                                                                            } else {
                                                                              await Fluttertoast.showToast(msg: 'Failed, try again', toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 5, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
                                                                            }
                                                                          },
                                                                          child:
                                                                              Text('Yes'),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            // Hành động khi bấm No
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child:
                                                                              Text('No'),
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
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  )
                                                : SizedBox(),
                                            order.statusOnView ==
                                                    'WAITING FOR ACCEPT'
                                                ? ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 10.0,
                                                              horizontal: 15),
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                    ),
                                                    onPressed: () {
                                                      // Hiển thị popup yes/no
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                                'Confirmation'),
                                                            content: Text(
                                                                'Are you sure you want to proceed?'),
                                                            actions: [
                                                              isPopLoading
                                                                  ? CircularProgressIndicator()
                                                                  : Row(
                                                                      children: [
                                                                        TextButton(
                                                                          onPressed:
                                                                              () async {
                                                                            setState(() {
                                                                              isPopLoading = true;
                                                                            });
                                                                            final response =
                                                                                await http.get(Uri.parse('${ApiService.baseUrl}/api/cars/ownerDeclined?orderId=${order.id}'), headers: {
                                                                              'Content-Type': 'application/json'
                                                                            });
                                                                            Navigator.of(context).pop();
                                                                            if (response.statusCode ==
                                                                                200) {
                                                                              await Fluttertoast.showToast(msg: 'Successfully cancel order', toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 5, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
                                                                              setState(() {
                                                                                isPopLoading = false;
                                                                              });
                                                                            } else {
                                                                              await Fluttertoast.showToast(msg: 'Failed, try again', toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 5, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
                                                                            }
                                                                          },
                                                                          child:
                                                                              Text('Yes'),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            // Hành động khi bấm No
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child:
                                                                              Text('No'),
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
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  )
                                                : SizedBox(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
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
  }
}
