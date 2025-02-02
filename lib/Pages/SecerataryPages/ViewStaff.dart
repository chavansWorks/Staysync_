import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:staysync/API/URLs.dart';
import 'package:staysync/Database/DatabaseHelper.dart';
import 'package:transformable_list_view/transformable_list_view.dart';

import 'package:staysync/API/api.dart';

import 'package:collection/collection.dart';

class StaffPage extends StatefulWidget {
  @override
  _StaffPageState createState() => _StaffPageState();
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

class _StaffPageState extends State<StaffPage> {
  late Future<List<Map<String, dynamic>>> staffFuture;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    staffFuture = DatabaseHelper().getStaff(); // Fetch staff info from DB
    _fetchStaffInfo(); // Fetch updated staff info from the API
  }

  void selectAndUploadCSV(BuildContext context) async {
    // Step 1: Pick a CSV File
    setState(() {
      isLoading = true; // Start shimmer effect
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String csvData = await file.readAsString();

      // Step 2: Parse CSV Locally
      List<List<dynamic>> csvRows = const CsvToListConverter().convert(csvData);
      if (csvRows.isEmpty) {
        showSnackBar(context, 'CSV is empty.');
        return;
      }

      // Validate CSV Header (First Row)
      List<String> expectedHeaders = [
        'staff_name',
        'staff_type',
        'address',
        'mobile_number',
        'gender',
        'dob',
      ];
      List<dynamic> csvHeaders =
          csvRows.first.map((e) => e.toString()).toList();
      if (!ListEquality().equals(csvHeaders, expectedHeaders)) {
        showSnackBar(
            context, 'Invalid CSV headers. Expected: $expectedHeaders');
        return;
      }

      // Optional: Validate Data Rows
      for (int i = 1; i < csvRows.length; i++) {
        List<dynamic> row = csvRows[i];
        // if (row.length != expectedHeaders.length) {
        //   showSnackBar(context, 'Row $i has invalid column count.');
        //   return;
        // }

        // // Validate individual columns
        // if (row[0].isEmpty) {
        //   showSnackBar(context, 'Staff name is required in row $i.');
        //   return;
        // }

        // if (row[2].isEmpty) {
        //   showSnackBar(context, 'Address is required in row $i.');
        //   return;
        // }

        // if (row[4].isEmpty) {
        //   showSnackBar(context, 'Gender is required in row $i.');
        //   return;
        // }

        // if (row[5].isEmpty || !RegExp(r'\d{4}-\d{2}-\d{2}').hasMatch(row[5])) {
        //   showSnackBar(
        //       context, 'Invalid date format in row $i. Expected YYYY-MM-DD.');
        //   return;
        // }

        // if (row[1].isEmpty) {
        //   showSnackBar(context, 'Staff type is required in row $i.');
        //   return;
        // }

        // Validate email format (if applicable in staff_type or another column)
        // if (row[2].isEmpty || !RegExp(r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(row[2])) {
        //   showSnackBar(context, 'Invalid email format in row $i.');
        //   return;
        // }
      }

      // Step 3: Upload CSV to Server
      final prefs = await SharedPreferences.getInstance();

      final buildingId = prefs.getString('building_id');

      try {
        FormData formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
          'building_id': buildingId, // Add the building ID here
        });

        Dio dio = Dio();
        Response response = await dio.post(
          AddStaffCSV, // Replace with your actual server URL
          data: formData,
        );

        setState(() {
          isLoading = false; // Stop shimmer effect
        });

        showSnackBar(context, 'Upload success: ${response.data}');

        // Step 4: Convert CSV Rows to List<Map<String, dynamic>>
        List<Map<String, dynamic>> parsedData = [];
        for (int i = 1; i < csvRows.length; i++) {
          List<dynamic> row = csvRows[i];
          Map<String, dynamic> rowData = {
            'user_name': row[0],
            'staff_type': row[1],
            'mobile_number': row[3],
            'user_gender': row[4],
            'join_date': row[5],
          };
          parsedData.add(rowData);
        }

        // Step 5: Update the Future with parsed data
        setState(() {
          staffFuture = Future.value(
              parsedData); // Directly update with List<Map<String, dynamic>>
        });
      } catch (e) {
        setState(() {
          isLoading = false; // Stop shimmer effect if no file is selected
        });
        showSnackBar(context, 'Upload failed: ');
      }
    } else {
      setState(() {
        isLoading = false; // Stop shimmer effect if no file is selected
      });
      showSnackBar(context, 'No file selected.');
    }
  }

  Future<void> _fetchStaffInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final mobileNumber = prefs.getString('mobile_number');
    final buildingId = prefs.getString('building_id');

    if (mobileNumber == null || buildingId == null) {
      print("Missing mobile number or building ID in SharedPreferences");
      return;
    }

    try {
      final result =
          await APIservice.fetchStaffInfoAPI(mobileNumber, buildingId);

      // Fetch staff data from the database
      final dbHelper = DatabaseHelper();
      final staffData = await dbHelper.getStaff();

      if (staffData.isNotEmpty) {
        print("Staff data retrieved successfully.");
        // Process staff data here
        print(staffData);
        setState(() {
          staffFuture = Future.value(staffData); // Update the staff data
        });
        setState(() {
          isLoading = false; // Stop shimmer effect
        });
      } else {
        setState(() {
          isLoading = false; // Stop shimmer effect
        });
        print("No staff data found in the database.");
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Stop shimmer effect
      });
      print("Error fetching staff info: $e");
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Rounded corners
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.all(16), // Inner padding
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
              )
            : FutureBuilder<List<Map<String, dynamic>>>(
                future: staffFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No staff found.'));
                  } else {
                    final staffList = snapshot.data!;
                    return TransformableListView.builder(
                      getTransformMatrix: getTransformMatrix,
                      itemBuilder: (context, index) {
                        final staff = staffList[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
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
                                GestureDetector(
                                  onTap: () {
                                    if (staff['qr_code_image'] != null) {
                                      _showFullScreenImage(
                                          context,
                                          Uint8List.fromList(
                                              staff['qr_code_image']));
                                    }
                                  },
                                  child: CircleAvatar(
                                    radius: 35,
                                    backgroundColor: Colors.blueAccent,
                                    backgroundImage:
                                        staff['qr_code_image'] != null
                                            ? MemoryImage(Uint8List.fromList(
                                                staff['qr_code_image']))
                                            : null, // Set null if no image
                                    child: staff['qr_code_image'] == null
                                        ? Text(
                                            "${staff['qr_code']}", // Display QR code text if no image
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                            ),
                                          )
                                        : null, // Hide text if image is available
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            staff['user_name'] ??
                                                'No Name', // Fallback if null
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[800]!,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              staff['staff_type'] ??
                                                  'Unknown Type', // Fallback if null
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
                                        "Mobile: ${staff['mobile_number'] ?? 'No Number'}", // Fallback if null
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        "Gender: ${staff['user_gender'] ?? 'Unknown'}", // Fallback if null
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        "Join Date: ${staff['join_date'] ?? 'Unknown Date'}", // Fallback if null
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: staffList.length,
                    );
                  }
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            selectAndUploadCSV(context), // Calls file upload function
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black.withOpacity(0.8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context), // Close dialog on tap
          child: InteractiveViewer(
            panEnabled: true, // Allow panning
            boundaryMargin: EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 5.0,
            child: Image.memory(
              imageBytes,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}