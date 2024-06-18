import 'package:az_car_flutter_app/data/ReviewModel.dart';
import 'package:az_car_flutter_app/data/CommentModel.dart';
import 'package:az_car_flutter_app/data/carModel.dart';
import 'package:az_car_flutter_app/services/get_api_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unicons/unicons.dart';

class CarDetailsWidget extends StatefulWidget {
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
  _CarDetailsWidgetState createState() => _CarDetailsWidgetState();
}

class _CarDetailsWidgetState extends State<CarDetailsWidget> {
  double averageRating = 5.0; // Giá trị mặc định là 5 sao

  void _calculateAverageRating(List<ReviewModel>? reviews) {
    if (reviews != null && reviews.isNotEmpty) {
      double totalRating = reviews.fold(0, (sum, item) => sum + item.rating);
      setState(() {
        averageRating = totalRating / reviews.length;
      });
    } else {
      setState(() {
        averageRating = 5.0; // Giá trị mặc định là 5 sao
      });
    }
  }


  void _showReviews() async {
    List<ReviewModel>? reviews;
    try {
      reviews = await ApiService.getReviewsByCarId(widget.car.id.toString());
      _calculateAverageRating(reviews);
    } catch (e) {
      print('Error fetching reviews: $e');
      reviews = [];
      _calculateAverageRating(null);
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Reviews'),
            content: (reviews != null && reviews.isNotEmpty)
                ? Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(reviews![index].comment),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.yellow),
                            SizedBox(width: 4),
                            Text('Rating: ${reviews![index].rating}'),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.date_range, color: Colors.grey),
                            SizedBox(width: 4),
                            Text('Date: ${reviews![index].reviewDate.toLocal().toString().split(' ')[0]}'),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
                : Text('No Reviews'),
            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _showComments() async {
    List<CommentModel>? comments;
    try {
      comments = await ApiService.getCommentsByCarId(widget.car.id.toString());
    } catch (e) {
      print('Error fetching comments: $e');
      comments = [];
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Comments'),
            content: (comments != null && comments.isNotEmpty)
                ? Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(comments![index].content),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User: ${comments![index].userName}'),
                        Text('Date: ${comments![index].reviewDate.toLocal().toString().split(' ')[0]}'),
                      ],
                    ),
                  );
                },
              ),
            )
                : Text('No Comments'),
            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

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
              widget.car.discount > 0
                  ? Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(8),
                child: Text(
                  'Sales: ${widget.car.discount}%',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: widget.size.width * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
                  : SizedBox(),
              const Spacer(),
              Text(
                widget.car.licensePlates,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.yellow[800],
                  fontSize: widget.size.width * 0.07,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Text(
              '${widget.car.carmodel.model} - ${widget.car.carmodel.year}',
              textAlign: TextAlign.left,
              style: GoogleFonts.poppins(
                color: widget.themeData.primaryColor,
                fontSize: widget.size.width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              (widget.car.price - (widget.car.price * widget.car.discount / 100))
                  .toStringAsFixed(2),
              style: GoogleFonts.poppins(
                color: widget.themeData.primaryColor,
                fontSize: widget.size.width * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ' VND/day',
              style: GoogleFonts.poppins(
                color: widget.themeData.primaryColor.withOpacity(0.8),
                fontSize: widget.size.width * 0.025,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: widget.size.height * 0.02),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildStat(
                        UniconsLine.dashboard,
                        '${widget.car.fuelType == 'Gasoline' ? 'Petrol' : widget.car.fuelType} ',
                        'Fuel',
                        widget.size,
                        widget.themeData,
                        null),
                    buildStat(
                        UniconsLine.users_alt,
                        'Seats',
                        '( ${widget.car.seatQty} )',
                        widget.size,
                        widget.themeData,
                        null),
                    buildStat(
                        UniconsLine.car,
                        'Engine',
                        ' ${widget.car.engineInformationTranmission ? 'Auto' : 'Manual'} ',
                        widget.size,
                        widget.themeData,
                        null),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: widget.size.height * 0.17,
                      child: buildStat(
                          UniconsLine.rocket,
                          widget.car.deliveryFee! > 0
                              ? '${widget.car.deliveryFee} VND'
                              : 'Free',
                          'Deli Fee',
                          widget.size,
                          widget.themeData,
                          null),
                    ),
                    SizedBox(
                      height: widget.size.height * 0.17,
                      child: buildStat(
                          UniconsLine.car_wash,
                          widget.car.cleaningFee! > 0
                              ? '${widget.car.cleaningFee} VND'
                              : 'Free',
                          'Clean Fee',
                          widget.size,
                          widget.themeData,
                          null),
                    ),
                    SizedBox(
                      height: widget.size.height * 0.17,
                      child: buildStat(
                          UniconsLine.sanitizer_alt,
                          widget.car.smellFee! > 0
                              ? '${widget.car.smellFee} VND'
                              : 'Free',
                          'Smell Fee',
                          widget.size,
                          widget.themeData,
                          null),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildStat(UniconsLine.receipt, '${widget.car.finishedOrders}',
                      'Trips', widget.size * 1.5, widget.themeData, 'green'),
                  buildStat(
                    UniconsLine.star,
                    averageRating.toStringAsFixed(2), // Hiển thị điểm đánh giá trung bình
                    'Quality',
                    widget.size * 1.5,
                    widget.themeData,
                    'yellow',
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _showReviews,
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xFFD12F24)),
                    ),
                    child: Text('Review'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _showComments,
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xFFD12F24)),
                    ),
                    child: Text('Comment'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: widget.size.height * 0.01,
          ),
        ),
        Center(
          child: SizedBox(
            height: widget.size.height * 0.15,
            width: widget.size.width * 0.9,
            child: Container(
              decoration: BoxDecoration(
                color: widget.themeData.cardColor,
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
                      horizontal: widget.size.width * 0.05,
                      vertical: widget.size.height * 0.015,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          UniconsLine.shield_check,
                          color: Colors.green,
                          size: widget.size.height * 0.05,
                        ),
                        Text(
                          '200.000 VND  Insurance bundle included',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: widget.themeData.primaryColor,
                            fontSize: widget.size.width * 0.035,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '* The trip has been insured, feel free to enjoy',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: widget.themeData.primaryColor.withOpacity(0.6),
                            fontSize: widget.size.width * 0.025,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '* No worries about incidents',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: widget.themeData.primaryColor.withOpacity(0.6),
                            fontSize: widget.size.width * 0.025,
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
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: widget.size.height * 0.01,
          ),
        ),
        Center(
          child: SizedBox(
            height: widget.size.height * 0.15,
            width: widget.size.width * 0.9,
            child: Container(
              decoration: BoxDecoration(
                color: widget.themeData.cardColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.size.width * 0.05,
                        vertical: widget.size.height * 0.015,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            UniconsLine.map_marker,
                            color: Colors.redAccent,
                            size: widget.size.height * 0.05,
                          ),
                          Text(
                            widget.car.address
                                .split(', ')
                                .sublist(widget.car.address.split(', ').length - 2)
                                .join(', '),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: widget.themeData.primaryColor,
                              fontSize: widget.size.width * 0.03,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.car.address
                                .split(', ')
                                .sublist(0, widget.car.address.split(', ').length - 2)
                                .join(', '),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: widget.themeData.primaryColor.withOpacity(0.6),
                              fontSize: widget.size.width * 0.03,
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
      String? colorName,
      ) {
    Map<String, Color> colorMap = {
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'yellow': Colors.yellow,
    };
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
                  color: colorMap[colorName] ?? const Color(0xff3b22a1),
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
