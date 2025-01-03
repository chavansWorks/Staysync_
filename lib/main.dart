import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staysync/Pages/LoginPages/SignIn.dart';
import 'package:staysync/Pages/homescreenDesign.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<Widget> _loadInitialPage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('Token');
    if (token != null) {
      print("Token: $token");

      return HomeScreen(); // Navigate to HomePage if the token exists
    } else {
      return SignInScreen(); // Navigate to SignInScreen if the token doesn't exist
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Socket Notifications',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
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
          } else if (snapshot.hasData) {
            return snapshot
                .data!; // Return the HomePage or SignInScreen based on the token
          } else {
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
