import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart'; // Biométrie
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // Bluetooth

void main() => runApp(const CyberSentinelApp());

class CyberSentinelApp extends StatelessWidget {
  const CyberSentinelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117), // Look "Hacker" sombre
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
  bool _isScanning = false;
  double _rssiLimit = -60.0; // Ton curseur de distance

  // FONCTION CYBER 1 : Authentification Biométrique
  Future<void> _checkBiometrics() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Scannez votre empreinte pour déverrouiller le PC',
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (e) { print(e); }

    if (authenticated) {
      _startSecureScan(); // Si OK, on lance la détection Bluetooth
    }
  }

  // FONCTION CYBER 2 : Scan BLE (Recherche du PC)
  void _startSecureScan() {
    setState(() => _isScanning = true);
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    // On écoute les périphériques autour
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        // Remplace par le nom Bluetooth de ton PC pour le test
        if (r.device.platformName == "TON_NOM_DE_PC") {
          print("PC Trouvé ! Signal : ${r.rssi} dBm");
          if (r.rssi > _rssiLimit) {
            print("Action : Envoyer Clé de Déverrouillage");
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CYBER-SENTINEL"), backgroundColor: Colors.transparent),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Indicateur Visuel Central
            GestureDetector(
              onTap: _checkBiometrics,
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.cyanAccent, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.cyan, blurRadius: 15)],
                ),
                child: const Icon(Icons.fingerprint, size: 80, color: Colors.white),
              ),
            ),
            const SizedBox(height: 50),
            const Text("RÉGLAGE DISTANCE (RSSI)"),
            Slider(
              value: _rssiLimit,
              min: -100, max: -20,
              activeColor: Colors.cyanAccent,
              onChanged: (val) => setState(() => _rssiLimit = val),
            ),
            Text("${_rssiLimit.toInt()} dBm (Plus c'est haut, plus il faut être proche)"),
          ],
        ),
      ),
    );
  }
}