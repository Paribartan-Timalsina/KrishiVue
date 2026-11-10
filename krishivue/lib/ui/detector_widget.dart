import 'dart:async';
import 'package:krishivue/pages/previewpage.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../models/recognition.dart';
import '../models/screen_params.dart';
import '../service/detector_service.dart';
import '../ui/box_widget.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';

class DetectorWidget extends StatefulWidget {
  const DetectorWidget({super.key});

  @override
  State<DetectorWidget> createState() => _DetectorWidgetState();
}

class _DetectorWidgetState extends State<DetectorWidget>
    with WidgetsBindingObserver {
  List<CameraDescription>? cameras;
  
  bool _isRearCameraSelected = true;
  
  CameraController? _cameraController;

  get _controller => _cameraController;

  Detector? _detector;
  
  StreamSubscription? _subscription;

  List<Recognition>? results;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initStateAsync();
  }

  void _initStateAsync() async {
    cameras = await availableCameras();
    
    _initializeCamera(cameras![0]);
    
    Detector.start().then((instance) {
      setState(() {
        _detector = instance;
        _subscription = instance.resultsStream.stream.listen((values) {
          setState(() {
            results = values['recognitions'];
          });
        });
      });
    });
  }

  void _initializeCamera(CameraDescription cameraDescription) async {
    // Low resolution keeps per-frame detection fast.
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.low,
      enableAudio: false,
    )..initialize().then((_) async {
        await _controller.startImageStream(onLatestImageAvailable);
        setState(() {});

        // Used to scale boxes onto the preview.
        ScreenParams.previewSize = _controller.value.previewSize!;
      });
  }

  Future takePicture() async {
    try {
      XFile picture = await _cameraController!.takePicture();
      
      // Send the first detection's box, in the detector's 300x300 input space,
      // so the backend can crop the photo to it.
      final rectData = {
        'left': results![0].location.left,
        'top': results![0].location.top,
        'width': results![0].location.width,
        'height': results![0].location.height,
        'scheight': 300,
        'scwidth': 300,
      };
      
      final myString = await json.encode(rectData);
      print(myString);
      
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PreviewPage(
                    picture: picture,
                    myString: myString,
                  )));
                  
    } catch (e) {
      final snackBar = SnackBar(
        content: Text("$e", style: TextStyle(fontSize: 20)),
        backgroundColor: Color.fromARGB(255, 223, 101, 44),
        dismissDirection: DismissDirection.up,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 150,
            left: 10,
            right: 10),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      debugPrint('Error occurred while taking picture: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    var aspect = 1 / _controller.value.aspectRatio;

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: aspect,
          child: CameraPreview(_controller),
        ),
        
        AspectRatio(
          aspectRatio: aspect,
          child: _boundingBoxes(),
        ),
        
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.10,
            width: MediaQuery.of(context).size.width * 1,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              color: Colors.black,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 40,
                    icon: Icon(
                      _isRearCameraSelected
                          ? CupertinoIcons.switch_camera
                          : CupertinoIcons.switch_camera_solid,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isRearCameraSelected = !_isRearCameraSelected;
                      });
                      _initializeCamera(cameras![_isRearCameraSelected ? 0 : 1]);
                    },
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: takePicture,
                    iconSize: 50,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(Icons.circle, color: Colors.white),
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _boundingBoxes() {
    if (results == null) {
      return const SizedBox.shrink();
    }
    return Stack(
        children: results!.map((box) => BoxWidget(result: box)).toList());
  }

  void onLatestImageAvailable(CameraImage cameraImage) async {
    _detector?.processFrame(cameraImage);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        _cameraController?.stopImageStream();
        _detector?.stop();
        _subscription?.cancel();
        break;
      case AppLifecycleState.resumed:
        _initStateAsync();
        break;
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _detector?.stop();
    _subscription?.cancel();
    super.dispose();
  }
}
