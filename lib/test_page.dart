import 'package:berseri/core/components/custom_button.dart';
import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("test button"),),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            CustomButton(
              text: 'save',
              onPressed: () {
                print("save test");
              },
            ),

            const SizedBox(height: 20,),

            CustomButton(
              text: 'delete',
              onPressed: () {
                print("delete test");
              },
              textColor: Colors.white,
              backgroundColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}