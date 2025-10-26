import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/login_screen2.dart';
import 'screens/food_list_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'My Flutter Project',
    theme: ThemeData(primarySwatch: Colors.green),
    initialRoute: "/welcome", // first page
    routes: {
      "/welcome": (context) => const WelcomeScreen(),
      "/signup": (context) => const SignupScreen(),
      "/login": (context) => const LoginScreen(), // if you create one
      "/home": (context) => const HomeScreen(),
      "/foods": (context) => const FoodListScreen(),
    },
  );
  }
}


