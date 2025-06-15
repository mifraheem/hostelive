import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hostelive_app/screen/home_screen.dart';
import 'package:hostelive_app/screen/login_screen.dart';
import 'package:hostelive_app/screen/signup_page.dart';
import 'package:hostelive_app/screen/student_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _initialRoute = '/login';

  @override
  void initState() {
    super.initState();
    _determineInitialRoute();
  }

  Future<void> _determineInitialRoute() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'access_token');
    if (mounted) {
      setState(() {
        _initialRoute = token != null ? '/home' : '/login';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hostelive',
      theme: ThemeData(primarySwatch: Colors.purple),
      initialRoute: _initialRoute,
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
        '/student-dashboard': (context) => StudentDashboard(),
      },
    );
  }
}
