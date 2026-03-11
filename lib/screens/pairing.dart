import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Pairing extends StatefulWidget {
  const Pairing({super.key});

  @override
  State<Pairing> createState() => _PairingState();
}

class _PairingState extends State<Pairing> {
  bool _isFinishing = false;

  void _finalize(String secret) async {
    if (_isFinishing) return;
    _isFinishing = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pairing_secret', secret);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Code QR enregistré"), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SCANNER LE PC"), backgroundColor: Colors.black),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) _finalize(barcodes.first.rawValue ?? "");
        },
      ),
    );
  }
}