import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ini test, berseri app'),
        backgroundColor: Colors.amberAccent,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text('INI CUMA PLACEHOLDER'),

            const SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }
}