import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staysync/Pages/LoginPages/SignIn.dart'; // Assuming this is the correct path for the SignInScreen

class HomePage extends StatelessWidget {
  final String userName =
      "John Doe"; // Replace with dynamic user name if needed

  // Add the context parameter to the logout function
  void logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Clear the stored preferences (Token and mobile_number)
    await prefs.remove('Token');
    await prefs.remove('mobile_number');

    // Navigate to the SignInScreen after logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SignInScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                    'lib/assets/bgimage.jpg'), // Add your image in the assets folder
              ),
              SizedBox(height: 20),
              Text(
                'Welcome, $userName!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'We are glad to have you here.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Add your navigation logic here
                },
                child: Text('Get Started'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Pass context to the logout function
                  logout(context);
                },
                child: Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red, // Red color for the log-out button
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
