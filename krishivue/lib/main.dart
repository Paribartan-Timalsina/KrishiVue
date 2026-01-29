import 'package:flutter/material.dart';
import 'package:krishivue/pages/intro.dart';
import 'package:krishivue/pages/landing.dart';
import "package:krishivue/widgets/bottomnavbar.dart";
import 'package:flutter/services.dart';

/// Main entry point for the KrishiVue application
/// Initializes the app with portrait-only orientation and sets up routing
void main() async {
  // Ensure Flutter framework is initialized before making async calls
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock screen orientation to portrait mode only
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  // Start the app with MaterialApp and define navigation routes
  runApp(MaterialApp(
    initialRoute: '/', // Start with splash screen
    routes: {
      "/": (context) => SplashScreen(), // Splash/intro screen
      '/landing': (context) => CustomBottomNavigationBar(), // Main app screen with bottom navigation
    },
  ));
}
