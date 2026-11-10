// Copyright 2023 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image_lib;
import '../models/recognition.dart';
import '../utils/image_utils.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

// Detection runs on a background isolate. Protocol:
//   server -> init(sendPort) -> detector -> init(token, interpreter, labels)
//   -> server -> ready; then per frame: detect -> busy -> result.
enum _Codes {
  init,
  busy,
  ready,
  detect,
  result,
}

class _Command {
  const _Command(this.code, {this.args});

  final _Codes code;
  final List<Object>? args;
}

/// UI-side handle; all preprocessing and inference happen on [_DetectorServer].
class Detector {
  static const String _modelPath = 'assets/models/final.tflite';
  static const String _labelPath = 'assets/models/labelmap.txt';

  Detector._(this._isolate, this._interpreter, this._labels);

  final Isolate _isolate;
  late final Interpreter _interpreter;
  late final List<String> _labels;

  late final SendPort _sendPort;

  bool _isReady = false;

  final StreamController<Map<String, dynamic>> resultsStream =
      StreamController<Map<String, dynamic>>();

  static Future<Detector> start() async {
    final ReceivePort receivePort = ReceivePort();
    final Isolate isolate =
        await Isolate.spawn(_DetectorServer._run, receivePort.sendPort);

    final Detector result = Detector._(
      isolate,
      await _loadModel(),
      await _loadLabels(),
    );
    receivePort.listen((message) {
      result._handleCommand(message as _Command);
    });
    return result;
  }

  static Future<Interpreter> _loadModel() async {
    final interpreterOptions = InterpreterOptions();

    if (Platform.isAndroid) {
      interpreterOptions.addDelegate(XNNPackDelegate());
    }

    return Interpreter.fromAsset(
      _modelPath,
      options: interpreterOptions..threads = 4,
    );
  }

  static Future<List<String>> _loadLabels() async {
    return (await rootBundle.loadString(_labelPath)).split('\n');
  }

  void processFrame(CameraImage cameraImage) {
    if (_isReady) {
      _sendPort.send(_Command(_Codes.detect, args: [cameraImage]));
    }
  }

  void _handleCommand(_Command command) {
    switch (command.code) {
      case _Codes.init:
        _sendPort = command.args?[0] as SendPort;
        // The background isolate needs this token to use plugins.
        RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
        _sendPort.send(_Command(_Codes.init, args: [
          rootIsolateToken,
          _interpreter.address,
          _labels,
        ]));
      case _Codes.ready:
        _isReady = true;
      case _Codes.busy:
        _isReady = false;
      case _Codes.result:
        _isReady = true;
        resultsStream.add(command.args?[0] as Map<String, dynamic>);
      default:
        debugPrint('Detector unrecognized command: ${command.code}');
    }
  }

  void stop() {
    _isolate.kill();
  }
}

class _DetectorServer {
  static const int mlModelInputSize = 300;

  static const double confidence = 0.4;
  Interpreter? _interpreter;
  List<String>? _labels;

  _DetectorServer(this._sendPort);

  final SendPort _sendPort;

  static void _run(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    final _DetectorServer server = _DetectorServer(sendPort);
    receivePort.listen((message) async {
      final _Command command = message as _Command;
      await server._handleCommand(command);
    });
    sendPort.send(_Command(_Codes.init, args: [receivePort.sendPort]));
  }

  Future<void> _handleCommand(_Command command) async {
    switch (command.code) {
      case _Codes.init:
        RootIsolateToken rootIsolateToken =
            command.args?[0] as RootIsolateToken;
        BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
        _interpreter = Interpreter.fromAddress(command.args?[1] as int);
        _labels = command.args?[2] as List<String>;
        _sendPort.send(const _Command(_Codes.ready));
      case _Codes.detect:
        _sendPort.send(const _Command(_Codes.busy));
        _convertCameraImage(command.args?[0] as CameraImage);
      default:
        debugPrint('_DetectorService unrecognized command ${command.code}');
    }
  }

  void _convertCameraImage(CameraImage cameraImage) {
    convertCameraImageToImage(cameraImage).then((image) {
      if (image != null) {
        if (Platform.isAndroid) {
          image = image_lib.copyRotate(image, angle: 90);
        }

        final results = analyseImage(image);
        _sendPort.send(_Command(_Codes.result, args: [results]));
      }
    });
  }

  Map<String, dynamic> analyseImage(image_lib.Image? image) {
    // The whole frame is squashed (not cropped) to the model's square input.
    final imageInput = image_lib.copyResize(
      image!,
      width: mlModelInputSize,
      height: mlModelInputSize,
    );

    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(
        imageInput.width,
        (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
         } 
      ),
    );

    final output = _runInference(imageMatrix);

    final locationsRaw = output.elementAt(1).first as List<List<double>>;

    final List<Rect> locations = locationsRaw
        .map((list) => list.map((value) => (value * mlModelInputSize)).toList())
        // Boxes come as [ymin, xmin, ymax, xmax].
        .map((rect) => Rect.fromLTRB(rect[1], rect[0], rect[3], rect[2]))
        .toList();
    final classesRaw = output.last.first as List<double>;
    final classes = classesRaw.map((value) => value.toInt()).toList();
    final scores = output.first.first as List<double>;
    final numberOfDetectionsRaw = output.elementAt(2).first as double;
    final numberOfDetections = numberOfDetectionsRaw.toInt();
    final List<String> classification = [];
    for (var i = 0; i < numberOfDetections; i++) {
      classification.add(_labels![classes[i]]);
    }

    List<Recognition> recognitions = [];
    for (int i = 0; i < numberOfDetections; i++) {
      var score = scores[i];
      var label = classification[i];

      if (score > confidence) {
        recognitions.add(
          Recognition(i, label, score, locations[i]),
        );
      }
    }

    return {"recognitions": recognitions};
  }

  List<List<Object>> _runInference(
    List<List<List<num>>> imageMatrix,
  ) {
    final input = [imageMatrix];

    // SSD outputs: 0 scores [1, 10], 1 boxes [1, 10, 4], 2 count [1], 3 classes [1, 10].
    final output = {
      0: [List<num>.filled(10, 0)],
      1: [List<List<num>>.filled(10, List<num>.filled(4, 0))],
      2: [0.0],
      3: [List<num>.filled(10, 0)],
    };

    _interpreter!.runForMultipleInputs([input], output);
    return output.values.toList();
  }
}