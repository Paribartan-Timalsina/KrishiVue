import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  
  final String result;

  ResultScreen(this.result);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Result Screen'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            result,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
