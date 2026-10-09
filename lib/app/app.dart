import 'package:berseri/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:berseri/app/routes.dart';

class BerseriApp extends ConsumerWidget {
  const BerseriApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final themeMode = ref.watch(themeModeNotifier);

    return MaterialApp.router(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      title: 'Berseri App',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: themeMode,
    );
  }
}
