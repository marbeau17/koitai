import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/constants/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp();

  // Hive local storage
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox<dynamic>(AppConfig.hiveBoxFortune),
    Hive.openBox<dynamic>(AppConfig.hiveBoxProfile),
    Hive.openBox<dynamic>(AppConfig.hiveBoxPair),
    Hive.openBox<dynamic>(AppConfig.hiveBoxSettings),
  ]);

  // Japanese locale data for intl / table_calendar
  await initializeDateFormatting('ja');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
