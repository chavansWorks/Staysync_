import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staysync/Database/DatabaseHelper.dart';
import 'package:staysync/Pages/LoginPages/SignIn.dart';

class LogoutHelper {
  // Function to logout and delete all records from the database
  static Future<void> logout(BuildContext context) async {
    final db = DatabaseHelper();

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('mobile_number');
    prefs.remove('Token');
    prefs.remove('users');
    prefs.remove('building_id');
    prefs.clear();

    // Clear all tables by deleting data
    await db.clearAllData();
    // Optionally, you can navigate to the login screen or reset the app's state
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SignInScreen(),
      ),
    );
  }
}
