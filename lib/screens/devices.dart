import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'pairing.dart';

const String AEGIS_SERVICE_UUID = "bf27730d-860a-4e09-889c-2d8b6a9e0fe7";

class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  State<Devices> createState() => _DevicesState();
}

class _DevicesState extends State<Devices> {
  final FlutterBlePeripheral peripheral = FlutterBlePeripheral();
  bool _isBroadcasting = false;

  void _toggleSonar() async {
    if (_isBroadcasting) {
      await peripheral.stop();
      setState(() => _isBroadcasting = false);
    } else {
      final AdvertiseData advertiseData = AdvertiseData(
        serviceUuid: AEGIS_SERVICE_UUID,
        localName: "AegisPhone-PRIME", 
      );

      await peripheral.start(advertiseData: advertiseData);
      setState(() => _isBroadcasting = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.radar, size: 100, color: _isBroadcasting ? Colors.cyanAccent : Colors.white10),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _toggleSonar,
              child: Text(_isBroadcasting ? "STOP SONAR" : "START SONAR"),
            ),
            const SizedBox(height: 20),
            if (_isBroadcasting)
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => Pairing(deviceId: "Aegis-Desktop")),
                  );
                },
                child: const Text("SCAN QR CODE"),
              ),
          ],
        ),
      ),
    );
  }
}