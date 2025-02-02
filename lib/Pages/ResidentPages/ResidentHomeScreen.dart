import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staysync/API/api.dart';
import 'package:staysync/Database/DatabaseHelper.dart';
import 'package:staysync/Pages/ResidentDrawer.dart';
import 'package:staysync/Pages/LoginPages/LogoutPage.dart';
import 'package:staysync/Pages/IconWithButton.dart';
import 'package:staysync/Pages/IconWithButton.dart';
import 'package:staysync/Pages/ResidentPages/Resident.dart';
import 'package:staysync/Pages/UserInfo.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:staysync/Pages/Dashboardcard.dart';
import 'package:staysync/Pages/ResidentPages/Rules.dart';

import 'Calendar.dart';
import 'StaffLink.dart';

class ResidentHomeScreen extends StatefulWidget {
  @override
  _ResidentHomeScreenState createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<ResidentInfo> userInfoFuture;

  final List<DashboardItem> dashboardItems = [
    DashboardItem(Icons.notifications, "Notices"),
    DashboardItem(Icons.manage_accounts, "Staff"),
    DashboardItem(Icons.group, "Residents"),
    DashboardItem(Icons.cleaning_services, "Maintenance"),
    DashboardItem(Icons.directions_car, "Parking"),
    DashboardItem(Icons.phone, "Emergency")
  ];

@override
void initState() {
  super.initState();
  userInfoFuture = _fetchResidentInfo(); // Call a function to fetch and convert data
}

Future<ResidentInfo> _fetchResidentInfo() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedUserInfo = prefs.getString('user_info');
  final mobile_number = prefs.getString('mobile_number');
  
  await APIservice.getResidentInfo(mobile_number!);
  List<Map<String, dynamic>> residentsData = await DatabaseHelper().getResidents();
  print("Residents data from DB: $residentsData");

  await prefs.setString('user_info', jsonEncode(residentsData.first));

  print("Resident info saved in SharedPreferences: ${jsonEncode(residentsData.first)}");

  if (residentsData.isNotEmpty) {
    // Convert the first resident from the list into a ResidentInfo object
    return ResidentInfo.fromJson(residentsData.first);
    

  } else {
    throw Exception("No resident data found.");
  }
}

  // Function to logout
  void logout(BuildContext context) async {
    LogoutHelper.logout(context);
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    key: _scaffoldKey,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: FutureBuilder<ResidentInfo>(
        future: userInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text(
              "Welcome, Resident!",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            );
          } else if (snapshot.hasError) {
            debugPrint("Error: ${snapshot.error}");
            return Text(
              "Error",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            );
          } else if (snapshot.hasData) {
            return Text(
              "Welcome, ${snapshot.data!.residentName}",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            );
          } else {
            return Text(
              "Welcome!",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            PreferredSize(
              preferredSize: const Size.fromHeight(200),
              child: Stack(
                children: [
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
                  Padding(
                    padding: const EdgeInsets.only(top: 100.0, left: 16, right: 16),
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
                              "Notice: Water supply maintenance tomorrow.",
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
                  Padding(
                    padding: const EdgeInsets.only(top: 160.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CarouselSlider(
                        items: [
                          // 1st Image of Slider
                          _buildCarouselItem(
                              "https://media.istockphoto.com/id/978975308/vector/upcoming-events-neon-signs-vector-upcoming-events-design-template-neon-sign-light-banner-neon.jpg?s=612x612&w=0&k=20&c=VMCoJJda9L17HVkFOFB3fyDpjC4Qu2AsyYn3u4T4F4c="),
                          // 2nd Image of Slider
                          _buildCarouselItem(
                              "https://static.vecteezy.com/system/resources/previews/014/435/755/non_2x/attention-please-announcement-sign-with-megaphone-flat-illustration-important-alert-icon-vector.jpg"),
                          // 3rd Image of Slider
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
                          autoPlayAnimationDuration: Duration(milliseconds: 800),
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
                    padding: const EdgeInsets.only(top: 290.0),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: dashboardItems.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 2 / 1.3,
                        ),
                        itemBuilder: (context, index) {
                          final item = dashboardItems[index];
                          return DashboardCard(
                            item: item,
                            onTap: () {
                              switch (item.label) {
                                case "Notices":
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ResidentHomeScreen()),
                                  );
                                  break;
                                case "Staff":
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => StaffLink()),
                                  );
                                  break;
                                case "Maintenance":
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ResidentHomeScreen()),
                                  );
                                  break;
                                case "Residents":
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ResidentHomeScreen()),
                                  );
                                  break;
                                case "Parking":
                                  logout(context);
                                  break;
                                case "Emergency":
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Emergency"),
                                      content: Text(
                                          "Emergency contacts are displayed here!"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text("OK"),
                                        ),
                                      ],
                                    ),
                                  );
                                  break;
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                print("Home button pressed");
              },
            ),
            IconWithTextButton(
              icon: Icons.rule,
              label: "Rules",
              onPressed: () {
                Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RulesOfSocietyPage()),
            );
              },
            ),
            const SizedBox(width: 20), // Space for the QR Code button

            IconWithTextButton(
              icon: Icons.event,
              label: "Events",
              onPressed: () {
                print("Feedback button pressed");
              },
            ),
            IconWithTextButton(
              icon: Icons.person,
              label: "Profile",
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

  // Helper function to build carousel item
  Widget _buildCarouselItem(String imageUrl) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }
}
