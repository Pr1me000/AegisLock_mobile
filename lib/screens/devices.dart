import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pairing.dart';

const String AEGIS_SERVICE_UUID = "bf27730d-860a-4e09-889c-2d8b6a9e0fe7";

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final FlutterBlePeripheral peripheral = FlutterBlePeripheral();
  final TextEditingController _secretController = TextEditingController();
  bool _isBroadcasting = false;

  @override
  void initState() {
    super.initState();
    _loadSecret();
  }

  Future<void> _loadSecret() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _secretController.text = prefs.getString('pairing_secret') ?? "";
      });
    }
  }

  Future<void> _saveSecret(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pairing_secret', value);
    if (_isBroadcasting) {
      await peripheral.stop();
      await _startBroadcasting();
    }
  }

  Future<void> _startBroadcasting() async {
    final prefs = await SharedPreferences.getInstance();
    final String name = prefs.getString('display_name') ?? "Aegis-S24";
    final String secret = _secretController.text.isNotEmpty ? _secretController.text : "0";

    final AdvertiseData advertiseData = AdvertiseData(
      serviceUuid: AEGIS_SERVICE_UUID,
      localName: name,
      manufacturerId: 0xFFFF,
      manufacturerData: Uint8List.fromList(secret.codeUnits),
    );

    final AdvertiseSettings settings = AdvertiseSettings(
      advertiseMode: AdvertiseMode.advertiseModeLowLatency,
      txPowerLevel: AdvertiseTxPower.advertiseTxPowerHigh,
      connectable: false,
    );

    await peripheral.start(advertiseData: advertiseData, advertiseSettings: settings);
    if (mounted) setState(() => _isBroadcasting = true);
  }

  void _toggleSonar() async {
    if (_isBroadcasting) {
      await peripheral.stop();
      if (mounted) setState(() => _isBroadcasting = false);
    } else {
      await _saveSecret(_secretController.text);
      await _startBroadcasting();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF64FFDA);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.track_changes, 
                size: 100, 
                color: _isBroadcasting ? mainColor : Colors.white10
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isBroadcasting ? Colors.white24 : mainColor,
                  foregroundColor: _isBroadcasting ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                onPressed: _toggleSonar, 
                child: Text(
                  _isBroadcasting ? "STOP SONAR" : "START SONAR",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              ),
              const SizedBox(height: 50),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: TextField(
                  controller: _secretController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                  onChanged: _saveSecret,
                  cursorColor: mainColor,
                  decoration: InputDecoration(
                    labelText: "Pairing Code",
                    labelStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF000000),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: mainColor, width: 1.5),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner, color: mainColor),
                      onPressed: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => const Pairing()));
                        await _loadSecret();
                        if (_isBroadcasting) {
                          await peripheral.stop();
                          await _startBroadcasting();
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}