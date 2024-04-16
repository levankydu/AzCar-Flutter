import 'dart:convert';
import 'dart:ffi';

import 'package:az_car_flutter_app/data/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';

import 'package:mailer/smtp_server.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.2.68:8081/api/auth';

  static Future<List<UserModel>> fetchPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/getUsers'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(response.body);
      return data.map((post) => UserModel.fromJson(post)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  static Future<bool> loginUser(String usernameOrEmail, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signin'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> signupUser(
      String username, String email, String password) async {
    if (username == '' || email == '' || password == '') {
      return false;
    } else {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    }
  }

  static Future<UserModel?> getUserByEmail(String email) async {
    if (email.isEmpty) {
      return null;
    } else {
      final response = await http.get(
        Uri.parse('$baseUrl/getUsersByEmail?email=$email'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return UserModel.fromJson(data);
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

  static Future<UserModel?> editUser(UserModel userModel) async {
    final response = await http.post(Uri.parse('$baseUrl/editUser'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(userModel.toJson()));
    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return UserModel.fromJson(data);
        } else {
          return null;
        }
      } catch (e) {
        print('Error decoding JSON: $e');
        return null;
      }
    } else {
      print('HTTP Error: ${response.statusCode}');
      return null;
    }
  }

  static Future<bool> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot_password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> tokenProcess(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tokenProcess'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

static Future<bool> resetPassword(String token, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/resetPassword'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'token': token,
      'password': password
    }),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}
  
  void sendEmail(String recipientEmail) async {
    String username = 'dn169240@gmail.com';
    String password = 'pblt rtjz jdps zobm';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'AzCar')
      ..recipients.add(recipientEmail)
      ..subject = 'Welcome to AzCar'
      ..html = 'Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi';

    try {
      final sendReport = await send(message, smtpServer);
      if (sendReport == false) {
        print('Email sent successfully');
      } else {
        print('Failed to send email');
      }
    } catch (e) {
      print('Error sending email: $e');
    }
  }
}
