import 'package:az_car_flutter_app/data/carModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unicons/unicons.dart';

class CarDetailsWidget extends StatelessWidget {
  final CarModel car;
  final Size size;
  final ThemeData themeData;

  const CarDetailsWidget({
    Key? key,
    required this.car,
    required this.size,
    required this.themeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discount :${car.discount}%',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: themeData.primaryColor,
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.star,
                color: Colors.yellow[800],
                size: size.width * 0.06,
              ),
              Text(
                car.licensePlates,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.yellow[800],
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Text(
              '${car.carmodel.model}-${car.carmodel.year}',
              textAlign: TextAlign.left,
              style: GoogleFonts.poppins(
                color: themeData.primaryColor,
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${(car.price - (car.price * car.discount / 100)).toStringAsFixed(2)}\$',
              style: GoogleFonts.poppins(
                color: themeData.primaryColor,
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '/per day',
              style: GoogleFonts.poppins(
                color: themeData.primaryColor.withOpacity(0.8),
                fontSize: size.width * 0.025,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: size.height * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildStat(
                UniconsLine.dashboard,
                '${car.fuelType} ',
                'Power',
                size,
                themeData,
              ),
              buildStat(
                UniconsLine.users_alt,
                'People',
                '( ${car.seatQty} )',
                size,
                themeData,
              ),
              buildStat(
                UniconsLine.car,
                'Engine',
                ' ${car.engineInformationTranmission ? 'Auto' : 'Manual'} ',
                size,
                themeData,
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.03,
          ),
          child: Text(
            'Car Location',
            style: GoogleFonts.poppins(
              color: themeData.primaryColor,
              fontSize: size.width * 0.055,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: SizedBox(
            height: size.height * 0.15,
            width: size.width * 0.9,
            child: Container(
              decoration: BoxDecoration(
                color: themeData.cardColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.015,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          UniconsLine.map_marker,
                          color: const Color(0xff3b22a1),
                          size: size.height * 0.05,
                        ),
                        Text(
                          car.address
                              .split(', ')
                              .sublist(car.address.split(', ').length - 2)
                              .join(', '),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: themeData.primaryColor,
                            fontSize: size.width * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          car.address
                              .split(', ')
                              .sublist(0, car.address.split(', ').length - 2)
                              .join(', '),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: themeData.primaryColor.withOpacity(0.6),
                            fontSize: size.width * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Padding buildStat(
      IconData icon,
      String title,
      String desc,
      Size size,
      ThemeData themeData,
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.015,
      ),
      child: SizedBox(
        height: size.width * 0.32,
        width: size.width * 0.25,
        child: Container(
          decoration: BoxDecoration(
            color: themeData.cardColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: size.width * 0.03,
              left: size.width * 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: const Color(0xff3b22a1),
                  size: size.width * 0.08,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: size.width * 0.02,
                  ),
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: themeData.primaryColor,
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    color: themeData.primaryColor.withOpacity(0.7),
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}