import 'package:az_car_flutter_app/page/user_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Using GetX for navigation

class SuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Success'),
        backgroundColor: Colors.green, // Optional: Change color to signify success
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.green, // Green color to signify success
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Your transaction has been successfully completed!',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(()=>MyProfileScreen()); // Navigates back to the previous screen
              },
              child: Text('Back to Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Optional: Style the button
              ),
            )
          ],
        ),
      ),
    );
  }
}
