import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import "package:image/image.dart" as image_lib;
import 'package:krishivue/pages/detection.dart';
import 'package:http/http.dart' as http;

class PreviewPage extends StatefulWidget {
  const PreviewPage({Key? key, required this.picture, required this.myString}) : super(key: key);

  final XFile picture;
  final String myString;
 
  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  bool uploading= false;
 void uploadImage() async {
  setState(() {
    uploading=true;
  });
   print(widget.myString);
  // Create a POST request to your Flask API endpoint
  var url = await  Uri.parse('http://192.168.0.128:8000/predictCropDisease'); // Replace with your API endpoint URL

  // Create a multipart request
  var request = await  http.MultipartRequest('POST', url);

  // Add the image file to the request
  var file = File(widget.picture.path);
  print("The picture is : ${file}");
  var stream = http.ByteStream(file.openRead());
  var length = await file.length();
  var multipartFile = http.MultipartFile('file', stream, length, filename: file.path);
  print("The multipart file is : ${multipartFile}");
  request.files.add(multipartFile);
  request.fields['myString']=widget.myString;

  // Send the request
  var response = await request.send();

  // Check the response status code
  if (response.statusCode == 200) {
     try {
  var jsonResponse = await response.stream.bytesToString();
  var decodedResponse = await json.decode(jsonResponse);
  
  // Print the decoded JSON response
  print('Response: $decodedResponse');

  Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetectionPage(
                   picture: widget.picture , myresult:decodedResponse,
                  )));
setState(() {
  uploading=false;
});
} catch (e) {
  print('Error decoding JSON response: $e');
}
    // Request was successful
    // You can handle the response here if the server sends any data back
  } else {
    myResult();
    // Request failed
    print('Error: ${response.reasonPhrase}');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Page')),
      body: SafeArea(
        child: 
        Column(
          mainAxisSize: MainAxisSize.min, 
          children: <Widget>[
            
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(File(widget.picture.path),
          
            fit: BoxFit.cover, 
             height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width * 1 ),
              
          ),

          const SizedBox(height: 24),

           Container(
                          //elese show uplaod button
                          child:
                          uploading?CircularProgressIndicator(): ElevatedButton.icon(
                          onPressed: ()  async {
                            
                             uploadImage();
                            //start uploading image
                          },
                          icon: Icon(Icons.file_upload,
                          size: 50,),
                          label: Text("UPLOAD IMAGE"),
        
                          //set brghtness to dark, because deepOrangeAccent is darker coler
                          //so that its text color is light
                        )),

        ]),
      ),
    );
  }
}

Widget myResult(){
  print('i AM HERE');
  return Container(
    
    //body: SafeArea(
      child: Column(children:<Widget> [
        
   CircularProgressIndicator()
      ]),
   // )

  
  );
}