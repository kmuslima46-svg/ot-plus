import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // App can still run offline; online jobs require Firebase configuration.
  }
  runApp(const OTPlusApp());
}

class OTPlusApp extends StatelessWidget {
  const OTPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFE81775);
    return MaterialApp(
      title: 'OT PLUS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFBFD),
        colorScheme: ColorScheme.fromSeed(seedColor: pink, primary: pink),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFBFD),
          foregroundColor: Color(0xFF30232A),
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0.7,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFF3E4EB)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFF5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFF0D8E4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFF0D8E4)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
