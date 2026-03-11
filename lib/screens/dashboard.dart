import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:local_auth/local_auth.dart';

const String AEGIS_SERVICE_UUID = "bf27730d-860a-4e09-889c-2d8b6a9e0fe7";

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLocking = false;
  double _seuil = -60.0;
  final FlutterBlePeripheral peripheral = FlutterBlePeripheral();
  final LocalAuthentication auth = LocalAuthentication();

  Future<void> _forceLockPC() async {
    if (_isLocking) return;

    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Autorisez le verrouillage manuel du PC',
      );
    } catch (e) {
      authenticated = true; 
    }

    if (!authenticated) return;
    
    setState(() => _isLocking = true);
    await peripheral.stop();

    final AdvertiseData lockData = AdvertiseData(
      serviceUuid: AEGIS_SERVICE_UUID,
      localName: "Aegis-S24",
      manufacturerId: 0xFFFF,
      manufacturerData: Uint8List.fromList("LOCK".codeUnits),
    );

    final AdvertiseSettings settings = AdvertiseSettings(
      advertiseMode: AdvertiseMode.advertiseModeLowLatency,
      txPowerLevel: AdvertiseTxPower.advertiseTxPowerHigh,
      connectable: false,
    );

    await peripheral.start(advertiseData: lockData, advertiseSettings: settings);
    
    await Future.delayed(const Duration(seconds: 3));
    await peripheral.stop();
    
    if (mounted) setState(() => _isLocking = false);
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF64FFDA);
    final String statusText = _isLocking ? "VERROUILLAGE EN COURS..." : "SCAN BLE ACTIF";

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("AEGIS-LOCK", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 3, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              statusText,
              style: const TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 1),
            ),
            const SizedBox(height: 40),
            
            GestureDetector(
              onTap: _isLocking ? null : _forceLockPC,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(
                    color: mainColor,
                    width: 2,
                  ),
                  boxShadow: _isLocking ? [
                    BoxShadow(
                      color: mainColor.withOpacity(0.6), 
                      blurRadius: 40, 
                      spreadRadius: 10
                    )
                  ] : [],
                ),
                child: const Center(
                  child: Icon(
                    Icons.security, 
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 30), 

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF000000), 
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(text: "Cible : ", style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'monospace')),
                        TextSpan(text: "60:FF:9E:4A:C7:59", style: TextStyle(color: mainColor, fontSize: 14, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25), 

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("SEUIL", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
                      Text("${_seuil.toInt()} dBm", style: TextStyle(color: mainColor, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: mainColor,
                      inactiveTrackColor: const Color(0xFF2C2F33),
                      thumbColor: mainColor,
                      trackHeight: 4.0,
                    ),
                    child: Slider(
                      value: _seuil,
                      min: -100.0,
                      max: -40.0,
                      onChanged: (value) {
                        setState(() {
                          _seuil = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 95), 
          ],
        ),
      ),
    );
  }
}