import 'package:az_car_flutter_app/data/user_model.dart';
import 'package:az_car_flutter_app/page/login_register_page.dart';
import 'package:az_car_flutter_app/services/get_api_services.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;

  ResetPasswordPage({Key? key, required this.token}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool _showPasswordError = false;
  bool _showConfirmPasswordError = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            child: Row(
              children: [
                IconButton(
                  alignment: Alignment.topLeft,
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 40,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 25,
                    letterSpacing: 2,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: 'Enter your new password',
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              errorText: _showPasswordError ? 'Please enter a password' : null,
            ),
            style: TextStyle(color: Colors.black),
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            onChanged: (value) {
              setState(() {
                _showPasswordError = value.isEmpty;
              });
            },
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm your new password',
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              errorText:
                  _showConfirmPasswordError ? 'Passwords do not match' : null,
            ),
            style: TextStyle(color: Colors.black),
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            onChanged: (value) {
              setState(() {
                _showConfirmPasswordError = value != passwordController.text;
              });
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            child: const Text('Submit'),
            onPressed: () async {
              String password = passwordController.text;
              String confirmPassword = confirmPasswordController.text;

              if (password.isEmpty || confirmPassword.isEmpty) {
                setState(() {
                  _showPasswordError = password.isEmpty;
                  _showConfirmPasswordError = confirmPassword.isEmpty;
                });
                return;
              }

              if (password != confirmPassword) {
                setState(() {
                  _showConfirmPasswordError = true;
                });
                return;
              }

              bool success = await ApiService.resetPassword(widget.token,password);
              if (success) {
                savePassword(password);
              } else {
                _showSnackBar(context, 'Password reset failed', false);
              }
            },
          ),
        ]),
      ),
    );
  }

  void savePassword(String password) {
    _showSnackBar(context, 'Password reset successfully', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginSignupScreen()),
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
