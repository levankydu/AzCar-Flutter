import 'dart:convert';

import 'package:az_car_flutter_app/data/OrderDetails.dart';
import 'package:az_car_flutter_app/page/login_register_page.dart';
import 'package:az_car_flutter_app/page/user_page.dart';
import 'package:az_car_flutter_app/services/get_api_services.dart';
import 'package:az_car_flutter_app/widgets/bottom_nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicons/unicons.dart';
import 'package:http/http.dart' as http;

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late List<OrderDetails> orderList = [];
  late bool isPopLoading = false;

  @override
  void initState() {
    super.initState();
    fetchOrderData();
  }

  Future<void> fetchOrderData() async {
    String userId;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool checkValue = prefs.containsKey('id');
    if (checkValue) {
      userId = prefs.getString('id')!;
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/api/cars/getOrderByUser?userId=$userId'), headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          orderList = data.map((json) => OrderDetails.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } else {
      Get.to(() => LoginSignupScreen());
    }
  }

  bool isInDateRange(String fromDate, String toDate) {
    DateTime now = DateTime.now();
    DateTime fromDateTime = DateFormat('dd-MM-yyyy').parse(fromDate);
    DateTime toDateTime = DateFormat('dd-MM-yyyy').parse(toDate);
    return now.isAfter(fromDateTime) && now.isBefore(toDateTime);
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
                child: Icon(
                  UniconsLine.bars,
                  color: themeData.secondaryHeaderColor,
                  size: size.height * 0.025,
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
      bottomNavigationBar: buildBottomNavBar(1, size, themeData),
      backgroundColor: themeData.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: orderList.length,
                itemBuilder: (context, index) {
                  OrderDetails order = orderList[index];
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
                          subtitle: Text('[${order.car.carmodel.brand}] ${order.car.carmodel.model}'),
                          // Add other details here based on your requirements
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                order.statusOnView,
                                style: TextStyle(
                                  color: order.statusOnView == 'DECLINED' || order.statusOnView == 'RENTOR DECLINED'
                                      ? Colors.red
                                      : (order.statusOnView == 'ACCEPTED' || order.statusOnView == 'OWNER TRIP DONE' ? Colors.green : Colors.orange), // Màu chữ
                                ),
                              ),
                              SizedBox(height: 4),
                              // Add some spacing between status and date
                              Text(
                                'From: ${order.fromDate}',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12, // Adjust font size as needed
                                ),
                              ),
                              Text(
                                'To: ${order.toDate}',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12, // Adjust font size as needed
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        // Add some spacing before the button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            isInDateRange(order.fromDate, order.toDate) && order.statusOnView == 'ACCEPTED'
                                ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                                backgroundColor: themeData.secondaryHeaderColor,
                              ),
                              onPressed: () {
                                // Hiển thị popup yes/no
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    bool isPopLoading = false;
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                          title: Text('Confirmation'),
                                          content: isPopLoading
                                              ? Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              CircularProgressIndicator(),
                                            ],
                                          )
                                              : Text('Are you sure you want to proceed?'),
                                          actions: isPopLoading
                                              ? []
                                              : [
                                            Row(
                                              children: [
                                                TextButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      isPopLoading = true;
                                                    });
                                                    final response = await http.get(Uri.parse('${ApiService.baseUrl}/api/cars/userRentalDone?orderId=${order.id}'), headers: {'Content-Type': 'application/json'});
                                                    Navigator.of(context).pop();
                                                    if (response.statusCode == 200) {
                                                      await Fluttertoast.showToast(
                                                          msg: 'Successfully finish rental',
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
                                                          builder: (context) => OrderPage(),
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
                                                      setState(() {
                                                        isPopLoading = false;
                                                      });
                                                    }
                                                  },
                                                  child: Text('Yes'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    // Hành động khi bấm No
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
                                );
                              },
                              child: Text(
                                'Finished Rental',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                                : SizedBox(),
                            !isInDateRange(order.fromDate, order.toDate) && (order.statusOnView == 'ACCEPTED' || order.statusOnView == 'WAITING FOR ACCEPT')
                                ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                                backgroundColor: Colors.redAccent,
                              ),
                              onPressed: () {
                                // Hiển thị popup yes/no
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    bool isPopLoading = false;
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                          title: Text('Confirmation'),
                                          content: isPopLoading
                                              ? Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              CircularProgressIndicator(),
                                            ],
                                          )
                                              : Text('Are you sure you want to proceed?'),
                                          actions: isPopLoading
                                              ? []
                                              : [
                                            Row(
                                              children: [
                                                TextButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      isPopLoading = true;
                                                    });
                                                    final response = await http.get(Uri.parse('${ApiService.baseUrl}/api/cars/userCancel?orderId=${order.id}'), headers: {'Content-Type': 'application/json'});
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
                                                          builder: (context) => OrderPage(),
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
                                                      setState(() {
                                                        isPopLoading = false;
                                                      });
                                                    }
                                                  },
                                                  child: Text('Yes'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    // Hành động khi bấm No
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
                                );
                              },
                              child: Text(
                                'Cancel Order',
                                style: TextStyle(color: Colors.white),
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
        ),
      ),
    );
  }
}
