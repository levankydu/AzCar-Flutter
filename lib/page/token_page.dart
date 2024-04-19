import 'package:az_car_flutter_app/data/user_model.dart';
import 'package:az_car_flutter_app/page/resetPassword.dart';
import 'package:az_car_flutter_app/services/get_api_services.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

class TokenPageProcess extends StatefulWidget {
  const TokenPageProcess({super.key});

  @override
  State<TokenPageProcess> createState() => _TokenPageProcessState();
}

class _TokenPageProcessState extends State<TokenPageProcess> {
  bool _showTokenError = false;
  String token = '';
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50, bottom: 20),
              child: Row(
                children: [
                  IconButton(
                    alignment: Alignment.topLeft,
                    icon: Icon(
                      CommunityMaterialIcons.arrow_left_bold_circle,
                      color: Colors.black,
                      size: 40,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    'Token Verify',
                    style: TextStyle(
                      fontSize: 25,
                      letterSpacing: 2,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            OTPTextField(
              length: 5,
              width: MediaQuery.of(context).size.width,
              fieldWidth: 50,
              style: TextStyle(fontSize: 17),
              textFieldAlignment: MainAxisAlignment.spaceAround,
              fieldStyle: FieldStyle.underline,
              onCompleted: (token) async {
                bool success = await ApiService.tokenProcess(token);

                if (success) {
                  _showSnackBar(context, 'Code token is successfully', true);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ResetPasswordPage(token: token,)),
                  );
                } else {
                  _showSnackBar(context, 'Failed code token', false);
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
