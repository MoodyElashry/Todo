import 'package:flutter/material.dart';
import 'package:finalflutter/services/user/authgate.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  bool? isDark = prefs.getBool('isDarkMode');
  if (isDark == null) {
    // Not set yet, default to true and save it
    isDark = true;
    await prefs.setBool('isDarkMode', isDark);
  } // default dark mode

  runApp(MyApp(isDarkMode: isDark));
}

class MyApp extends StatelessWidget {
  final bool isDarkMode;
  const MyApp({required this.isDarkMode, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Your App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: AuthGate(), // your starting page
    );
  }
}


