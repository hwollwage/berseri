import 'package:berseri/features/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BerseriApp extends ConsumerWidget {
  const BerseriApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Berseri App',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}