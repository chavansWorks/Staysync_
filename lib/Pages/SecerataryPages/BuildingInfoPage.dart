import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staysync/Pages/SecerataryPages/MemberDetailsPage.dart';
import 'package:staysync/Pages/SecerataryPages/ViewStaff.dart';
import 'package:staysync/Pages/UserInfo.dart';
import '../IconWithButton.dart';

class BuildingInfoScreen extends StatefulWidget {
  @override
  _BuildingInfoScreenState createState() => _BuildingInfoScreenState();
}

class _BuildingInfoScreenState extends State<BuildingInfoScreen> {
  late Future<UserInfo> _userInfoFuture;

  @override
  void initState() {
    super.initState();
    _userInfoFuture = _getUserInfo();
  }

  // Retrieve User Info from SharedPreferences
  Future<UserInfo> _getUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUserInfo = prefs.getString('user_info');
    if (savedUserInfo != null) {
      return UserInfo.fromJson(jsonDecode(savedUserInfo));
    } else {
      throw Exception('User info not found');
    }
  }

  Future<void> _navigateToStaff() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StaffPage(),
      ),
    );
  }

  Future<void> _navigateToResident() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberDetailsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Info',
          style: GoogleFonts.roboto(),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<UserInfo>(
          future: _userInfoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading data'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('No data available'));
            } else {
              final user = snapshot.data!;

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Personal Info',
                                  style: GoogleFonts.roboto(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                SizedBox(height: 12),
                                _buildInfoRow('Name', user.name),
                                _buildInfoRow('Gender', user.gender),
                                _buildInfoRow('Date of Birth', _formatDate(user.dob)),
                                _buildInfoRow('Mobile Number', user.mobileNumber),
                                _buildInfoRow('User Type', user.usertype),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Building Info',
                                  style: GoogleFonts.roboto(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                SizedBox(height: 12),
                                _buildInfoRow('Secretary Name', user.residentName),
                                _buildInfoRow('No. of Flats', user.noOfFlats.toString()),
                                _buildInfoRow('Address', user.address),
                                _buildInfoRow('Secretary Name', user.secretaryName),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        label: 'Residents',
                        onTap: _navigateToResident,
                        icon: Icons.person_search,
                      ),
                      CustomButton(
                        label: 'Staff',
                        onTap: _navigateToStaff,
                        icon: Icons.group,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 80,
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Format Date function
  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }
}
