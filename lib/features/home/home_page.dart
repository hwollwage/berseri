import 'package:berseri/features/camera/camera_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    CameraPage(),
    // DiagnosticPage(),
    // RoutinePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ini test, berseri app'),
        backgroundColor: Colors.amberAccent,
      ),

      body: pages[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera), 
            label: "Camera"
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.plus_one), 
            label: "Diagnostic"
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.plus_one), 
            label: "Routine"
          ),
        ],
      ),
    );
  }
}
