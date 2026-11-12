import 'package:berseri/app/app.dart';
import 'package:berseri/features/notifications/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    publishableKey: dotenv.get('SUPABASE_PUBLISHABLE_KEY'),
  );

  await NotificationService.instance.init();
  await NotificationService.instance.requestPermission();
  await NotificationService.instance.ensureReminderScheduled();


  runApp(
    const ProviderScope(
      child: BerseriApp(),
    ),
  );
}