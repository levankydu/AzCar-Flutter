import 'dart:convert';

import 'package:az_car_flutter_app/data/carModel.dart';
import 'package:az_car_flutter_app/data/user_model.dart';
import 'package:az_car_flutter_app/services/get_api_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HeartButton extends StatefulWidget {
  late CarModel car;
  final UserModel? user;

  HeartButton(this.car, this.user);

  @override
  _HeartButtonState createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(left: 190.0),
        child: IconButton(
          icon: Icon(
            widget.car.isFavorite == true
                ? Icons.favorite
                : Icons.favorite_border,
            size: 30,
            color: Colors.red,
          ),
          onPressed: () async {
            setState(() {
              widget.car.isFavorite = !widget.car.isFavorite;
            });
            String carId = widget.car.id.toString();
            String userEmail = widget.user!.email;
            final response = await http.get(
              Uri.parse('${ApiService.baseUrl}/api/cars/processFavorite?carId=$carId&userEmail=$userEmail'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
            );
            if (response.statusCode == 200) {
              print(response);
            } else {}
          },
        ),
      ),
    );
  }
}
