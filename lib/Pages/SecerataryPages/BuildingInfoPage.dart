import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staysync/API/api.dart';
import 'package:staysync/Database/DatabaseHelper.dart';
import 'package:intl/intl.dart';
import 'package:staysync/Pages/SecerataryPages/ResidentInfo.dart';
import 'package:staysync/Pages/SecerataryPages/MemberDetailsPage.dart';
import 'package:staysync/Pages/SecerataryPages/qrcsvupload.dart';
import 'package:staysync/Pages/UserInfo.dart';

import '../IconWithButton.dart';

class BuildingInfoScreen extends StatefulWidget {
  @override
  _BuildingInfoScreenState createState() => _BuildingInfoScreenState();
}

class _BuildingInfoScreenState extends State<BuildingInfoScreen> {
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _loadUserInfo();
    _getUserInfo();
  }

  Future<List<Map<String, dynamic>>> _loadUserInfo() async {
    final db = DatabaseHelper();
    return await db.getUsers();
  }

  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Future<UserInfo> _getUserInfo() async {
    print('asdaa');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUserInfo = prefs.getString('user_info');
    final mobile_number = prefs.getString('mobile_number');
    final building_id = prefs.getString('building_id');
    print('building_id.toString(): $building_id');

    await APIservice.getResidentInfo(mobile_number!, building_id.toString());
    if (savedUserInfo != null) {
      return UserInfo.fromJson(jsonDecode(savedUserInfo));
    } else {
      throw Exception('User info not found');
    }
  }

  Future<void> SendDataToAPI(List<Resident> parsedData) async {
    try {
      // Convert each Resident object to JSON and send to the API
      // You don't need to convert it here, just pass the List<Resident> directly
      List<Map<String, dynamic>> userInfo = await _loadUserInfo();
      var firstUser = userInfo.isNotEmpty ? userInfo[0] : null;

      await APIservice.submitExcelData(
        userId: firstUser?['userid'],
        buildingId: firstUser?['building_id'],
        residents: parsedData, // Pass the List<Resident> directly
      );
    } catch (e) {
      print("Error sending data to API: $e");
    }
  }

  Future<void> _navigateToStaff() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadCSVPage(),
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

  Future<void> _pickAndParseCsv() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final file = File(path);
      final csvString = await file.readAsString();
      final csvRows = const CsvToListConverter().convert(csvString, eol: '\n');

      List<Resident> parsedData = [];
      for (int i = 1; i < csvRows.length; i++) {
        final row = csvRows[i];

        // Ensure proper type conversion
        String name = row[0].toString(); // Ensure this is a String
        String gender = row[1].toString(); // Ensure this is a String
        String mobileNumber = row[2].toString(); // Ensure this is a String
        String dob = row[3].toString(); // Ensure this is a String
        String wingNo = row[4].toString(); // Ensure this is a String
        String flatNo = row[5].toString(); // Ensure this is a String
        int floorNo = int.tryParse(row[6].toString()) ??
            0; // Convert to int, default to 0 if invalid

        // Add resident to the parsed data list
        parsedData.add(Resident(
          name: name,
          gender: gender,
          mobileNumber: mobileNumber,
          dob: dob,
          wingNo: wingNo,
          flatNo: flatNo,
          floorNo: floorNo, // Now properly converted to int
        ));
      }

      // Pass the parsed data to your SendDataToAPI function
      SendDataToAPI(parsedData);
    }
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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading data'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No data available'));
            } else {
              final users = snapshot.data!;

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
                                _buildInfoRow('Name', users[0]['name']),
                                _buildInfoRow('Gender', users[0]['gender']),
                                _buildInfoRow('Date of Birth',
                                    _formatDate(users[0]['dob'])),
                                _buildInfoRow(
                                    'Mobile Number', users[0]['mobile_number']),
                                _buildInfoRow(
                                    'User Type', users[0]['usertype']),
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
                                _buildInfoRow('Secretary Name',
                                    users[0]['resident_name']),
                                _buildInfoRow('No. of Flats',
                                    users[0]['no_of_flats'].toString()),
                                _buildInfoRow('Address', users[0]['address']),
                                _buildInfoRow('Secretary Name',
                                    users[0]['secretary_name']),
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
}
