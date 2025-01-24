import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staysync/API/api.dart';
import 'package:staysync/Database/DatabaseHelper.dart';
import 'package:staysync/Pages/BuildingInfoPage.dart';
import 'package:staysync/Pages/LoginPages/LogoutPage.dart';
import 'package:staysync/Pages/UserInfo.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late Future<List<Map<String, dynamic>>> usersFuture;

  @override
  void initState() {
    super.initState();
    usersFuture = _loadUserInfo();
  }

  // Function to load user info from the database
  Future<List<Map<String, dynamic>>> _loadUserInfo() async {
    final db = DatabaseHelper();
    return await db.getUsers(); // Fetch user info from the database
  }

  void logout(BuildContext context) async {
    LogoutHelper.logout(context);
  }

  Future<UserInfo> _getUserInfo() async {
    try {
      // Retrieve SharedPreferences instance
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Get saved user information
      String? savedUserInfo = prefs.getString('user_info');
      final mobileNumber = prefs.getString('mobile_number');
      final buildingId = prefs.getString('building_id');

      print('building_id.toString(): $buildingId');

      // Validate mobileNumber and buildingId before proceeding
      if (mobileNumber == null || buildingId == null) {
        throw Exception('Mobile number or building ID is missing');
      }

      // Fetch updated resident information from API
      var data = await APIservice.getResidentInfo(mobileNumber, buildingId);
      // If `user_info` is found in SharedPreferences, return it
      if (savedUserInfo != null) {
        return UserInfo.fromJson(jsonDecode(savedUserInfo));
      } else {
        throw Exception('User info not found in SharedPreferences');
      }
    } catch (e) {
      print('Error in _getUserInfo: $e');
      rethrow; // Rethrow the exception after logging
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: usersFuture, // Wait for user data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading user data"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No user data found"));
          }

          // Now that data is available, proceed with displaying the drawer content
          final users = snapshot.data!;
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
                      'Name: ${users[0]['name']}', // Display name
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Mobile: ${users[0]['mobile_number']}', // Display mobile number
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BuildingInfoScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.contact_mail, color: Colors.blue[800]),
                title: Text(
                  'Contact Us',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: () {
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
                  _getUserInfo();
                  Navigator.pop(context); // Close the drawer
                },
              ),
              Divider(),
              ListTile(
                leading:
                    Icon(Icons.admin_panel_settings, color: Colors.blue[800]),
                title: Text(
                  'Building Authority',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: () {
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
                  Navigator.pop(context); // Close the drawer
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.blue[800]),
                title: Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  // Perform logout
                  logout(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// Logout function
void logout(BuildContext context) async {
  LogoutHelper.logout(context);
}
