// staff_link.dart
import 'package:flutter/material.dart';
import 'package:staysync/API/api.dart';
import 'package:flutter/services.dart';
import 'package:staysync/Pages/LoginPages/SecreataryRegiPage.dart';
// Import the API service
import '../SecerataryPages/qrscanner.dart';

class StaffLink extends StatefulWidget {
  @override
  _StaffLinkState createState() => _StaffLinkState();
}

class _StaffLinkState extends State<StaffLink> {
  TextEditingController _mobileController = TextEditingController();

  // This variable will hold the maid info returned from the API.
  Map<String, dynamic>? maidInfo;

  // For demonstration, let’s assume flatId is known or selected somewhere.
  // In a real app, this could be retrieved from the resident’s saved info.
  String flatId = "YOUR_FLAT_ID";

  // Method to call the API with the entered mobile number
  Future<void> _getMaidInfoByMobile() async {
    final staffMobile = _mobileController.text.trim();
    if (staffMobile.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please enter a mobile number.")));
      return;
    }

    final result = await APIservice.getMaidInfo(staffMobileNumber: staffMobile);
    if (result != null) {
      setState(() {
        maidInfo = result['data'];
      });
      // Optionally show a dialog or a bottom sheet with the details and a confirmation button.
      _showMaidInfoDialog();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Maid not found or an error occurred.")));
    }
  }

  // Method to call the API using a scanned QR code that returns a staff id
  Future<void> _getMaidInfoByStaffId(String staffId) async {
    final result = await APIservice.getMaidInfo(staffId: staffId);
    if (result != null) {
      setState(() {
        maidInfo = result['data'];
      });
      _showMaidInfoDialog();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Maid not found or an error occurred.")));
    }
  }

  // Dialog to display maid information and confirm linking
  void _showMaidInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Maid Info"),
          content: maidInfo != null
              ? Text("Name: ${maidInfo!['name']}\nMobile: ${maidInfo!['mobile']}")
              : Text("No info available."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Call addStaffToResident using the staff_id from maidInfo.
                if (maidInfo != null && maidInfo!['staff_id'] != null) {
                  final response = await APIservice.addStaffToResident(
                    staffId: maidInfo!['staff_id'].toString(),
                    flatId: flatId,
                  );
                  Navigator.of(context).pop(); // Close the dialog
                  if (response != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Maid linked successfully!")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to link maid.")),
                    );
                  }
                }
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Mobile Number',
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.white, width: 1.5),
            borderRadius: BorderRadius.circular(10.0),
          ),
          height: 60.0,
          child: TextField(
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(Icons.phone, color: Colors.white),
              hintText: 'Enter Maid Mobile Number',
              hintStyle: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProceedBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _getMaidInfoByMobile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: Text(
          'Proceed',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildQrBtn() {
    return IconButton(
      onPressed: () async {
        // Navigate to the Scanner page and wait for the result.
        // In this example, we assume that when a QR code is scanned,
        // the staff id is returned. You may need to modify your Scanner to do this.
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Scanner()),
        );
        // Assume the scanner returns a staff id (as a String)
        if (result != null && result is String) {
          _getMaidInfoByStaffId(result);
        }
      },
      icon: Icon(
        Icons.qr_code_scanner_rounded,
        color: Colors.white,
        size: 100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/assets/bgimage.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF73AEF5).withOpacity(0.6),
                      Color(0xFF61A4F1).withOpacity(0.5),
                      Color(0xFF478DE0).withOpacity(0.4),
                      Color(0xFF398AE5).withOpacity(0.3),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 50.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 120.0),
                    Center(
                      child: Text(
                        'Link Maid',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Regular Italic',
                          fontSize: 35.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 50.0),
                    _buildMobileTF(),
                    SizedBox(height: 20.0),
                    _buildProceedBtn(),
                    SizedBox(height: 20.0),
                    Text("OR", style: TextStyle(color: Colors.white, fontSize: 17)),
                    SizedBox(height: 20.0),
                    _buildQrBtn(),
                    SizedBox(height: 20.0),
                    Text("Scan QR Code", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
