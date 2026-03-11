import 'package:flutter/material.dart';
import 'screens/dashboard.dart';
import 'screens/devices.dart';
import 'screens/settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AegisApp());
}

class AegisApp extends StatelessWidget {
  const AegisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1115),
      ),
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const DevicesPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: Container(
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFF161920),
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.shield,
                    size: 28,
                    color: _currentIndex == 0 ? const Color(0xFF64FFDA) : Colors.white38
                  ),
                  onPressed: () => setState(() => _currentIndex = 0),
                ),
                IconButton(
                  icon: Icon(
                    Icons.track_changes,
                    size: 28,
                    color: _currentIndex == 1 ? const Color(0xFF64FFDA) : Colors.white38
                  ),
                  onPressed: () => setState(() => _currentIndex = 1),
                ),
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    size: 28,
                    color: _currentIndex == 2 ? const Color(0xFF64FFDA) : Colors.white38
                  ),
                  onPressed: () => setState(() => _currentIndex = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}