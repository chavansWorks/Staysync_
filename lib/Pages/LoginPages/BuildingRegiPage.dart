import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:staysync/API/api.dart';
import 'package:staysync/Pages/SecerataryPages/SecretaryHomeScreen.dart';

class BuildingRegistrationPage extends StatefulWidget {
  final String secretaryName;
  final String DOB;
  final String gender;
  final String Document;
  final String DocumentAppointment;

  BuildingRegistrationPage({
    required this.secretaryName,
    required this.DOB,
    required this.gender,
    required this.Document,
    required this.DocumentAppointment,
  });

  @override
  _BuildingRegistrationPageState createState() =>
      _BuildingRegistrationPageState();
}

class _BuildingRegistrationPageState extends State<BuildingRegistrationPage> {
  final TextEditingController _buildingNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  File? _addressProofDocument; // Change the type to File? (nullable)
  String? _addressProofDocumentPath;
  final TextEditingController _numFloorsController = TextEditingController();
  final TextEditingController _secretaryNameController =
      TextEditingController();
  bool _isDocumentSectionOpen = false;
  bool _agreeToTerms = false;
  File? _ownershipDocument; // Change the type to File? (nullable)

  // Pick document using FilePicker
  Future<void> _pickDocument(String documentType) async {
    print("file picked");
    try {
      // Use FilePicker to pick any document
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'jpg',
          'jpeg',
          'png',
          'docx',
          'txt'
        ], // Allowed file extensions
      );

      if (result != null) {
        // Get the picked file
        PlatformFile pickedFile = result.files.first;

        // Debug the picked file details
        print('Picked file: ${pickedFile.path}');
        print('Picked file name: ${pickedFile.name}');

        if (pickedFile.path != null) {
          // Get the app's document directory
          Directory appDocDirectory = await getApplicationDocumentsDirectory();
          String newFilePath = '${appDocDirectory.path}/${pickedFile.name}';

          // Copy the file to the new path
          File newFile = File(newFilePath);
          await File(pickedFile.path!).copy(newFilePath);

          setState(() {
            _addressProofDocumentPath = newFilePath; // Store the document path
            _addressProofDocument = newFile; // Save the document file
          });

          print('File saved at: $newFilePath');
        } else {
          print('Error: No file path found for the selected file');
          _showInfoDialog(
              "Error", "No file path found for the selected document.");
        }
      } else {
        print('Error: No document selected');
        _showInfoDialog("Error", "No document selected.");
      }
    } catch (e) {
      print("Error picking document: $e");
      _showInfoDialog("Error", "An error occurred while picking the document.");
    }
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

  Widget _buildNameTF(String text, String hintText,
      TextEditingController _buildingNameController) {
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
            controller: _buildingNameController,
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

  Widget _buildDocumentPicker(
      String documentLabel, File? document, String infoMessage) {
    return GestureDetector(
      onTap: () {
        _pickDocument("addhar"); // This triggers the pick
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
                    document == null ? Icons.upload_file : Icons.check_circle,
                    color: document == null ? Colors.white : Colors.green,
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      document == null
                          ? documentLabel
                          : 'Document: ${document.path.split('/').last}',
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
                              style: TextStyle(fontSize: 16),
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
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
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
            child: _buildDocumentPicker(
                'Proof Of Identity',
                _addressProofDocument,
                'Can Upload Aadhar, Pan Card, Driving License'),
          ),
          SizedBox(height: 10.0),
        ],
      ],
    );
  }

  Widget _buildAgreeToTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _agreeToTerms,
          activeColor: Colors.blue,
          onChanged: (bool? newValue) {
            setState(() {
              _agreeToTerms = newValue!;
            });
          },
        ),
        const Flexible(
          child: Text(
            'I confirm that the information provided is accurate.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  // Define the SubmitBuilding method inside the class
  void SubmitBuilding() async {
    print("Document Selected " + _addressProofDocument.toString());
    if (_addressProofDocument != null) {
      bool result = await APIservice.registerBuilding(
        fullName: widget.secretaryName,
        identityProof:
            File(widget.Document), // Assuming `widget.Document` is a file
        appointmentLetter:
            File(widget.DocumentAppointment), // Same for appointment letter
        addressProof: _addressProofDocument!, // Use the picked file here
        buildingName: _buildingNameController.text,
        address: _addressController.text,
        dob: widget.DOB,
        gender: widget.gender,
        noOfFlats: int.tryParse(_numFloorsController.text) ?? 0,
      );
      print(result);
      if (result) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SecretaryHomeScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload the address proof document.')),
      );
    }
  }

  Widget _buildSubmitButton(String label, void Function() Action) {
    return ElevatedButton(
      onPressed: () {
        if (_buildingNameController.text == '') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter your Building name')),
          );
        }
        if (_addressController.text == '') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter your Building name')),
          );
        }
        if (_ownershipDocument == '') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter your Building name')),
          );
        }
        if (_agreeToTerms) {
          // Handle registration submission
          Action();
          print('Building Registered!');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please agree to the terms.')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 16.0, color: Colors.white),
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
                decoration: const BoxDecoration(
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
                      const Color(0xFF73AEF5).withOpacity(0.6),
                      const Color(0xFF61A4F1).withOpacity(0.5),
                      const Color(0xFF478DE0).withOpacity(0.4),
                      const Color(0xFF398AE5).withOpacity(0.3),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 25.0, vertical: 50.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 30.0),
                    const Center(
                      child: Text(
                        'Register Your Building Complex',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    _buildNameTF('Building Name', 'Enter your building name',
                        _buildingNameController),
                    const SizedBox(height: 20.0),
                    _buildNameTF('Address', 'Enter building address',
                        _addressController),
                    SizedBox(height: 20.0),
                    _buildNameTF('Total Number of Flats',
                        'Enter number of flats', _numFloorsController),
                    SizedBox(height: 20.0),
                    _buildDocumentSection(),
                    SizedBox(height: 20.0),
                    _buildAgreeToTermsCheckbox(),
                    SizedBox(height: 20.0),
                    Center(
                      child: _buildSubmitButton(
                          'Register Building', SubmitBuilding),
                    ),
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
