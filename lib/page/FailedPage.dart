import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Using GetX for navigation if necessary

class FailedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Failed'),
        backgroundColor: Colors.red, // Red color to signify failure
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 100,
              color: Colors.red, // Red color to signify an error
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Something error!!',
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
                Get.back(); // Navigates back to the previous screen or retries the operation
              },
              child: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Style the button with a red color
              ),
            )
          ],
        ),
      ),
    );
  }
}
