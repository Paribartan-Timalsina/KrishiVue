import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
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
  var url = await  Uri.parse('http://192.168.0.128:8000/predictCropDisease');
  var request = await  http.MultipartRequest('POST', url);
  var file = File(widget.picture.path);
  print("The picture is : ${file}");
  var stream = http.ByteStream(file.openRead());
  var length = await file.length();
  var multipartFile = http.MultipartFile('file', stream, length, filename: file.path);
  print("The multipart file is : ${multipartFile}");
  request.files.add(multipartFile);
  request.fields['myString']=widget.myString;
  var response = await request.send();
  if (response.statusCode == 200) {
     try {
  var jsonResponse = await response.stream.bytesToString();
  var decodedResponse = await json.decode(jsonResponse);
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
  } else {
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
                          uploading?CircularProgressIndicator(): ElevatedButton.icon(
                          onPressed: ()  async {
                            
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

