import 'dart:convert'; // For JSON encoding/decoding
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staysync/API/URLs.dart';
import 'package:http_parser/http_parser.dart';
import 'package:staysync/Database/DatabaseHelper.dart';
import 'package:staysync/Pages/ResidentInfo.dart';
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
          var userInfo = UserInfo.fromJson(responseData['data']['userInfo']);
          print("Userin");

          print(userInfo.name);
          final prefs = await SharedPreferences.getInstance();

          // Save the user info as JSON string
          prefs.setString('user_info', jsonEncode(userInfo.toJson()));
          // Save user info to SQLite
          final dbHelper = DatabaseHelper();
          prefs.setString('building_id', userInfo.buildingId);

          await dbHelper.insertUser({
            'userid': userInfo.userid,
            'name': userInfo.name,
            'gender': userInfo.gender,
            'dob': userInfo.dob,
            'mobile_number': userInfo.mobileNumber,
            'usertype': userInfo.usertype,
            'building_id': userInfo.buildingId,
            'resident_name': userInfo.residentName,
            'no_of_flats': userInfo.noOfFlats,
            'address': userInfo.address,
            'address_proof': userInfo.addressProof,
            'secretary_id': userInfo.secretaryId,
            'secretary_name': userInfo.secretaryName,
            'created_at': userInfo.createdAt,
            'updated_at': userInfo.updatedAt,
            'auth_token': jwtToken, // Assuming you are saving JWT token as well
            'last_synced_at':
                DateTime.now().toIso8601String(), // Current timestamp
          });

          print("User info saved to SQLite successfully!");

          return userInfo;
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

  static Future<List<Resident>?> retrySubmission({
    required String userId,
    required String buildingId,
    required List<Resident> residents,
    int retryCount = 3,
  }) async {
    List<Resident>? residentData; // Nullable list to handle failures

    for (int i = 0; i < retryCount; i++) {
      try {
        // Prepare the data for API request (this is the data you'll send)
        Map<String, dynamic> data = {
          'userId': userId,
          'buildingId': buildingId,
          'ExcelData': residents.map((resident) {
            return {
              'resident_name': resident.name,
              'user_gender': resident.gender,
              'mobile_number': resident.mobileNumber,
              'user_dob': resident.dob,
              'wing_no': resident.wingNo,
              'flat_no': resident.flatNo,
              'floor_no': resident.floorNo,
            };
          }).toList(),
        };

        // Pass the original 'residents' list to submitToAPI
        residentData = await submitToAPI(
          userId: userId,
          buildingId: buildingId,
          residents: residents, // Pass the 'residents' list, not the map
        );

        if (residentData != null) {
          print("Submission successful on attempt ${i + 1}");
          return residentData;
        }
      } catch (error) {
        print("Attempt ${i + 1} failed: $error");
        if (i == retryCount - 1) {
          throw Exception("All attempts to submit data failed.");
        }
      }
    }

    return null; // Return null if all retries failed
  }

  static Future<void> saveToLocalDatabase(List<Resident> residents) async {
    final db = DatabaseHelper();
    for (var resident in residents) {
      await db.insertResident(resident.toJson());
    }
    print("Residents saved to local database.");
  }

  static Future<List<Resident>?> submitToAPI({
    required String userId,
    required String buildingId,
    required List<Resident> residents,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwtToken = prefs.getString('Token');

    // Prepare the data with only relevant fields for the API
    Map<String, dynamic> data = {
      'userId': userId,
      'buildingId': buildingId,
      'ExcelData': residents.map((resident) {
        return {
          'name': resident.name,
          'gender': resident.gender,
          'mobile_number': resident.mobileNumber,
          'dob': resident.dob,
          'wing_no': resident.wingNo,
          'flat_no': resident.flatNo,
          'floor_no': resident.floorNo,
        };
      }).toList(),
    };

    final response = await http.post(
      Uri.parse(ResidentExcelAPI),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$jwtToken',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print("Data submitted successfully: ${response.body}");

      // Parse the response body
      Map<String, dynamic> responseData = jsonDecode(response.body);

      // Check if the response contains the resident data
      if (responseData['status'] == 'true') {
        List<dynamic> residentsData = responseData['data'];

        // Convert the API response data into Resident objects
        List<Resident> updatedResidents = residentsData.map((residentJson) {
          return Resident(
            userId: residentJson['userId'],
            name: residentJson['resident_name'],
            gender: residentJson['user_gender'],
            mobileNumber: residentJson['mobile_number'],
            dob: residentJson['user_dob'],
            wingNo: residentJson['wing_no'],
            flatNo: residentJson['flat_no'],
            floorNo: residentJson['floor_no'],
            createdAt: residentJson['created_at'],
            updatedAt: residentJson['updated_at'],
          );
        }).toList();

        // Print updated residents
        updatedResidents.forEach((resident) {
          print("resident.toString()");

          print(resident.toString());
        });

        // Return the updated residents
        return updatedResidents;
      } else {
        print("Error in response: ${responseData['status']}");
        return null; // Return null in case of error
      }
    } else {
      print("Failed to submit data: ${response.statusCode}");
      return null; // Return null in case of failure
    }
  }

  static Future<void> submitExcelData({
    required String userId,
    required String buildingId,
    required List<Resident> residents,
  }) async {
    print("Resident Data");
    print(residents[0].toString());

    try {
      // Save to local database

      // Submit to API with retry mechanism
      List<Resident>? updatedResidents = await retrySubmission(
        userId: userId,
        buildingId: buildingId,
        residents: residents,
      );

      if (updatedResidents != null) {
        print(updatedResidents[0].toString());

        await saveToLocalDatabase(updatedResidents);

        print("Updated residents after submission:");
        updatedResidents.forEach((resident) {
          print(resident.toString());
        });
      }
    } catch (error) {
      print("Error in submitting Excel data: $error");
    }
  }

  static Future<void> getResidentInfo(
      String mobileNumber, String buildingId) async {
    print("Fetching Resident Info");

    try {
      // Retrieve token from SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwtToken = prefs.getString('Token'); // Get the token stored

      if (jwtToken == null) {
        throw Exception('No token found');
      }

      // Make the POST request to fetch user info
      final response = await http.post(
        Uri.parse(GetResidentInfoAPI), // Your API URL here
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$jwtToken',
        },
        body: jsonEncode({
          'mobile_number': mobileNumber,
          'buildingId': buildingId,
        }),
      );

      print("Raw response body: ${response.body}"); // Log the raw response
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['status'] == true) {
        final userData = responseData['data']['userData'] as List;

        if (userData.isNotEmpty) {
          // Insert each resident into the database
          for (var user in userData) {
            // Map each item in userData to a map for the database
            Map<String, dynamic> residentMap = {
              'userid': user['userid'],
              'user_name': user['resident_name'],
              'user_gender': user['user_gender'],
              'user_dob': user['user_dob'],
              'mobile_number': user['mobile_number'],
              'login_id': user['login_id'],
              'usertype': user['usertype'],
              'resident_id': user['resident_id'],
              'building_id': user['building_id'],
              'wing_no': user['wing_no'],
              'flat_no': user['flat_no'],
              'floor_no': user['floor_no'],
              'resident_name': user['resident_name'],
              'created_at': user['created_at'],
              'updated_at': user['updated_at']
            };

            // Insert the resident data into the database
            await DatabaseHelper().insertResident(residentMap);
          }

          print("Resident data saved to the database.");
        } else {
          throw Exception('No resident data available');
        }
      } else {
        throw Exception(
            'Failed to fetch user data: ${responseData['message']}');
      }

      // Parse the response body

      // Check response status code and handle the data accordingly
    } catch (err) {
      print("Error getting user infsssso: $err");
      throw Exception('Error fetching user info');
    }
  }
}
