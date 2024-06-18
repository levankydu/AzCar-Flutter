import 'package:az_car_flutter_app/data/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:flutter/services.dart'; // Import for clipboard
import 'package:intl/intl.dart';


// Assuming you have these models and services set up

import '../data/Bank.dart';
import '../data/CardBankDTO.dart';
import '../data/DepositDTO.dart';
import '../data/TransactionLimiter.dart';
import '../services/cardBankService.dart';
import '../services/depositService.dart';
import 'FailedPage.dart';
import 'SuccessPage.dart';

class DepositPage extends StatefulWidget {
  final int? id;
  final double? balance;  // Adding a balance parameter

  DepositPage({Key? key, this.id, this.balance}) : super(key: key);


  @override
  _DepositPageState createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  final TextEditingController amountController = TextEditingController();
  late final String randomReferenceNumber;
  bool _isAccepted = false;
  bool _isLoading = false;
  String _message = '';
  List<CardBankDTO> cardBanks = [];
  CardBankDTO? selectedBank;



  @override
  void initState() {
    late final int? userId;
    fetchCardBankAdminList();
    super.initState();
    userId = widget.id;
    if (userId == null) {
      // Handle the case where `userId` is null
      Future.microtask(() {
        Get.snackbar('Error', 'No user ID provided. Returning to previous page.');
        Get.back(); // Optionally navigate back if no ID is provided
      });
    }
    randomReferenceNumber = _generateRandomString();
  }

  void fetchCardBankAdminList() async {
    cardBanks = await CardBankService.getListCardBank();
    setState(() {});  // Refresh the UI after data is fetched
  }

  String formatCurrency(int amount) {
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return currencyFormat.format(amount);
  }
  void _showBankDetails(CardBankDTO bank) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(bank.bankName),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bank ID: ${bank.bankNumber}'),
                Text('Beneficiary Name: ${bank.beneficiaryName}'),
                Text('Address: ${bank.addressbank}'),
                Text('Status: ${bank.active}'),
                // Add more fields as needed
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),  // Close the details dialog
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showMenuDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bank Admin Info'),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: cardBanks.asMap().entries.map((entry) {
                int idx = entry.key;
                CardBankDTO bank = entry.value;
                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog
                    setState(() {
                      selectedBank = bank; // Set selectedBank to the chosen bank
                    });
                  },
                  child: Container(
                    color: Colors.transparent, // Default color
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: Text('${idx + 1}. ${bank.bankName}', style: TextStyle(fontSize: 16)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('ID: ${bank.bankNumber}', style: TextStyle(color: Colors.grey)),
                        ),
                      ],
                    ),
                  ),
                  onHover: (isHovering) {
                    if (isHovering) {
                      // This will work only in web and desktop environments.
                      // Mobiles do not have hover functionality.
                      setState(() {
                        // Force rebuild to show a different color
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: Text('Close'),
            ),
          ],
        );
      },
    );
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
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Help Instructions"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("1. Click 'Show Bank Info' to select your bank."),
                Text("2. Input the amount you want to deposit."),
                Text("3. Click 'I accept conditions and policy' and then 'Confirm Deposit'."),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _generateRandomString() {
    const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(6, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deposit'),

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text('Balance: ${widget.balance  ?? '0'} VND',

        style: TextStyle(
          color: Color(0xFF7e3ccf), // Hex color code for Flutter
        fontWeight: FontWeight.bold, // Make text bold
        fontSize: 18, // Set font size to 24
      ),),  // Safely using balance with null check

            SizedBox(height: 10),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showMenuDialog,
              child: Text('Show Bank Info'),
            ),
            if (selectedBank != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Bank Name: ${selectedBank!.bankName}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, color: Color(0xFF3498DB)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: selectedBank!.bankName));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bank name copied to clipboard')));
                    },
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text('Bank ID: ${selectedBank!.bankNumber}'),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, color: Color(0xFF3498DB)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: selectedBank!.bankNumber));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bank ID copied to clipboard')));
                    },
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text('Beneficiary Name: ${selectedBank!.beneficiaryName}'),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, color: Color(0xFF3498DB)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: selectedBank!.beneficiaryName));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Beneficiary name copied to clipboard')));
                    },
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text('Address: ${selectedBank!.addressbank}'),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, color: Color(0xFF3498DB)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: selectedBank!.addressbank));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Address copied to clipboard')));
                    },
                  ),
                ],
              ),
            ],
            SizedBox(height: 20),
            Text(
              'Reference Number: $randomReferenceNumber',
              style: TextStyle(
                color: Color(0xFF249ae3),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            IconButton(
              icon: Icon(Icons.copy, color: Color(0xFF3498DB)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: randomReferenceNumber));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reference number copied to clipboard')));
              },
            ),


            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Enter Amount (VND)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            Wrap(
              children:[ (50000),  (100000), (200000)].map((amount) => ElevatedButton(
                onPressed: () {
                  setState(() {
                    amountController.text = amount.toString();
                  });
                },
                child: Text('VND $amount'),
              )).toList(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _showTermsDialog,  // Call the _showTermsDialog method when text is tapped
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isAccepted,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _isAccepted = newValue ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Text('I accept conditions and policy',
                          style: TextStyle(
                            decoration: TextDecoration.underline, // Optionally underline the text to indicate it's clickable
                            color: Colors.blue, // Use a color to indicate it is interactive
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _showHelpDialog,
                        child: Text('Help', style: TextStyle(
                            decoration: TextDecoration.underline,

                            color: Colors.red)),
                      ),

                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: (_isAccepted && selectedBank != null) ? _handleDeposit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, disabledForegroundColor: Colors.grey.withOpacity(0.38), disabledBackgroundColor: Colors.grey.withOpacity(0.12),  // Color when disabled
                  ),
                  child: Text('Confirm Deposit'),
                ),
                if (_isLoading) CircularProgressIndicator(),
                Text(_message, style: TextStyle(color: Colors.red)),
              ],
            ),


          ],
        ),
      ),
    );
  }

  void _handleDeposit() async {
    final double amount = double.tryParse(amountController.text.replaceAll(',', '').replaceAll('.', '')) ?? 0;
    if (amount <= 10000 || amount > 50000000) {
      Get.snackbar('Error', 'Please enter a valid amount greater than VND 10,000 and less than or equal to VND 50,000,000');
      return;
    }
    var permission = await TransactionLimiter.checkTransactionPermission();
    if (!permission['canPerform']) {
      int remainingMinutes = permission['remainingMinutes'] as int;
      Get.snackbar(
          'Hold On!',
          'You must wait $remainingMinutes minute more minutes between deposits.'
      );
      return;
    }
    bool success = await DepositService.createDeposit(
      randomReferenceNumber,
      DepositDTO(
        userId: widget.id.toString(), // Safe to use directly
        amount: amount,
        referenceNumber: randomReferenceNumber,
        paymentDate: DateTime.now().toIso8601String(),
      ),
    );

    if (success) {
      TransactionLimiter.updateLastTransactionTime();

      Get.off(() => SuccessPage());
    } else {
      Get.off(() => FailedPage());
    }
  }


}
