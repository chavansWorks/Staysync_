import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staysync/API/api.dart';
import 'package:staysync/Pages/LoginPages/SecreataryRegiPage.dart';
import 'package:staysync/Pages/homescreenDesign.dart';

class OtpLoginScreen extends StatefulWidget {
  final String mobileNumber;
  OtpLoginScreen({required this.mobileNumber});

  @override
  _OtpLoginScreenState createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  TextEditingController _otpController = TextEditingController();

  void verifyOtp() async {
    if (_otpController.text.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      var mobile_number = prefs.getString('mobile_number');
      final result =
          await APIservice.confirmOtp(widget.mobileNumber, _otpController.text);
      print(result.toString() + "Res");

      if (result != null) {
        String token = result['token'];
        String userType = result['userType'];
        if (userType == "UnregisteredUser") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SignupScreen(),
            ),
          );
        } else if (userType == "Secretary") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
          );
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('OTP Verified Welcome')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid OTP Please Enter Valid OTP')));
        print('OTP not confirmed');
      }

      // Handle OTP verification logic here
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter OTP')));
    }
  }

  Widget _buildOtpTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'OTP',
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
            controller: _otpController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0),
              prefixIcon: Icon(Icons.lock, color: Colors.white),
              hintText: 'Enter OTP',
              hintStyle: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyOtpBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: verifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: Text(
          'Verify OTP',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void resendOtp() {
    // Handle OTP resend logic here
    print("OTP resent to mobile: ${widget.mobileNumber}");
  }

  Widget _buildResendOtpBtn() {
    return TextButton(
      onPressed: resendOtp,
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          'Resend OTP',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
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
              // Background image with gradient overlay
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'lib/assets/bgimage.jpg'), // Your image asset
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 180,
                    ),
                    Center(
                      child: Text(
                        'Verify OTP for ${widget.mobileNumber}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    _buildOtpTF(),
                    _buildResendOtpBtn(),
                    SizedBox(height: 20.0),
                    _buildVerifyOtpBtn(),
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
