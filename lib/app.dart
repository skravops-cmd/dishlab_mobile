import 'package:flutter/material.dart';
import 'features/auth/ui/login_page.dart';

class DishLabApp extends StatelessWidget {
  const DishLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DishLab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const LoginPage(),
    );
  }
}
