import 'package:flutter/material.dart';
import 'screens/dashboard.dart';

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
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Dashboard(),
    const Center(child: Text("DEVICES PAGE", style: TextStyle(color: Colors.cyanAccent))),
    const Center(child: Text("SETTINGS PAGE", style: TextStyle(color: Colors.cyanAccent))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        height: 60,
        margin: const EdgeInsets.fromLTRB(25, 0, 25, 70),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2128),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(Icons.shield, 0),
            _navItem(Icons.devices, 1),
            _navItem(Icons.settings, 2),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: Colors.transparent,
        child: Icon(
          icon,
          color: isSelected ? Colors.cyanAccent : Colors.white24,
          size: 24,
        ),
      ),
    );
  }
}