import 'package:az_car_flutter_app/page/home_page.dart';
import 'package:az_car_flutter_app/page/token_page.dart';
import 'package:az_car_flutter_app/services/get_api_services.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailController = TextEditingController();
  bool _showEmailError =
      false; // Variable to control whether to show email error or not
      String email= '';

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: 20), // Added horizontal padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button and title
            Padding(
              padding: const EdgeInsets.only(top: 50, bottom: 20),
              child: Row(
                children: [
                  IconButton(
                    alignment: Alignment.topLeft,
                    icon: Icon(
                      CommunityMaterialIcons.arrow_left_bold_circle,
                      color: Colors.black, // Set back button color to black
                      size: 40,
                    ),
                    onPressed: () {
                      Navigator.pop(
                          context); // Navigate back to the previous screen
                    },
                  ),
                  Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontSize: 25,
                      letterSpacing: 2,
                      color: Colors.black, // Set title color to black
                    ),
                  ),
                ],
              ),
            ),
            // Email input field
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Enter your email',
                labelStyle: TextStyle(
                    color: Colors.black), // Set label text color to black
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black), // Set enabled border color to black
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black), // Set focused border color to black
                ),
                errorText: _showEmailError
                    ? 'Vui lòng nhập email'
                    : null, // Show error text only when needed
              ),
              style: TextStyle(color: Colors.black), // Set text color to black
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                setState(() {
                  _showEmailError = value
                      .isEmpty; // Set _showEmailError based on whether email is empty
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Send'),
              onPressed: () async {
                String email = emailController.text;
                if (email.isEmpty) {
                  // If email is empty, set _showEmailError to true to show error message
                  setState(() {
                    _showEmailError = true;
                  });
                  return;
                }
                bool success = await ApiService.forgotPassword(email);

                if (success) {
                  // Show a success message
                  _showSnackBar(
                      context, 'Password reset email sent successfully', true);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TokenPageProcess()),
                  );
                } else {
                  // Show an error message
                  _showSnackBar(
                      context, 'Email not found!', false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, bool isSuccess) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
