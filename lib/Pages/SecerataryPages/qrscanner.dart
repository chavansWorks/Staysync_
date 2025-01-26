import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:staysync/widgets/scan_result_widget.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  Uint8List? createdCodeBytes;
  Code? result;

  @override
  Widget build(BuildContext context) {
    final isCameraSupported = defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scan Code'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context)
                  .pop(); // Navigate back to the previous screen
            },
          ),
        ),
        body: isCameraSupported
            ? (result != null && result?.isValid == true)
                ? ScanResultWidget(
                    result: result,
                    onScanAgain: () => setState(() => result = null),
                  )
                : ReaderWidget(
                    onScan: _onScanSuccess,
                    onScanFailure: _onScanFailure,
                    onControllerCreated: _onControllerCreated,
                    resolution: ResolutionPreset.high,
                    lensDirection: CameraLensDirection.back,
                    flashOnIcon: const Icon(Icons.flash_on),
                    flashOffIcon: const Icon(Icons.flash_off),
                    flashAlwaysIcon: const Icon(Icons.flash_on),
                    flashAutoIcon: const Icon(Icons.flash_auto),
                    galleryIcon: const Icon(Icons.photo_library),
                    toggleCameraIcon: const Icon(Icons.switch_camera),
                    codeFormat: Format.qrCode,
                    actionButtonsBackgroundBorderRadius:
                        BorderRadius.circular(10),
                    actionButtonsBackgroundColor: Colors.black.withOpacity(0.5),
                  )
            : const Center(
                child: Text('Camera not supported on this platform'),
              ),
      ),
    );
  }

  void _onControllerCreated(_, Exception? error) {
    if (error != null) {
      // Handle permission or unknown errors
      _showMessage(context, 'Error: $error');
    }
  }

  void _onScanSuccess(Code? code) {
    setState(() {
      result = code;
    });

    if (code != null && code.isValid) {
      final qrCodeData = code.text ?? ''; // Fallback to empty string if null
      if (qrCodeData.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scanned QR Code: $qrCodeData'),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        _showMessage(context, 'Invalid QR Code');
      }
    } else {
      _showMessage(context, 'Invalid QR Code');
    }
  }

  void _onScanFailure(Code? code) {
    if (code?.error?.isNotEmpty == true) {
      _showMessage(context, 'Error: ${code?.error}');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
