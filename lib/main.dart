import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/surah_screen.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();

  // ==========================================================
  // LOCAL QURAN DATABASE
  // ==========================================================
  await dbHelper.initQuranData();

  // ==========================================================
  // SERVER SYNC
  // ==========================================================
  try {
    final syncResult = await dbHelper.syncWithServer(
      'https://oegfashion.com/sync_quran.php',
    );
    debugPrint('🔄 Quran Sync Result: $syncResult');
  } catch (e, stackTrace) {
    debugPrint('❌ Quran Sync Error: $e');
    debugPrint('$stackTrace');
  }

  // ==========================================================
  // USER PREFERENCES
  // ==========================================================
  final prefs = await SharedPreferences.getInstance();
  final String savedUsername = prefs.getString('username') ?? 'ব্যবহারকারী';
  final String savedTheme = prefs.getString('theme_mode') ?? 'dark';

  // ==========================================================
  // RUN APP
  // ==========================================================
  runApp(
    MyApp(
      username: savedUsername,
      themeMode: savedTheme,
    ),
  );
}

class MyApp extends StatefulWidget {
  final String username;
  final String themeMode;
  const MyApp({super.key, required this.username, required this.themeMode});

  static _MyAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String _currentUsername;
  late ThemeMode _currentThemeMode;

  @override
  void initState() {
    super.initState();
    _currentUsername = widget.username;
    _currentThemeMode = widget.themeMode == 'light' 
        ? ThemeMode.light 
        : widget.themeMode == 'dark' 
            ? ThemeMode.dark 
            : ThemeMode.system;
  }

  Future<void> updateUsername(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', newName);
    if (!mounted) return;
    setState(() {
      _currentUsername = newName;
    });
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String modeStr = 'system';
    if (mode == ThemeMode.dark) {
      modeStr = 'dark';
    } else if (mode == ThemeMode.light) {
      modeStr = 'light';
    }
    await prefs.setString('theme_mode', modeStr);
    if (!mounted) return;
    setState(() {
      _currentThemeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'তাফাক্কুর',
      debugShowCheckedModeBanner: false,
      themeMode: _currentThemeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1C2C),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: SurahScreen(username: _currentUsername),
    );
  }
}