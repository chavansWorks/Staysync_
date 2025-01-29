import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staysync/API/api.dart';
import 'package:staysync/Database/DatabaseHelper.dart';
import 'package:staysync/Pages/SecerataryPages/ResidentInfo.dart';
import 'package:staysync/Pages/UserInfo.dart';
import 'package:transformable_list_view/transformable_list_view.dart';
import 'package:shimmer/shimmer.dart';

class MemberDetailsPage extends StatefulWidget {
  @override
  _MemberDetailsPageState createState() => _MemberDetailsPageState();
}

class _MemberDetailsPageState extends State<MemberDetailsPage> {
  late Future<List<Map<String, dynamic>>> residentsFuture;
  late Future<UserInfo> userInfoFuture;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    residentsFuture = DatabaseHelper().getResidents();
    userInfoFuture = _getUserInfo();
    _fetchUserInfo();
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

  Future<void> _navigateToResident() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberDetailsPage(),
      ),
    );
  }

  Future<void> _pickAndParseCsv() async {
    setState(() {
    isLoading = true; // Start shimmer effect
  });
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
      await SendDataToAPI(parsedData);
      setState(() {
      residentsFuture = Future.value(parsedData.map((resident) => resident.toJson()).toList()); // Update the future with parsed data
      isLoading = false; // Stop shimmer effect
    });
  } else {
    setState(() {
      isLoading = false; // Stop shimmer effect if no file is selected
    });
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
      setState(() {
    isLoading = false; // Stop shimmer effect
  });
      return UserInfo.fromJson(jsonDecode(savedUserInfo));
    } else {
      throw Exception('User info not found');
    }
  }


  Future<List<Map<String, dynamic>>> _loadUserInfo() async {
    final db = DatabaseHelper();
    return await db.getUsers();
  }

  Future<void> _fetchUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final mobile_number = prefs.getString('mobile_number');
    print("SharedPreferences");

    if (mobile_number == null) {
      print("Mobile number not found in SharedPreferences");
      return;
    } else {
      print("Mobile number found in SharedPreferences");
    }

    try {
      await APIservice.getResidentInfo(
          mobile_number, DatabaseHelper.colBuildingId.toString());
  //     setState(() {
  //   isLoading = false; // Start shimmer effect
  // });
      print("Resident Data Retrieved: ");
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  Matrix4 getTransformMatrix(TransformableListItem item) {
    const endScaleBound = 0.9;
    final animationProgress = item.visibleExtent / item.size.height;
    final paintTransform = Matrix4.identity();

    if (item.position != TransformableListItemPosition.middle) {
      final scale = endScaleBound + ((1 - endScaleBound) * animationProgress);
      paintTransform
        ..translate(item.size.width / 2)
        ..scale(scale)
        ..translate(-item.size.width / 2);
    }

    return paintTransform;
  }

 

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Member Details'),
    ),
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 93, 192, 238), Colors.blueAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: isLoading
    ? Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          itemCount: 10, // The number of items to show while loading
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16), // Inner padding
                  title: Container(
                    height: 20, // Placeholder height
                    color: Colors.white,
                  ),
                  subtitle: Container(
                    height: 15, // Placeholder height
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ): FutureBuilder<List<Map<String, dynamic>>>(
        future: residentsFuture,
        builder: (context, snapshot) {
          if ( snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());  
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No residents found.'));
          } else {
            final members = snapshot.data!;
            return TransformableListView.builder(
              getTransformMatrix: getTransformMatrix,
              itemBuilder: (context, index) {
                final member = members[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            "${member['flat_no']}", // Assuming flatNo is the identifier
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    member['resident_name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800]!,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "${member['floor_no']}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Mobile: ${member['mobile_number']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                "Wing: ${member['wing_no']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: members.length,
            );
          }
        },
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () async {
         _pickAndParseCsv(); // Assuming this method fetches data
        },
      child: const Icon(Icons.add),
      backgroundColor: Colors.blueAccent,
    ),
  );
}}

