import 'dart:math';
import 'dart:ui';

/// Singleton class to store and manage screen and camera preview dimensions
/// 
/// This class helps in scaling the ML model output (bounding boxes) from the
/// model's input size to the actual screen display size for proper rendering.
class ScreenParams {
  /// Size of the device screen
  static late Size screenSize;
  
  /// Size of the camera preview from the camera controller
  static late Size previewSize;

  /// Aspect ratio of the camera preview
  /// Calculated as max dimension / min dimension
  static double previewRatio = max(previewSize.height, previewSize.width) /
      min(previewSize.height, previewSize.width);

  /// Actual size of the preview as displayed on screen
  /// Maintains aspect ratio while fitting the screen width
  static Size screenPreviewSize =
      Size(screenSize.width, screenSize.width * previewRatio);
}
