import 'package:flutter/material.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<ContactUs> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation1, _animation2, _animation3;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3),
      ),
    );

    _animation2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.6),
      ),
    );

    _animation3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0),
      ),
    );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 228, 196),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => FadeTransition(
            opacity: _animation1,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.3, 0.6),
              )),
              child: child,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    // Logo
                    Image.asset(
                      'assets/logo.png',
                      height: 50,
                    ),
                    // Spacer for some distance between logo and text
                    SizedBox(width: 10),
                    // Text "KrishiVUe"
                    Text(
                      'KrishiVue',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              // Light line below the logo
              Divider(
                color: Colors.grey, // Adjust color as needed
                thickness: 0.5,
                height: 10,
              ),
              SizedBox(height: 16),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) => ScaleTransition(
                  scale: _animation2,
                  child: child,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blue,
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) => FadeTransition(
                          opacity: _animation3,
                          child: child,
                        ),
                        child: Text(
                          "Welcome to KrishiVue",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) => FadeTransition(
                          opacity: _animation3,
                          child: child,
                        ),
                        child: Text(
                          "Your Agricultural Companion",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.6, 0.9),
                  )),
                  child: child,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.green,
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) => FadeTransition(
                          opacity: _animation3,
                          child: child,
                        ),
                        child: Text(
                          "KrishiVue is a comprehensive agricultural platform designed to empower farmers and revolutionize the way they manage their crops.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 238, 228, 136), // Change background color here
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Key Features',
                      style: TextStyle(
                        fontSize: 24, // Increased font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12), // Added space
                    Text(
                      '1. Real-time Crop Monitoring',
                      style: TextStyle(fontSize: 18), // Increased font size
                    ),
                    SizedBox(height: 8), // Added space
                    Text(
                      '2. Intelligent Pest Detection',
                      style: TextStyle(fontSize: 18), // Increased font size
                    ),
                   
                    SizedBox(height: 8), // Added space
                    Text(
                      '4. Crop Disease Identification',
                      style: TextStyle(fontSize: 18), // Increased font size
                    ),
                    SizedBox(height: 8), // Added space
                    Text(
                      '5. Yield Prediction ',
                      style: TextStyle(fontSize: 18), // Increased font size
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
