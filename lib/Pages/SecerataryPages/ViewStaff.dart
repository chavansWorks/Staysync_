import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staysync/Database/DatabaseHelper.dart';
import 'package:transformable_list_view/transformable_list_view.dart';

import 'package:staysync/API/api.dart';

class StaffPage extends StatefulWidget {
  @override
  _StaffPageState createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  late Future<List<Map<String, dynamic>>> staffFuture;

  @override
  void initState() {
    super.initState();
    staffFuture = DatabaseHelper().getStaff(); // Fetch staff info from DB
    _fetchStaffInfo(); // Fetch updated staff info from the API
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
      } else {
        print("No staff data found in the database.");
      }
    } catch (e) {
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
        child: FutureBuilder<List<Map<String, dynamic>>>(
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
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              "${staff['staff_id']}", // Display staff_id
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      staff['user_name'],
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
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        staff['staff_type'],
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
                                  "Mobile: ${staff['mobile_number']}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  "Gender: ${staff['user_gender']}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  "Join Date: ${staff['join_date']}",
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
                itemCount: staffList.length,
              );
            }
          },
        ),
      ),
    );
  }
}
