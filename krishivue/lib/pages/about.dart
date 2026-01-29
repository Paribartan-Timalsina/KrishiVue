import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:isolate';
import 'package:path/path.dart' as Path;
import 'package:krishivue/pages/prediction.dart';
import 'package:flutter/material.dart';
import 'package:krishivue/widgets/app_bar.dart';
import "package:http/http.dart" as http;

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
    final _formKey = GlobalKey<FormState>();
  TextEditingController nController = TextEditingController();
  TextEditingController pController = TextEditingController();
  TextEditingController kController = TextEditingController();
  TextEditingController rainController = TextEditingController();
  TextEditingController tempController = TextEditingController();
  TextEditingController humidityController = TextEditingController();
  TextEditingController phController = TextEditingController();
  void _showResultModal(String result) {
  showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(color:Colors.lightGreen,),
                        child: Text("The crop that is best suitable for field is:${result}")
                        ),
                      const SizedBox(height: 10,),
                      ElevatedButton(
                        child: const Text('OK'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              );
            }
  );
  }

  void _submitdata() async {
     var data={
      'n':double.parse(nController.text),
      'p':double.parse(pController.text),
      'k':double.parse(kController.text),
      'temperature':double.parse(tempController.text),
      'humidity':double.parse(humidityController.text),
      'ph':double.parse(phController.text),
      'rainfall':double.parse(rainController.text),
      
     };
    // print(data);
      final myString = await json.encode(data);
       print(myString);
     final Uri uri = Uri.parse('http://192.168.1.66:8000/predictCrop'); // Replace with your API endpoint URL

  try {
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print(jsonResponse);
      
_showResultModal(jsonResponse['prediction']);


    } else {
      print('Post request failed with status: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (error) {
    print('Error making post request: $error');
  }



  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Get a Suitable Crop for Production'),
      body: SafeArea(
        child: Form(
          key: _formKey,
            child: ListView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                color: Colors.white
                ),
                
                child: Text("Fill up the form to get best crop",
                style: TextStyle(
                  fontSize: 20,
                 overflow: TextOverflow.clip
                 
                ),
                textAlign:TextAlign.center,
                ),
              ),
            ),
            TextFormField(
              validator: (value){
                if(value == null||value.isEmpty){
                  return 'Please enter the valid form';
                }
                return null;
              },
              controller: rainController,
              decoration: InputDecoration(
                labelText: 'Rainfall',
                hintText: "2",
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Colors.black, width: 3)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                prefixIcon: Icon(Icons.agriculture),
                suffixIcon: Icon(Icons.delete_outline)
              ),
            ),
         SizedBox(height: 14,),
           TextFormField(
              validator: (value){
                if(value == null||value.isEmpty){
                  return 'Please enter the valid form';
                }
                return null;
              },
              controller: nController,
              decoration: InputDecoration(
                labelText: 'Nitrogen',
                hintText: "2",
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Colors.black, width: 3)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                prefixIcon: Icon(Icons.agriculture),
                suffixIcon: Icon(Icons.delete_outline)
              ),
            ),

SizedBox(height: 14,),

              TextFormField(
              validator: (value){
                if(value == null||value.isEmpty){
                  return 'Please enter the valid form';
                }
                return null;
              },
              controller: pController,
              decoration: InputDecoration(
                labelText: 'Phosphorus',
                hintText: "2",
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Colors.black, width: 3)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                prefixIcon: Icon(Icons.agriculture),
                suffixIcon: Icon(Icons.delete_outline)
              ),
            ),

SizedBox(height: 14,),




                TextFormField(
              validator: (value){
                if(value == null||value.isEmpty){
                  return 'Please enter the valid form';
                }
                return null;
              },
              controller: kController,
              decoration: InputDecoration(
                labelText: 'Potassium',
                hintText: "2",
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Colors.black, width: 3)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                prefixIcon: Icon(Icons.agriculture),
                suffixIcon: Icon(Icons.delete_outline)
              ),
            ),



SizedBox(height: 14,),


                TextFormField(
              validator: (value){
                if(value == null||value.isEmpty){
                  return 'Please enter the valid form';
                }
                return null;
              },
              controller: tempController,
              decoration: InputDecoration(
                labelText: 'Temperature',
                hintText: "2 °C",
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Colors.black, width: 3)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                prefixIcon: Icon(Icons.agriculture),
                suffixIcon: Icon(Icons.delete_outline)
              ),
            ),




SizedBox(height: 14,),

                TextFormField(
              validator: (value){
                if(value == null||value.isEmpty){
                  return 'Please enter the valid form';
                }
                return null;
              },
              controller: humidityController,
              decoration: InputDecoration(
                labelText: 'Humidity',
                hintText: "2",
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Colors.black, width: 3)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                prefixIcon: Icon(Icons.agriculture),
                suffixIcon: Icon(Icons.delete_outline)
              ),
            ),
SizedBox(height: 14,),





                TextFormField(
              validator: (value){
                if(value == null||value.isEmpty){
                  return 'Please enter the valid form';
                }
                return null;
              },
              controller: phController,
              decoration: InputDecoration(
                labelText: 'ph',
                hintText: "2",
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Colors.black, width: 3)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                prefixIcon: Icon(Icons.agriculture),
                suffixIcon: Icon(Icons.delete_outline)
              ),
            ),







            



            
            ElevatedButton.icon(onPressed: (){
              print('${nController.text}');
               // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Data')),
        
      );
      _submitdata();
    }
            }, icon: Icon(Icons.post_add), label: Text("Submit"))
          ],
        )),
      ),
    );
  }
}
