import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

import 'package:krishivue/pages/landing.dart';
class DetectionPage extends StatefulWidget {
 const DetectionPage({Key? key, required this.picture, required this.myresult}) : super(key: key);
  final XFile picture;
   final Map<String, dynamic> myresult;
  @override
  State<DetectionPage> createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  @override
  void initState(){
    super.initState();
    Future.delayed(Duration(seconds: 5),(){
       showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Home Page'),
          content: const Text('Do you want to return to home page?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Landing())),
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('No'),
            ),
          ],
        ),
      );
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detection of Diseases"),

      ),
      body:SafeArea(
        child: Column(
          children: <Widget>[
             Padding(
            padding: const EdgeInsets.all(3.0),
            child: Image.file(File(widget.picture.path),
          
            fit: BoxFit.cover, 
             height: MediaQuery.of(context).size.height * 0.7,
             width: MediaQuery.of(context).size.width * 1 ),
              
          ),

            const SizedBox(height: 15),


             Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  color: Colors.blueAccent,
                  
                  child: SingleChildScrollView(
                    child: Column(
                      
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.myresult.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 17, 142, 220)
                            ),
                            child: 
                          Text(
                            '${entry.key}: ${entry.value}',
                         style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),
                          )
                          
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            )

          ],
         
          
          ),
      )
    );
  }
}


