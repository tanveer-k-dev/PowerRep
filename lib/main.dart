import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: PowerRepApp()));
}

class PowerRepApp extends ConsumerWidget {
  const PowerRepApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'PowerRep',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.redAccent,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
        colorScheme: const ColorScheme.light(
          primary: Colors.redAccent,
          secondary: Colors.redAccent,
          surface: Colors.white,
          onSurface: Color(0xFF2D3436),
        ),
        textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme).copyWith(
          titleLarge: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: const Color(0xFF161616),
        ),
        primaryColor: Colors.redAccent,
        colorScheme: const ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.redAccent,
          surface: Color(0xFF161616),
          onSurface: Colors.white,
        ),
        textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).copyWith(
          titleLarge: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
