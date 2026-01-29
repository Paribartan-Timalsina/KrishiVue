/// Custom bottom navigation bar widget for KrishiVue app
/// Provides navigation between Home, About, and Contact pages

import 'package:flutter/material.dart';
import 'package:krishivue/pages/contact.dart';
import 'package:krishivue/pages/landing.dart';
import 'package:krishivue/pages/about.dart';

/// Custom bottom navigation bar that can be toggled on/off by tapping the screen
/// This provides a cleaner full-screen experience when needed
class CustomBottomNavigationBar extends StatefulWidget {
  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  /// Controls visibility of bottom navigation bar
  /// Starts hidden and can be toggled by tapping the screen
  bool showBottomNavBar = false;
  
  /// Currently selected page index (0: Home, 1: About, 2: Contact)
  int _selectedIndex = 0;
  
  /// Handle navigation bar item tap
  /// Updates the selected index to switch between pages
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  /// List of page widgets corresponding to each navigation item
  final List<Widget> _pages = [
    Landing(),    // Home/Landing page
    AboutUs(),    // About Us page
    ContactUs()   // Contact Us page
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          // Tap anywhere on screen to toggle bottom navigation bar visibility
          onTap: () {
            setState(() {
              showBottomNavBar = !showBottomNavBar;
            });
          },
          child: Stack(
            children: [
              // Display the currently selected page
              Container(
                child: _pages[_selectedIndex]
              ),
              
              // Conditionally show bottom navigation bar when toggled
              if (showBottomNavBar)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: BottomNavigationBar(
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                        backgroundColor: Color.fromARGB(255, 247, 93, 82),
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.info_outline),
                        label: 'Predict Crop',
                        backgroundColor: Colors.green,
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.contact_page),
                        label: 'About Us',
                        backgroundColor: Color.fromARGB(255, 9, 155, 222),
                      ),
                    ],
                    currentIndex: _selectedIndex,
                    selectedItemColor: Color.fromARGB(255, 240, 139, 6),
                    onTap: _onItemTapped,
                  ),
                )
            ]
          ),
        )
      )
    );
  }
}
