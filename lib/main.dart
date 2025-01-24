import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staysync/Pages/LoginPages/SignIn.dart';
import 'package:staysync/Pages/ResidentPages/ResidentHomePage.dart';
import 'package:staysync/Pages/homescreenDesign.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// 1. Global navigator key for centralized navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // 2. Centralized navigation function
  void navigateTo(Widget page) {
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<void> _loadInitialPage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('Token');
    final String? mobile_number = prefs.getString('mobile_number');

    if (token != null) {
      print("Token: $token");
      print("Token: $mobile_number");

      // Check if the token is expired
      bool isTokenExpired = JwtDecoder.isExpired(token);
      print("Token Expired: $isTokenExpired");

      var UserType = prefs.getString('UserType');
      // Navigate to appropriate page based on token expiration status
      if (!isTokenExpired || UserType == 'Secretary') {
        // Valid token, navigate to HomeScreen
        navigateTo(HomeScreen());
      } else if (UserType == 'Resident') {
        navigateTo(ResidentScreen());
      } else {
        // Token expired, navigate to SignInScreen
        navigateTo(SignInScreen());
      }
    } else {
      // No token found, navigate to SignInScreen
      navigateTo(SignInScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Socket Notifications',
      debugShowCheckedModeBanner: false,
      // 3. Pass navigatorKey to MaterialApp
      navigatorKey: navigatorKey,
      home: FutureBuilder(
        future: _loadInitialPage(), // Load the initial page asynchronously
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                  child: CircularProgressIndicator()), // Loading indicator
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(fontSize: 16.0, color: Colors.red),
                ), // Handle any errors
              ),
            );
          } else {
            // Here we don't return the snapshot.data, since navigateTo is already handling the screen change
            return Scaffold(
              body: Center(
                child: Text('Unexpected error occurred'),
              ),
            );
          }
        },
      ),
    );
  }
}
