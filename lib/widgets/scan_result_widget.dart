import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

class ScanResultWidget extends StatelessWidget {
  final Code? result;
  final VoidCallback onScanAgain;

  const ScanResultWidget({
    Key? key,
    required this.result,
    required this.onScanAgain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (result == null || !result!.isValid) {
      return const Center(child: Text('No result found.'));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Scan Result: ${result!.text ?? 'Unknown'}',
            style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onScanAgain,
          child: const Text('Scan Again'),
        ),
      ],
    );
  }
}
