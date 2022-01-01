import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'camera_screen.dart';

// code from: https://github.com/jagrut-18/flutter_camera_app/blob/master/lib/gallery_screen.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animefie',
      home: CameraScreen(cameras: cameras),
    );
  }
}
