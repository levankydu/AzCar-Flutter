import 'package:shared_preferences/shared_preferences.dart';

class TransactionLimiter {
  static const String _lastTxnKey = "last_transaction_timestamp";

  static Future<Map<String, dynamic>> checkTransactionPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTxnTimestamp = prefs.getInt(_lastTxnKey);
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (lastTxnTimestamp == null) {
      return {"canPerform": true};
    }

    final differenceInMinutes = (currentTime - lastTxnTimestamp) / 60000;
    if (differenceInMinutes < 1) {
      // Calculate remaining minutes
      final remainingMinutes = 1 - differenceInMinutes;
      return {
        "canPerform": false,
        "remainingMinutes": remainingMinutes.ceil()  // Round up the remaining minutes
      };
    }

    return {"canPerform": true};
  }

  static Future<void> updateLastTransactionTime() async {
    final prefs = await SharedPreferences.getInstance();
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_lastTxnKey, currentTime);
  }
}
