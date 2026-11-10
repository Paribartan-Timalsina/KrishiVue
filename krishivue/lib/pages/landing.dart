import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:krishivue/ui/home_view.dart';
import 'dart:io';
import 'package:krishivue/widgets/app_bar.dart';
import "package:krishivue/pages/previewgallery.dart";
class Landing extends StatefulWidget {
  @override
  State<Landing> createState() => LandingState();
}

class LandingState extends State<Landing> {
  XFile? uploadimage;
  Future<void> chooseImage() async {
    var choosedimage = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      uploadimage = choosedimage!;
    });
  }
  void uploadImage() {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => PreviewGalleryPage(picture: uploadimage!)
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Home"),
      body: SafeArea(
        child: GestureDetector(
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 1,
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/back.jpg'),
                    fit: BoxFit.fill,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.15),
                      BlendMode.dstATop,
                    ),
                  ),
                ),
                
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height * 0.82 * 0.8,
                        width: MediaQuery.of(context).size.width * 1,
                        child: Center(
                          child: uploadimage == null
                              ? Text(
                                  "Select Image using one of the icons",
                                  style: TextStyle(fontSize: 20),
                                )
                              : Image.file(File(uploadimage!.path)),
                        ),
                      ),
                      
                      SizedBox(height: 10),
                      Container(
                        child: uploadimage == null
                            ? Container()
                            : Container(
                                height: 40,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    uploadImage();
                                  },
                                  icon: Icon(Icons.file_upload, size: 40),
                                  label: Text("UPLOAD IMAGE"),
                                ),
                              ),
                      ),
                      
                      SizedBox(height: 10),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            color: Colors.blueGrey,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.push(
                                        context, 
                                        MaterialPageRoute(
                                          builder: (context) => HomeView()
                                        )
                                      );
                                    },
                                    child: Icon(
                                      Icons.camera,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await chooseImage();
                                    },
                                    child: Icon(
                                      Icons.file_upload,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
