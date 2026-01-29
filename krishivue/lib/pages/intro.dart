/// Splash screen (intro screen) for KrishiVue app
/// 
/// Displays app logo with fade-in animation for 3 seconds
/// then automatically navigates to the main application

import 'package:flutter/material.dart';
import 'package:krishivue/pages/landing.dart';
import "package:krishivue/widgets/bottomnavbar.dart";

/// Splash screen widget that shows on app launch
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Opacity value for fade-in animation (0.0 = invisible, 1.0 = fully visible)
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Navigate to main screen after 3 seconds delay
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CustomBottomNavigationBar(),
        ),
      );
    });

    // Start fade-in animation after 1 second delay
    // This creates a nice entrance effect for the logo
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _opacity = 1.0; // Fade logo to fully visible
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          // Full screen dimensions
          width: MediaQuery.of(context).size.width * 1,
          height: MediaQuery.of(context).size.height * 1,
          
          // Background image with semi-transparent overlay
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/back.jpg'),
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.2), // 20% transparency
                BlendMode.dstATop,
              ),
            )
          ),
          
          // Animated logo with fade-in effect
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: Duration(seconds: 1), // 1 second fade-in animation
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Circular logo container
                ClipOval(
                  child: Container(
                    width: 400,
                    height: 400,
                    color: Colors.transparent,
                    child: Center(
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
