import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() => runApp(const CyberSentinelApp());

class CyberSentinelApp extends StatelessWidget {
  const CyberSentinelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
      ),
      home: const Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final LocalAuthentication auth = LocalAuthentication();
  
  // VARIABLES DE CONTROLE
  bool _isAuthenticated = false;
  bool _isScanning = false;
  double _rssiLimit = -60.0;
  String _status = "Attente Biométrie";
  String _debugLog = "Prêt.";
  
  // FILTRE DE SIGNAL
  List<int> _rssiHistory = [];
  final String _targetMac = "60:FF:9E:4A:C7:59";

  StreamSubscription<List<ScanResult>>? _scanSubscription;

  // NETTOYAGE DE LA MÉMOIRE (Unique)
  @override
  void dispose() {
    _scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  // 1. AUTHENTIFICATION
  Future<void> _checkBiometrics() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Accès au PC sécurisé',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );

      if (authenticated) {
        setState(() {
          _isAuthenticated = true;
          _status = "Authentifié - Scan en cours...";
        });
        _startSecureScan();
      }
    } catch (e) {
      setState(() => _debugLog = "Erreur Bio: $e");
    }
  }

  // 2. SCAN & FILTRAGE
  void _startSecureScan() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();

    setState(() {
      _isScanning = true;
      _debugLog = "Recherche de : $_targetMac";
    });

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
    setState(() {
      _rssiHistory.add(currentRssi);
      if (_rssiHistory.length > 10) _rssiHistory.removeAt(0);

      double average = _rssiHistory.reduce((a, b) => a + b) / _rssiHistory.length;

      _debugLog = "Signal Brut: $currentRssi dBm | Moyenne: ${average.toStringAsFixed(1)}";

      if (average > _rssiLimit) {
        _status = "À PORTÉE (PC Déverrouillé)";
      } else {
        _status = "HORS PORTÉE (Verrouillage...)";
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometrics();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CYBER-SENTINEL"), centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Center(
            child: GestureDetector(
              onTap: _checkBiometrics,
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isAuthenticated ? Colors.green.withOpacity(0.1) : Colors.cyan.withOpacity(0.1),
                  border: Border.all(
                    color: _isAuthenticated ? Colors.greenAccent : Colors.cyanAccent, 
                    width: 2
                  ),
                ),
                child: Icon(
                  _isAuthenticated ? Icons.security : Icons.fingerprint, 
                  size: 80, 
                  color: Colors.white
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(_status, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text("Seuil de déverrouillage: ${_rssiLimit.toInt()} dBm"),
                Slider(
                  value: _rssiLimit,
                  min: -100, max: -20,
                  onChanged: (val) => setState(() => _rssiLimit = val),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10)
            ),
            child: Text(
              _debugLog,
              style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent),
            ),
          ),
        ],
      ),
    );
  }
}