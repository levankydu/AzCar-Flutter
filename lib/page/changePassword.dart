import 'package:az_car_flutter_app/services/get_api_services.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key, required this.email}) : super(key: key);
  final String email;

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thay đổi mật khẩu'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _oldPasswordController,
                decoration: InputDecoration(labelText: 'Mật khẩu cũ'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu cũ của bạn';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(labelText: 'Mật khẩu mới'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu mới của bạn';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Xác nhận mật khẩu mới'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng xác nhận mật khẩu mới của bạn';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Mật khẩu không khớp';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String oldPassword = _oldPasswordController.text;
                    String newPassword = _newPasswordController.text;
                    String confirmPassword = _newPasswordController.text;
                    print(widget.email);
                    String success = await ApiService.changePassword(widget.email, oldPassword, newPassword, confirmPassword);
                    if (success=='Password changed successfully.') {
                      _showSnackBar(context, 'Thay đổi mật khẩu thành công', true);
                    } else {
                      _showSnackBar(context,success, false);
                    }
                  }
                },
                child: Text('Thay đổi mật khẩu'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, bool success) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}