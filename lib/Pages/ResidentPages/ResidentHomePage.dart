import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staysync/API/api.dart';
import 'package:staysync/Database/DatabaseHelper.dart';
import 'package:staysync/Pages/Dashboardcard.dart';
import 'package:staysync/Pages/Drawer.dart';
import 'package:staysync/Pages/IconWithButton.dart';
import 'package:staysync/Pages/LoginPages/LogoutPage.dart';
import 'package:staysync/Pages/UserInfo.dart';

class ResidentScreen extends StatefulWidget {
  @override
  _ResidentScreenState createState() => _ResidentScreenState();
}

class _ResidentScreenState extends State<ResidentScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<UserInfo> userInfoFuture;

  final List<DashboardItem> residentDashboardItems = [
    DashboardItem(Icons.person, "Resident Details"),
    DashboardItem(Icons.apartment, "Flat Information"),
    DashboardItem(Icons.event, "Community Events"),
    DashboardItem(Icons.phone, "Emergency Contacts"),
    DashboardItem(Icons.access_alarm, "Service Requests"),
    DashboardItem(Icons.local_parking, "Parking Details"),
    DashboardItem(Icons.notifications, "Notifications"),
    DashboardItem(Icons.help, "Help & Support"),
  ];

  @override
  void initState() {
    super.initState();
    userInfoFuture = _getUserInfo(); // Calling the method here
    _fetchUserInfo();
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

  Future<UserInfo> _getUserInfo1() async {
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

  Future<UserInfo> _loadUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUserInfo = prefs.getString('user_info');

    if (savedUserInfo != null) {
      return UserInfo.fromJson(jsonDecode(savedUserInfo));
    } else {
      throw Exception('User info not found');
    }
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
      print("Resident Data Retrieved: ");
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FutureBuilder<UserInfo>(
          future: userInfoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text(
                "Loading...",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            } else if (snapshot.hasError) {
              return Text(
                "Error",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            } else if (snapshot.hasData) {
              return Text(
                snapshot.data!.residentName,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            } else {
              return Text(
                "No Data",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            }
          },
        ),
      ),
      drawer: CustomDrawer(),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blue background with rounded corners and notice card
            PreferredSize(
              preferredSize: const Size.fromHeight(200),
              child: Stack(
                children: [
                  // Blue background container
                  Container(
                    height: 280,
                    decoration: BoxDecoration(
                      color: Colors.blue[800],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                  // Notice Card at the top
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 100.0, left: 16, right: 16),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: const Row(
                        children: [
                          Icon(Icons.announcement, color: Colors.grey),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Notice: Upcoming Maintenance Tomorrow...",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom card for community app notice
                  Padding(
                    padding: const EdgeInsets.only(top: 160.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CarouselSlider(
                        items: [
                          _buildCarouselItem(
                              "https://media.istockphoto.com/id/978975308/vector/upcoming-events-neon-signs-vector-upcoming-events-design-template-neon-sign-light-banner-neon.jpg?s=612x612&w=0&k=20&c=VMCoJJda9L17HVkFOFB3fyDpjC4Qu2AsyYn3u4T4F4c="),
                          _buildCarouselItem(
                              "https://static.vecteezy.com/system/resources/previews/014/435/755/non_2x/attention-please-announcement-sign-with-megaphone-flat-illustration-important-alert-icon-vector.jpg"),
                          _buildCarouselItem(
                              "https://4.imimg.com/data4/WM/AR/MY-25909262/notice-board-250x250.jpg"),
                        ],
                        options: CarouselOptions(
                          height: 165.0,
                          enlargeCenterPage: true,
                          autoPlay: true,
                          aspectRatio: 16 / 9,
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enableInfiniteScroll: true,
                          autoPlayAnimationDuration:
                              Duration(milliseconds: 800),
                          viewportFraction: 0.8,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 360.0, left: 16),
                    child: Text(
                      "Resident Features",
                      style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 310.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: residentDashboardItems.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 18,
                        ),
                        itemBuilder: (context, index) {
                          final item = residentDashboardItems[index];
                          return DashboardCard(item: item);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue[700],
        height: 92,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconWithTextButton(
              icon: Icons.home,
              label: "Home",
              onPressed: () {
                LogoutHelper.logout(context);
                print("Home button pressed");
              },
            ),
            IconWithTextButton(
              icon: Icons.add_box,
              label: "Delivery",
              onPressed: () {
                print("Delivery button pressed");
              },
            ),
            const SizedBox(width: 20), // Space for the QR Code button
            IconWithTextButton(
              icon: Icons.apartment,
              label: "Building",
              onPressed: () {
                print("Building button pressed");
              },
            ),
            IconWithTextButton(
              icon: Icons.person,
              label: "You",
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[800],
        onPressed: () {},
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildCarouselItem(String imageUrl) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: 1000.0,
        ),
      ),
    );
  }
}
