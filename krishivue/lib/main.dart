import 'package:flutter/material.dart';
import 'package:krishivue/pages/intro.dart';
import "package:krishivue/widgets/bottomnavbar.dart";
import 'package:flutter/services.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      "/": (context) => SplashScreen(),
      '/landing': (context) => CustomBottomNavigationBar(),
    },
  ));
}
