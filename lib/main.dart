import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fasyl/core/config/app_theme.dart';
import 'package:fasyl/core/config/constants.dart';
import 'package:fasyl/core/views//splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppString.appName,
      theme: AppTheme.lightTheme,
      home: SplashScreen(),
    );
  }
}
