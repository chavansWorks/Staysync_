import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:staysync/Pages/LoginPages/SecreataryRegiPage.dart';

import '../SecerataryPages/qrscanner.dart';

class StaffLink extends StatefulWidget {
  @override
  _StaffLinkState createState() => _StaffLinkState();
}

class _StaffLinkState extends State<StaffLink> {
  TextEditingController _mobileController = TextEditingController();

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
              hintText: 'Enter your Mobile Number',
              hintStyle: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupBtn() {
    return GestureDetector(
      onTap: () => {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignupScreen(),
          ),
        )
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Do you want to register your building? ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Sign up',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProceedBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {}, // Removed API function
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: Text(
          'Proceed to OTP',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                        'Link Staff',
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
                    Text("OR", style: TextStyle(color: Colors.white,fontSize: 17)),
                    SizedBox(height: 20.0),
                    IconButton(onPressed: () {   
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Scanner()));
                    } ,
                    icon: Icon(
                    Icons.qr_code_scanner_rounded, color: const Color.fromARGB(224, 255, 255, 255), size: 100,)),
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
