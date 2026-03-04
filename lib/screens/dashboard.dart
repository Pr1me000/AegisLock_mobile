import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;
  double _rssiLimit = -60.0;
  String _status = "Vérification Identité...";
  String _debugLog = "Initialisation système...";
  List<int> _rssiHistory = [];
  final String _targetMac = "60:FF:9E:4A:C7:59"; 
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () { 
      if (mounted) _checkBiometrics(); 
    });
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Accès sécurisé à AegisLock',
      );
      if (authenticated) {
        setState(() {
          _isAuthenticated = true;
          _status = "SCAN BLE ACTIF";
        });
        _startSecureScan();
      }
    } catch (e) {
      setState(() => _debugLog = "Erreur Bio: $e");
    }
  }

  void _startSecureScan() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    setState(() => _debugLog = "Cible : $_targetMac");
    FlutterBluePlus.startScan(timeout: null);

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.remoteId.toString().toUpperCase() == _targetMac) {
          _handleSignal(r.rssi);
        }
      }
    });
  }

  void _handleSignal(int currentRssi) {
    if (!mounted) return;
    setState(() {
      _rssiHistory.add(currentRssi);
      if (_rssiHistory.length > 10) _rssiHistory.removeAt(0);
      double average = _rssiHistory.reduce((a, b) => a + b) / _rssiHistory.length;
      _debugLog = "RSSI: $currentRssi | Moy: ${average.toStringAsFixed(1)} dBm";

      if (average > _rssiLimit) {
        _status = "PORTÉE OK (PC DÉVERROUILLÉ)";
      } else {
        _status = "HORS PORTÉE (VERROUILLAGE...)";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    final double screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("AEGIS-LOCK", style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          const Spacer(flex: 7), 

          Text(_status, style: TextStyle(fontSize: screenW * 0.04, color: Colors.white70)),
          SizedBox(height: screenH * 0.02),
          
          Center(
            child: GestureDetector(
              onTap: _checkBiometrics,
              child: Container(
                width: screenW * 0.45, 
                height: screenW * 0.45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isAuthenticated ? Colors.green.withOpacity(0.05) : Colors.cyan.withOpacity(0.05),
                  border: Border.all(
                    color: _isAuthenticated ? Colors.greenAccent : Colors.cyanAccent, 
                    width: 2
                  ),
                ),
                child: Icon(
                  _isAuthenticated ? Icons.security : Icons.fingerprint, 
                  size: screenW * 0.18, 
                  color: Colors.white
                ),
              ),
            ),
          ),

          const SizedBox(height: 60),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(horizontal: screenW * 0.06, vertical: 5),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
            child: Text(_debugLog, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 10)),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenW * 0.08),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("SEUIL", style: TextStyle(color: Colors.white38, fontSize: 10)),
                    Text("${_rssiLimit.toInt()} dBm", style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 10)),
                  ],
                ),
                Slider(
                  value: _rssiLimit,
                  min: -100, max: -20,
                  activeColor: Colors.cyanAccent,
                  onChanged: (val) => setState(() => _rssiLimit = val),
                ),
              ],
            ),
          ),
          
          const Spacer(flex: 3), 
        ],
      ),
    );
  }
}