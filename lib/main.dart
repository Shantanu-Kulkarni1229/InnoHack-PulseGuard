import 'package:flutter/material.dart';
import 'package:pulseguard/Pages/Authentication/Signup_Screen.dart';
import 'package:pulseguard/Pages/Constants/Bottom_Navbar.dart';
import 'package:pulseguard/Pages/PrimaryScreens/ContactScreen/Contact_Screen.dart';
import 'package:pulseguard/Pages/PrimaryScreens/HealthScreen/Health_Screen.dart';
import 'package:pulseguard/Pages/PrimaryScreens/MapScreen/Map_Screen.dart';
import 'package:pulseguard/Pages/PrimaryScreens/SettingsScreen/Setting_screen.dart';
import 'package:pulseguard/Pages/Constants/Bottom_Navbar.dart'; // Import the navbar file
import './Pages/splashScreen/splash_screen.dart';
import './Pages/onboarding/OnboardingScreen.dart';
import './Pages/Authentication/Login_Screen.dart';
import './Pages/Authentication/Signup_Screen.dart';
import './Pages/Authentication/Forgot_Password.dart';
import './Pages/PrimaryScreens/HomeScreens/Home_Screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   try {
    // Initialize Firebase
    await Firebase.initializeApp();
    debugPrint("Firebase initialized successfully");
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }
  runApp(const PulseGuardApp());
}

class PulseGuardApp extends StatelessWidget {
  const PulseGuardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PulseGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/main':
            (context) =>
                const MainWrapper(), // Main wrapper for primary screens
      },
    );
  }
}

class MainWrapper extends StatefulWidget {
  const MainWrapper({Key? key}) : super(key: key);

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const MapScreen(),
    const HealthScreen(),
    const EmergencyContactsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: PulseGuardNavBar(
        currentIndex: _currentIndex,
        onTabChange: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
