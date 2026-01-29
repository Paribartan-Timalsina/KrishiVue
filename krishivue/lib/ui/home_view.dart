import 'package:flutter/material.dart';
import '../models/screen_params.dart';
import '../ui/detector_widget.dart';

/// [HomeView] stacks [DetectorWidget]
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {

   print(MediaQuery.sizeOf(context));
    ScreenParams.screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      key: GlobalKey(),
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Real Time Detection')
      ),
      body: const DetectorWidget(),
    );
  }
}
