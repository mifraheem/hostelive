import 'package:flutter/material.dart';
import 'package:hostelive_app/screen/login_screen.dart';
import 'package:hostelive_app/screen/signup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hostelive',
      theme: ThemeData(primarySwatch: Colors.purple),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
      },
    );
  }
}
