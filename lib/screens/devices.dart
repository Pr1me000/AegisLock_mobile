import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  State<Devices> createState() => _DevicesState();
}

class _DevicesState extends State<Devices> {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;

  void _startDiscovery() async {
    setState(() {
      _isScanning = true;
      _scanResults = [];
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      
      FlutterBluePlus.scanResults.listen((results) {
        if (mounted) setState(() => _scanResults = results);
      });

      await Future.delayed(const Duration(seconds: 4));
      if (mounted) setState(() => _isScanning = false);
    } catch (e) {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("SECURE DISCOVERY", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text(_isScanning ? "RECHERCHE..." : "RADAR PRÊT", style: const TextStyle(color: Colors.white24, fontSize: 10)),
          Expanded(
            child: ListView.builder(
              itemCount: _scanResults.length,
              itemBuilder: (context, index) {
                final res = _scanResults[index];
                return ListTile(
                  title: Text(res.device.platformName.isEmpty ? "Inconnu" : res.device.platformName),
                  subtitle: Text(res.device.remoteId.toString()),
                  trailing: const Text("LINK", style: TextStyle(color: Colors.cyanAccent)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ElevatedButton(
              onPressed: _isScanning ? null : _startDiscovery,
              child: Text(_isScanning ? "SCANNING..." : "START SCAN"),
            ),
          ),
        ],
      ),
    );
  }
}