import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Pairing extends StatefulWidget {
  final String deviceId;
  const Pairing({super.key, required this.deviceId});

  @override
  State<Pairing> createState() => _PairingState();
}

class _PairingState extends State<Pairing> {
  bool _useCamera = true;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // PopScope intercepte le bouton retour physique d'Android
    return PopScope(
      canPop: !_useCamera, // On n'autorise la sortie que si on est déjà en mode manuel
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return; // Si on a déjà quitté, on ne fait rien
        
        if (_useCamera) {
          setState(() {
            _useCamera = false; // Bascule sur le champ de code au lieu de quitter
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        appBar: AppBar(
          title: const Text("VÉRIFICATION PHYSIQUE"),
          backgroundColor: Colors.transparent,
          // La flèche dans l'AppBar doit aussi suivre cette logique
          leading: IconButton(
            icon: Icon(_useCamera ? Icons.arrow_back : Icons.close),
            onPressed: () {
              if (_useCamera) {
                setState(() => _useCamera = false);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: _useCamera
            ? MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    _finalize(barcodes.first.rawValue ?? "");
                  }
                },
              )
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("ENTREZ LE CODE AFFICHÉ SUR LE PC", 
                      style: TextStyle(color: Colors.white70, letterSpacing: 1)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () => _finalize(_controller.text), 
                      child: const Text("VALIDER LA LIAISON", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
                    )
                  ],
                ),
              ),
      ),
    );
  }

  void _finalize(String secret) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("🔐 Liaison tentée avec le secret : $secret"))
    );
    Navigator.pop(context);
  }
}