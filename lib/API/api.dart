import 'dart:convert'; // For JSON encoding/decoding
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staysync/API/URLs.dart';
import 'package:http_parser/http_parser.dart';
import 'package:staysync/Pages/UserInfo.dart';

class APIservice {
  static Future<bool> registerBuilding({
    required String fullName,
    required File identityProof, // Image as File
    required File appointmentLetter, // Image as File
    required File addressProof, // Image as File
    required String buildingName,
    required String address,
    required String dob,
    required String gender,
    required int noOfFlats,
  }) async {
    print(buildingRegisterUrl); // Replace with the actual URL constant

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var jwtToken = prefs.getString('Token');
    var mobileNumber = prefs.getString('mobile_number');
    print(mobileNumber);
    print(mobileNumber.toString());

    try {
      // Prepare request body (form data)
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(buildingRegisterUrl),
      );

      // Add form fields
      request.fields['mobile_number'] = mobileNumber.toString();
      request.fields['FullName'] = fullName;
      request.fields['BuildingName'] = buildingName;
      request.fields['Address'] = address;
      request.fields['DOB'] = dob;
      request.fields['Gender'] = gender;
      request.fields['NoOfFlats'] = noOfFlats.toString();

      // Add images as multipart files
      request.files.add(await http.MultipartFile.fromPath(
        'IdentyProof',
        identityProof.path,
        contentType: MediaType(
            'image', 'jpeg'), // Adjust contentType based on the image format
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'AppointmentLetter',
        appointmentLetter.path,
        contentType: MediaType(
            'image', 'jpeg'), // Adjust contentType based on the image format
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'AddressProof',
        addressProof.path,
        contentType: MediaType(
            'image', 'jpeg'), // Adjust contentType based on the image format
      ));

      // Set the Authorization header
      request.headers['Authorization'] = '$jwtToken';

      // Send the request
      final response = await request.send();

      // Handle response
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);

        if (jsonResponse['status'] == true) {
          // Registration successful
          print("Building registered successfully: ${jsonResponse['message']}");
          return true;
        } else {
          print("Building registration failed: ${jsonResponse['message']}");
          return false;
        }
      } else {
        print("Failed to register building: ${response.statusCode}");
        return false; // API error
      }
    } catch (err) {
      print("Error registering building: $err");
      return false; // Request error
    }
  }

  // Replace 'otplogin' with the actual URL constant

  static Future<bool> sendOtp(String mobile_number) async {
    print(otplogin);
    try {
      final response = await http.post(
        Uri.parse(otplogin),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobile_number': mobile_number, // Send the mobile number
        }),
      );

      // Check response status code and return accordingly
      if (response.statusCode == 200) {
        print("OTP sent successfully: ${response.body}");
        return true; // OTP sent successfully
      } else {
        print("Failed to send OTP: ${response.statusCode} - ${response.body}");
        return false; // Failed to send OTP
      }
    } catch (err) {
      print("Error sending OTP: $err");
      return false; // Error sending OTP
    }
  }

  // Method to confirm OTP
  static Future<Map<String, dynamic>?> confirmOtp(
      String mobile_number, String OTP) async {
    print(OTP);
    try {
      final response = await http.post(
        Uri.parse(otpverify), // Use the correct URL for verifying OTP
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobile_number': mobile_number, // Send the mobile number
          'otp': OTP.toString(), // Send the OTP
        }),
      );

      // Check the response status code and return accordingly
      if (response.statusCode == 200) {
        // Parse the response JSON
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == true) {
          // Successfully confirmed OTP
          print("OTP confirmed successfully + ${responseData['token']}");

          // Extract token and user type from the response
          String token = responseData['token']; // The JWT token from response
          String userType =
              responseData['userType']; // The user type (Admin, Resident, etc.)
          // Example of storing the token and user type:
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('Token', token);
          prefs.setString('userType', userType);

          // Return the token and user type
          return {
            'token': token,
            'userType': userType,
          };
        } else {
          print("OTP confirmation failed: ${responseData['message']}");
          return null; // Failed to confirm OTP
        }
      } else {
        print(
            "Failed to confirm OTP: ${response.statusCode} - ${response.body}");
        return null; // Error confirming OTP
      }
    } catch (err) {
      print("Error confirming OTP: $err");
      return null; // Error confirming OTP
    }
  }

  static Future<UserInfo> getUserInfo(String mobile_number) async {
    try {
      // Retrieve token from SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwtToken =
          prefs.getString('Token'); // Get the token stored in SharedPreferences

      if (jwtToken == null) {
        throw Exception('No token found');
      }

      // Prepare the headers with Authorization token
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '$jwtToken', // Set the token in headers
      };

      // Make the POST request to fetch user info
      final response = await http.post(
        Uri.parse(getUserInfoUrl), // Your API URL here
        headers: headers,
        body: jsonEncode({
          'mobile_number':
              mobile_number, // Send the mobile number to fetch user info
        }),
      );

      // Check response status code and return accordingly
      if (response.statusCode == 200) {
        print("User info retrieved successfully: ${response.body}");

        // Parse the response to a Map<String, dynamic>
        Map<String, dynamic> responseData = jsonDecode(response.body);

        // Ensure the success field exists and is a boolean
        bool success = responseData['data']['success'] ?? false;

        if (success) {
          var Userin = UserInfo.fromJson(responseData['data']['userInfo']);
          print("Userin");

          print(Userin.name);
          final prefs = await SharedPreferences.getInstance();

          // Save the user info as JSON string
          prefs.setString('user_info', jsonEncode(Userin.toJson()));

          return Userin;
        } else {
          throw Exception('Failed to fetch user info');
        }
      } else {
        throw Exception('Failed to get user info: ${response.statusCode}');
      }
    } catch (err) {
      print("Error getting user info: $err");
      throw Exception('Error fetching user info');
    }
  }
}
