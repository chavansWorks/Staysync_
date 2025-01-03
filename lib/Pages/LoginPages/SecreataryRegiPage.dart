import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:staysync/Pages/LoginPages/BuildingRegiPage.dart';
import 'package:staysync/Pages/LoginPages/SignIn.dart';
import 'package:path_provider/path_provider.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _agreeToTerms = false;
  String? _aadharDocument;
  String? _buildingProofDocument;

  bool _isDocumentSectionOpen = false;

  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  String? _selectedGender; //

  void signUp() {
    // Handle sign-up logic here
    print("Signed up with mobile: ${_mobileController.text}");
  }

  void resendOtp() {
    // Handle OTP resend logic here
    print("OTP resent to mobile: ${_mobileController.text}");
  }

  Future<void> _pickDocument(String documentType) async {
    print("file Piked");
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        String filePath = pickedFile.path;

        // Get the app's document directory
        Directory appDocDirectory = await getApplicationDocumentsDirectory();
        String newFilePath = '${appDocDirectory.path}/${pickedFile.name}';

        // Copy the file to the new path
        File newFile = File(newFilePath);
        await File(filePath).copy(newFilePath);

        setState(() {
          if (documentType == 'aadhar') {
            _aadharDocument = newFilePath; // Store the Aadhar document path
          } else if (documentType == 'AppointmentLetter') {
            _buildingProofDocument =
                newFilePath; // Store the Appointment Letter path
          }
        });

        print('File saved at: $newFilePath');
      }
    } catch (e) {
      print("Error picking document: $e");
      _showInfoDialog("Error", "An error occurred while picking the document.");
    }
  }

  Widget _buildNameTF(String text, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          text.toString(),
          style: TextStyle(color: Colors.white, fontSize: 15.5),
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
            controller: _fullNameController,
            keyboardType: TextInputType.name,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.person,
                color: Colors.white,
              ),
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown(String text, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          text.toString(),
          style: TextStyle(color: Colors.white, fontSize: 15.5),
        ),
        SizedBox(height: 10.0),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.white, width: 1.5),
            borderRadius: BorderRadius.circular(10.0),
          ),
          height: 60.0,
          child: DropdownButton<String>(
            hint: Text(
              hintText,
              style: TextStyle(color: Colors.white),
            ),
            value: _selectedGender,
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
            ),
            style: TextStyle(color: Colors.white),
            dropdownColor: Colors.black,
            isExpanded: true,
            underline: SizedBox(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedGender = newValue!;
              });
            },
            items: <String>['MALE', 'FEMALE', 'OTHER']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDOBTF(String text, String hintText, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          text.toString(),
          style: TextStyle(color: Colors.white, fontSize: 15.5),
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
            controller: _dobController,
            readOnly: true, // To prevent manual input
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.calendar_today,
                color: Colors.white,
              ),
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                _dobController.text = "${pickedDate.toLocal()}"
                    .split(' ')[0]; // Format to YYYY-MM-DD
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Mobile Number',
          style: TextStyle(color: Colors.white, fontSize: 15.5),
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
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.phone,
                color: Colors.white,
              ),
              hintText: 'Enter your Mobile Number',
              hintStyle: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'OTP',
          style: TextStyle(color: Colors.white, fontSize: 15.5),
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
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Enter OTP',
              hintStyle: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
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

  Widget _buildDocumentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            setState(() {
              _isDocumentSectionOpen = !_isDocumentSectionOpen;
            });
          },
          child: Row(
            children: [
              Icon(
                _isDocumentSectionOpen
                    ? Icons.arrow_drop_up
                    : Icons.arrow_drop_down,
                color: Colors.white,
              ),
              Flexible(
                child: Text(
                  'Upload Documents',
                  style: TextStyle(color: Colors.white, fontSize: 15.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (_isDocumentSectionOpen) ...[
          SizedBox(height: 10.0),
          GestureDetector(
            child: _buildDocumentPicker('Proof Of Identity', _aadharDocument,
                'Can Upload Aadhar, Pan Card, Driving License', 'aadhar'),
          ),
          SizedBox(height: 10.0),
          GestureDetector(
            child: _buildDocumentPicker(
                'Appointment Letter',
                _buildingProofDocument,
                'Please Upload Appointment Letter or any Document Showing You are Secretary',
                'AppointmentLetter'),
          ),
          SizedBox(height: 10.0),
        ],
      ],
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDocumentPicker(String documentLabel, String? documentName,
      String infoMessage, String documentType) {
    return GestureDetector(
      onTap: () {
        print("file Deas");
        _pickDocument(documentType); // Pass the documentType correctly
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              height: 60.0,
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Icon(
                    documentName == null
                        ? Icons.upload_file
                        : Icons.check_circle,
                    color: documentName == null ? Colors.white : Colors.green,
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      documentName == null
                          ? documentLabel
                          : 'Document: $documentName',
                      style: TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.info, color: Colors.white),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Document Info',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            content: Text(
                              infoMessage,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'OK',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            contentPadding: EdgeInsets.all(20),
                            buttonPadding: EdgeInsets.only(right: 20),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Displaying the selected image
          if (documentName != null)
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Image.file(
                File(documentName), // Display the selected image
                width: 50.0,
                height: 50.0,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBtn(String buttonName) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_fullNameController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please enter your name')),
            );
          } else if (_selectedGender.toString() == 'null') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please Select your Gender')),
            );
          } else if (_dobController.text == '') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please enter your Date of Birth')),
            );
          } else if (_aadharDocument.toString() == 'null') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please upload your Aadhar document')),
            );
          } else if (_buildingProofDocument.toString() == 'null') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please select your Appointment Letter')),
            );
          } else {
            print(_aadharDocument.toString());
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BuildingRegistrationPage(
                  secretaryName: _fullNameController.text,
                  DOB: _dobController.text,
                  gender: _selectedGender.toString(),
                  Document: _aadharDocument.toString(),
                  DocumentAppointment: _buildingProofDocument.toString(),
                ),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Background color
          padding: EdgeInsets.symmetric(vertical: 15.0),
        ),
        child: Text(
          buttonName,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginBtn() {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignInScreen(),
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Already have an Account? ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Sign in',
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
                    SizedBox(height: 30.0),
                    Center(
                      child: Text(
                        'Register your Building Complex.',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily:
                              'Regular Italic', // Use the Dancing Script font
                          fontSize: 35.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 30.0),
                    _buildNameTF("Secretary Full Name", "Enter your Name"),
                    SizedBox(height: 20.0),
                    _buildDOBTF("Date of Birth",
                        "Please Select your date of birth", context),
                    SizedBox(height: 20.0),
                    _buildGenderDropdown(
                        "Please Select gender", "Please Select your Gender"),
                    SizedBox(height: 20.0),
                    _buildDocumentSection(),
                    SizedBox(height: 15.0),
                    SizedBox(height: 10.0),
                    SizedBox(height: 10.0),
                    _buildBtn("Next"),
                    SizedBox(height: 10.0),
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
