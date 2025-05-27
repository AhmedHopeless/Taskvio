import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project/pages/login.dart';
import 'package:project/pages/register.dart';
import 'package:project/pages/dashboard.dart';
import 'package:project/pages/teams.dart';
import 'package:project/pages/calendar.dart';
import 'package:project/pages/focus.dart';
import 'package:project/pages/team_dashboard.dart';
import 'package:project/pages/splash_screen.dart';
void main() async {
  await Supabase.initialize(
    url: 'https://msfnqnwhkmejglouqhqp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1zZm5xbndoa21lamdsb3VxaHFwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUxNzYxODQsImV4cCI6MjA2MDc1MjE4NH0.QnJ63Z37LOpaIU9e3mP49nr1zxOsJVbu8u6_mSRX_c8',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taskvio',
      theme: ThemeData(
        primaryColor: Color(0xFF133E87), // Primary color set to #133E87
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/teams': (context) => TeamsScreen(),
        '/calendar': (context) => CalendarScreen(),
        '/focus': (context) => FocusModeScreen()
      },
    );
  }
}
