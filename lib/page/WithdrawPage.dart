import 'package:az_car_flutter_app/data/WithdrawDTO.dart';
import 'package:az_car_flutter_app/data/user_model.dart';
import 'package:az_car_flutter_app/services/cardBankService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:flutter/services.dart'; // Import for clipboard

// Assuming you have these models and services set up

import '../data/CardBankDTO.dart';
import '../data/TransactionLimiter.dart';
import '../services/depositService.dart';
import 'FailedPage.dart';
import 'SuccessPage.dart';

class WithdrawPage extends StatefulWidget {
  final int? id;
  final double? balance;  // Adding a balance parameter

  WithdrawPage({Key? key, this.id, this.balance}) : super(key: key);


  @override
  _WithdrawPageState createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController withdrawController = TextEditingController();
  late final String randomReferenceNumber;
  bool _isAccepted = false;
  String _message = '';
  CardBankDTO? cardBank;
  bool _isLoading = true;  // Add isLoading state



  @override
  void initState() {
    late final int? userId;
    fetchCardBankDetails();
    super.initState();
    userId = widget.id;
    if (userId == null) {
      // Handle the case where `userId` is null
      Future.microtask(() {
        Get.snackbar(
            'Error', 'No user ID provided. Returning to previous page.');
        Get.back(); // Optionally navigate back if no ID is provided
      });
    }
    randomReferenceNumber = _generateRandomString();
  }

  void fetchCardBankDetails() async {
    if (widget.id != null) {
      cardBank = await CardBankService.getCardBankByUserId(widget.id.toString());
      if (!mounted) return;
      setState(() {
        _isLoading = false;  // Update loading state
      });
    } else {
      // Handle null ID by showing a snackbar and optionally navigating back
      Get.snackbar('Error', 'No user ID provided. Returning to previous page.');
      Get.back();
    }
  }
  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Terms and Conditions"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("1. User Rights"),
                Text("2. Application Owner Rights"),
                Text("3. Liability Limitation"),
                Text("4. Personal Information and Privacy"),
                Text("5. Service Usage Terms"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Agree'),
              onPressed: () {
                if (!mounted) return;
                setState(() {
                  _isAccepted = true;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _generateRandomString() {
    const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  Widget _withdrawButton(double withdraw) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          withdrawController.text = withdraw.toString();
        });
      },
      child: Text('\$$withdraw'),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WithDraw'),
      ),
      body:
      SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Balance: ${widget.balance?.toStringAsFixed(2) ?? "Not available"} USD',
              style: TextStyle(
                color: Color(0xFF7e3ccf),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            // Display card bank details if available

              Text('Bank Name: ${cardBank!.bankName}'),
              Text('Beneficiary Name: ${cardBank!.beneficiaryName}'),
              Text('Address: ${cardBank!.addressbank}'),

            Text(
              'Reference Number: $randomReferenceNumber',
              style: TextStyle(
                color: Color(0xFF249ae3),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            IconButton(
              icon: Icon(Icons.copy, color: Color(0xFF3498DB)), // Example of a custom blue color
              onPressed: () {
                Clipboard.setData(ClipboardData(text: randomReferenceNumber)).then(
                        (value) => Get.snackbar('Copied', 'Reference number copied to clipboard'),
                    onError: (error) => Get.snackbar('Error', 'Failed to copy to clipboard')
                );
              },
            )
            ,

            TextField(
              controller: withdrawController,
              decoration: InputDecoration(
                labelText: 'Enter withdraw (USD)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            Wrap(
              children: [500.0, 1000.0, 2000.0].map(_withdrawButton).toList(),
            ),
            GestureDetector(
              onTap: _showTermsDialog,
              child: Row(
                children: [
                  Checkbox(
                      value: _isAccepted,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _isAccepted = newValue ?? false;
                        });
                      }),
                  Expanded(
                    child: Text(
                      'I accept conditions and policy',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (_isAccepted) ? _handleWithdraw : null,
              child: Text('Confirm Withdraw'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onSurface: Colors.grey,
              ),
            ),
            Text(_message, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  void _handleWithdraw() async {
    final double withdraw = double.tryParse(withdrawController.text) ?? 0;
    if (withdraw <= 0) {
      Get.snackbar('Error', 'Withdraw amount must be greater than 0');
      return;
    }

    if (widget.balance != null && withdraw > widget.balance!) {
      Get.snackbar('Error', 'Withdraw amount cannot exceed current balance');
      return;
    }

    if (withdraw < 10 || withdraw > 20000) {
      Get.snackbar('Error', 'Please enter a valid withdraw amount greater than USD 10 and less than or equal to USD 20,000');
      return;
    }

    var permission = await TransactionLimiter.checkTransactionPermission();
    if (!permission['canPerform']) {
      int remainingMinutes = permission['remainingMinutes'] as int;
      Get.snackbar(
          'Hold On!',
          'You must wait $remainingMinutes minute more minutes between WithDraw.'
      );
      return;
    }

    bool success = await DepositService.createWithdraw(
        randomReferenceNumber, WithdrawDTO(
      userId: widget.id.toString(),
      withdraw: withdraw,
      referenceNumber: randomReferenceNumber,
      paymentDate: DateTime.now().toIso8601String(),
    )
    );

    if (success) {
      TransactionLimiter.updateLastTransactionTime();
      Get.off(() => SuccessPage());
    } else {
      Get.off(() => FailedPage());
    }
  }
}


