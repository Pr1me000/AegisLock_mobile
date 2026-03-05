import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Liste fictive d'appareils déjà liés (à lier à une DB plus tard)
    final List<Map<String, String>> pairedDevices = [
      {"name": "PC-GAMER-ARCH", "mac": "60:FF:9E:4A:C7:59"},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("APPAREILS APPAIRÉS"), backgroundColor: Colors.transparent),
      body: ListView.builder(
        itemCount: pairedDevices.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.laptop, color: Colors.cyanAccent),
            title: Text(pairedDevices[index]['name']!),
            subtitle: Text(pairedDevices[index]['mac']!, style: const TextStyle(color: Colors.white24)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
              onPressed: () {
                // Logique pour supprimer la clé privée
              },
            ),
          );
        },
      ),
    );
  }
}