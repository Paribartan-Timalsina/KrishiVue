/// Real-time object detection widget using device camera
/// 
/// This widget handles camera initialization, live frame processing,
/// and displays detection results with bounding boxes and stats

import 'dart:async';
import 'dart:isolate';
import 'package:krishivue/pages/previewpage.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../models/recognition.dart';
import '../models/screen_params.dart';
import '../service/detector_service.dart';
import '../ui/box_widget.dart';
import '../ui/stats_widget.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';

/// Widget that provides real-time object detection from camera feed
/// Sends each camera frame for ML inference in a background isolate
class DetectorWidget extends StatefulWidget {
  const DetectorWidget({super.key});

  @override
  State<DetectorWidget> createState() => _DetectorWidgetState();
}

class _DetectorWidgetState extends State<DetectorWidget>
    with WidgetsBindingObserver {
  /// List of available cameras on the device
  List<CameraDescription>? cameras;
  
  /// Whether rear camera is currently selected (true) or front camera (false)
  bool _isRearCameraSelected = true;
  
  /// Camera controller for managing camera operations
  CameraController? _cameraController;

  /// Getter for initialized camera controller (assumes it's not null when used)
  get _controller => _cameraController;

  /// Object detector running on a background isolate
  /// Null until initialization completes
  Detector? _detector;
  
  /// Subscription to detection results stream from the background isolate
  StreamSubscription? _subscription;

  /// Current detection results for drawing bounding boxes
  List<Recognition>? results;

  /// Real-time performance statistics (inference time, FPS, etc.)
  Map<String, String>? stats;

  @override
  void initState() {
    super.initState();
    // Observe app lifecycle changes (pause/resume)
    WidgetsBinding.instance.addObserver(this);
    _initStateAsync();
  }

  /// Asynchronously initialize camera and detector
  void _initStateAsync() async {
    // Get list of available cameras on device
    cameras = await availableCameras();
    
    // Initialize camera preview and start image stream
    _initializeCamera(cameras![0]);
    
    // Spawn detector in background isolate for ML inference
    Detector.start().then((instance) {
      setState(() {
        _detector = instance;
        // Listen to detection results stream
        _subscription = instance.resultsStream.stream.listen((values) {
          setState(() {
            results = values['recognitions'];
            stats = values['stats'];
          });
        });
      });
    });
  }

  /// Initialize camera with specified camera description
  /// 
  /// Sets up camera controller, starts image stream, and stores preview size
  void _initializeCamera(CameraDescription cameraDescription) async {
    // Create camera controller with low resolution for better performance
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.low,
      enableAudio: false,
    )..initialize().then((_) async {
        // Start streaming camera frames for detection
        await _controller.startImageStream(onLatestImageAvailable);
        setState(() {});

        // Store preview size for scaling bounding boxes
        // 352x288 on iOS, 240p (320x240) on Android with ResolutionPreset.low
        ScreenParams.previewSize = _controller.value.previewSize!;
      });
  }

  /// Capture a picture and navigate to preview page with detection results
  /// 
  /// Captures current frame, packages the best detection result with bounding
  /// box coordinates, and passes to preview page for cropping/display
  Future takePicture() async {
    try {
      print("Camera capture button clicked");
      
      // Capture current frame from camera
      XFile picture = await _cameraController!.takePicture();
      
      print("Detection results before sorting:");
      print(results);
      
      print("Detection results after sorting:");
      print(results?[0]);
      print(results![0].location.left);
      
      // Package bounding box data for the detected object with highest confidence
      final rectData = {
        'left': results![0].location.left,
        'top': results![0].location.top,
        'width': results![0].location.width,
        'height': results![0].location.height,
        'scheight': 300,  // Model input height
        'scwidth': 300,   // Model input width
      };
      
      // Convert bounding box data to JSON string for passing to preview page
      final myString = await json.encode(rectData);
      print(myString);
      
      // Navigate to preview page with captured image and bounding box data
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PreviewPage(
                    picture: picture,
                    myString: myString,
                  )));
                  
    } catch (e) {
      // Show error message in snackbar if capture fails
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
    // Show empty container while camera is initializing
    if (_cameraController == null || !_controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    // Calculate aspect ratio for proper camera preview display
    var aspect = 1 / _controller.value.aspectRatio;

    return Stack(
      children: [
        // Camera preview layer
        AspectRatio(
          aspectRatio: aspect,
          child: CameraPreview(_controller),
        ),
        
        // Bounding boxes overlay layer
        AspectRatio(
          aspectRatio: aspect,
          child: _boundingBoxes(),
        ),
        
        // Bottom control panel with camera switch and capture buttons
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
                // Camera switch button (front/rear)
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
                      // Reinitialize camera with selected camera (0: rear, 1: front)
                      _initializeCamera(cameras![_isRearCameraSelected ? 0 : 1]);
                    },
                  ),
                ),
                // Capture button
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

  /// Widget to display performance statistics (optional, currently disabled)
  Widget _statsWidget() => (stats != null)
      ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.white.withAlpha(150),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: stats!.entries
                    .map((e) => StatsWidget(e.key, e.value))
                    .toList(),
              ),
            ),
          ),
        )
      : const SizedBox.shrink();

  /// Build stack of bounding boxes for all detected objects
  Widget _boundingBoxes() {
    if (results == null) {
      return const SizedBox.shrink();
    }
    return Stack(
        children: results!.map((box) => BoxWidget(result: box)).toList());
  }

  /// Callback invoked for each camera frame
  /// Sends frame to detector for ML inference in background isolate
  void onLatestImageAvailable(CameraImage cameraImage) async {
    _detector?.processFrame(cameraImage);
  }

  /// Handle app lifecycle changes (pause/resume)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        // Stop camera and detector when app goes to background
        _cameraController?.stopImageStream();
        _detector?.stop();
        _subscription?.cancel();
        break;
      case AppLifecycleState.resumed:
        // Restart camera and detector when app returns to foreground
        _initStateAsync();
        break;
      default:
    }
  }

  /// Clean up resources when widget is disposed
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _detector?.stop();
    _subscription?.cancel();
    super.dispose();
  }
}
