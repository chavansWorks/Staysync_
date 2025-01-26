import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:collection/collection.dart';
import 'dart:io';

import 'package:staysync/API/URLs.dart';
import 'package:staysync/Pages/SecerataryPages/ViewStaff.dart';

class UploadCSVPage extends StatelessWidget {
  const UploadCSVPage({Key? key}) : super(key: key);

  void selectAndUploadCSV(BuildContext context) async {
    // Step 1: Pick a CSV File
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String csvData = await file.readAsString();

      // Step 2: Parse CSV Locally
      List<List<dynamic>> csvRows = const CsvToListConverter().convert(csvData);
      if (csvRows.isEmpty) {
        showSnackBar(context, 'CSV is empty.');
        return;
      }

      // Validate CSV Header (First Row)
      List<String> expectedHeaders = [
        'staff_name',
        'staff_type',
        'address',
        'mobile_number',
        'gender',
        'dob',
      ];
      List<dynamic> csvHeaders =
          csvRows.first.map((e) => e.toString()).toList();
      if (!ListEquality().equals(csvHeaders, expectedHeaders)) {
        showSnackBar(
            context, 'Invalid CSV headers. Expected: $expectedHeaders');
        return;
      }

      // Optional: Validate Data Rows
      for (int i = 1; i < csvRows.length; i++) {
        List<dynamic> row = csvRows[i];
        // if (row.length != expectedHeaders.length) {
        //   showSnackBar(context, 'Row $i has invalid column count.');
        //   return;
        // }

        // // Validate individual columns
        // if (row[0].isEmpty) {
        //   showSnackBar(context, 'Staff name is required in row $i.');
        //   return;
        // }

        // if (row[2].isEmpty) {
        //   showSnackBar(context, 'Address is required in row $i.');
        //   return;
        // }

        // if (row[4].isEmpty) {
        //   showSnackBar(context, 'Gender is required in row $i.');
        //   return;
        // }

        // if (row[5].isEmpty || !RegExp(r'\d{4}-\d{2}-\d{2}').hasMatch(row[5])) {
        //   showSnackBar(
        //       context, 'Invalid date format in row $i. Expected YYYY-MM-DD.');
        //   return;
        // }

        // if (row[1].isEmpty) {
        //   showSnackBar(context, 'Staff type is required in row $i.');
        //   return;
        // }

        // Validate email format (if applicable in staff_type or another column)
        // if (row[2].isEmpty || !RegExp(r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(row[2])) {
        //   showSnackBar(context, 'Invalid email format in row $i.');
        //   return;
        // }
      }

      // Step 3: Upload CSV to Server
      try {
        FormData formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(file.path,
              filename: file.path.split('/').last),
        });

        Dio dio = Dio();
        Response response = await dio.post(
          AddStaffCSV, // Replace with your actual server URL
          data: formData,
        );

        showSnackBar(context, 'Upload success: ${response.data}');
      } catch (e) {
        showSnackBar(context, 'Upload failed: $e');
      }
    } else {
      showSnackBar(context, 'No file selected.');
    }
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload CSV'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => selectAndUploadCSV(context),
              child: const Text('Upload CSV'),
            ),
            const SizedBox(height: 20), // Spacing between the buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StaffPage(), // Ensure StaffPage is implemented
                  ),
                );
              },
              child: const Text('View Staff Page'),
            ),
          ],
        ),
      ),
    );
  }
}
