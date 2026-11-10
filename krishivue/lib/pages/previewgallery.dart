import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:krishivue/pages/detection.dart';
import 'package:http/http.dart' as http;

class PreviewGalleryPage extends StatefulWidget {
  const PreviewGalleryPage({Key? key, required this.picture}) : super(key: key);

  final XFile picture;

  @override
  State<PreviewGalleryPage> createState() => _PreviewGalleryPageState();
}

class _PreviewGalleryPageState extends State<PreviewGalleryPage> {
  bool uploading=false;
 void uploadImage() async {
  setState(() {
    uploading=true;
  });
  var url = Uri.parse('http://192.168.0.128:8000/predictdiseases');
  var request = http.MultipartRequest('POST', url);
  var file = File(widget.picture.path);
  print("The picture is : ${file}");
  var stream = http.ByteStream(file.openRead());
  var length = await file.length();
  var multipartFile = http.MultipartFile('file', stream, length, filename: file.path);
  print("The multipart file is : ${multipartFile}");
  request.files.add(multipartFile);
  var response = await request.send();
  if (response.statusCode == 200) {
    try {
      var jsonResponse = await response.stream.bytesToString();
  var decodedResponse = json.decode(jsonResponse);
      Navigator.push(context,MaterialPageRoute(builder:(context)=>DetectionPage(picture: widget.picture, myresult: decodedResponse) ));
  
setState(() {
  uploading=false;
});
  print('Response: $decodedResponse');
} catch (e) {
  print('Error decoding JSON response: $e');
}

  } else {
    print("The error has occured");
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
                          child:
                          uploading?
                          Container( child: 
                          CircularProgressIndicator(),
                          
                          )
                          : ElevatedButton.icon(
                          onPressed: () {
                            uploadImage();
                          },
                          icon: Icon(Icons.file_upload,
                          size: 50,),
                          label: Text("UPLOAD IMAGE"),
                        )),

        ]),
      ),
    );
  }
}