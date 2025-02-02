import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staysync/Pages/SecerataryPages/BuildingInfoPage.dart';
import 'package:staysync/Pages/LoginPages/LogoutPage.dart';
import 'package:staysync/Pages/UserInfo.dart';
import 'ResidentPages/Resident.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late Future<Object> userInfoFuture;

  @override
  void initState() {
    super.initState();
    userInfoFuture = _getUserInfo();
  }

  // Function to load user info from SharedPreferences
Future<Object> _getUserInfo() async {
  try {
    // Retrieve SharedPreferences instance
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get saved user information from SharedPreferences
    String? savedUserInfo = prefs.getString('user_info');
    final mobileNumber = prefs.getString('mobile_number');
    final buildingId = prefs.getString('building_id'); // This should be retrieved separately
    final userType = prefs.getString('UserType') ?? '';

    print('Saved User Info: $savedUserInfo'); // Check if data exists
    
    if (savedUserInfo != null) {
      // Decode the saved JSON string
      final residentData = jsonDecode(savedUserInfo);
      print('Decoded Resident Info: $residentData'); // Check decoded data

      // Extract building_id directly from the decoded data
      final decodedBuildingId = residentData['building_id'];
      print('Decoded building_id: $decodedBuildingId');

      // Depending on user type, return the relevant data
      if (userType == 'Resident') {
        return ResidentInfo.fromJson(residentData); // Return ResidentInfo
      } else {
        throw Exception('User info not found in SharedPreferences');
      }
    } else {
      throw Exception('User info not found in SharedPreferences');
    }
  } catch (e) {
    print('Error in _getUserInfo: $e');
    rethrow;
  }
}

  // Logout function
  void logout(BuildContext context) async {
    LogoutHelper.logout(context);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Object>(
        future: userInfoFuture, // Wait for user data from SharedPreferences
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading user data"));
          }

          if (!snapshot.hasData) {
            return Center(child: Text("No user data found"));
          }

          final userInfo = snapshot.data;

          // Determine whether it's a ResidentInfo or UserInfo object
          String name = '';
          String mobileNumber = '';
          if (userInfo is ResidentInfo) {
            name = userInfo.residentName ?? 'Unknown';
            mobileNumber = userInfo.mobileNumber ?? 'Unknown';
          } else if (userInfo is UserInfo) {
            name = userInfo.name ?? 'Unknown';
            mobileNumber = userInfo.mobileNumber ?? 'Unknown';
          }

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
                      'Name: $name',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Mobile: $mobileNumber',
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
