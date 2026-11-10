import 'package:flutter/material.dart';
import 'package:krishivue/pages/contact.dart';
import 'package:krishivue/pages/landing.dart';
import 'package:krishivue/pages/about.dart';
class CustomBottomNavigationBar extends StatefulWidget {
  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  bool showBottomNavBar = false;
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  final List<Widget> _pages = [
    Landing(),
    AboutUs(),
    ContactUs()
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            setState(() {
              showBottomNavBar = !showBottomNavBar;
            });
          },
          child: Stack(
            children: [
              Container(
                child: _pages[_selectedIndex]
              ),
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
