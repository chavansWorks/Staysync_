import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staysync/Pages/LoginPages/SignIn.dart';
import 'package:staysync/Pages/UserInfo.dart';

// CustomDrawer widget that displays the user's info and handles logout
class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late Future<UserInfo> userInfoFuture;

  @override
  void initState() {
    super.initState();
    userInfoFuture = _loadUserInfo();
  }

  // Function to load user info from SharedPreferences
  Future<UserInfo> _loadUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUserInfo = prefs.getString('user_info');

    if (savedUserInfo != null) {
      // Decode back to UserInfo object
      return UserInfo.fromJson(jsonDecode(savedUserInfo));
    } else {
      throw Exception('User info not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<UserInfo>(
        future: userInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    CircularProgressIndicator()); // Show loading spinner while fetching data
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            var userFromPrefs = snapshot.data!;

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[800]!, Colors.blue[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Name: ${userFromPrefs.name}', // Display name
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userFromPrefs
                            .mobileNumber, // Placeholder for phone number, modify as needed
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home, color: Colors.blue[800]),
                  title: Text(
                    'Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    // Navigate to Home Screen
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info, color: Colors.blue[800]),
                  title: Text(
                    'Building Info',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    // Navigate to Building Info Screen
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  leading: Icon(Icons.contact_mail, color: Colors.blue[800]),
                  title: Text(
                    'Contact Us',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    // Navigate to Contact Us Screen
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  leading: Icon(Icons.help, color: Colors.blue[800]),
                  title: Text(
                    'About Us',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    // Navigate to About Us Screen
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                Divider(), // Add a divider
                ListTile(
                  leading:
                      Icon(Icons.admin_panel_settings, color: Colors.blue[800]),
                  title: Text(
                    'Building Authority',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    // Navigate to Building Authority Screen
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.blue[800]),
                  title: Text(
                    'Settings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    // Navigate to Settings Screen
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                Divider(), // Add a divider
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.blue[800]),
                  title: Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    // Perform Logout
                    logout(context); // Close the drawer
                  },
                ),
              ],
            );
          }

          return Center(child: Text('No data available'));
        },
      ),
    );
  }
}

// Logout function
void logout(BuildContext context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // Clear the stored preferences (Token and mobile_number)
  await prefs.remove('Token');
  await prefs.remove('mobile_number');
  await prefs.remove('user_info');

  // Check if the token is cleared
  var token = prefs.getString('Token'); // Will return null if removed

  print(token); // For debugging; token should be null at this point
  if (token == null) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SignInScreen(),
      ),
    );
  }
}
