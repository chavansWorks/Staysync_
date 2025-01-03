import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staysync/API/api.dart';
import 'package:staysync/Pages/LoginPages/ConfirmOtp.dart';
import 'package:staysync/Pages/LoginPages/SecreataryRegiPage.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _mobileController = TextEditingController();

  void proceedToOtpScreen() async {
    if (_mobileController.text.isNotEmpty) {
      // Call sendOtp and wait for the result
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("mobile_number", _mobileController.text);

      bool otpSent = await APIservice.sendOtp(_mobileController.text);

      // Proceed only if OTP is sent successfully
      if (otpSent) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Otp Has been Send to Your Device ${_mobileController.text}')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OtpLoginScreen(mobileNumber: _mobileController.text),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP, please try again')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your mobile number')),
      );
    }
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
            builder: (context) =>
                SignupScreen(), // Replace with your target screen
          ),
        )
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Do u want to register ur builiding? ',
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
        onPressed: proceedToOtpScreen,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 160.0),
                    Center(
                      child: Text(
                        'Sign In',
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
                    _buildMobileTF(), // TextField widget
                    SizedBox(height: 20.0),
                    _buildProceedBtn(), // Button widget
                    SizedBox(height: 20.0),
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
