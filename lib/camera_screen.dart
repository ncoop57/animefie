import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

import 'gallery_screen.dart';

// Supported models
Map<String, List<String>> urls = {
  'ArcaneGAN': [
    'https://hf.space/gradioiframe/akhaliq/ArcaneGAN/api/predict',
    'version 0.4'
  ],
  'AnimeGANv2': [
    'https://hf.space/gradioiframe/akhaliq/AnimeGANv2/api/predict',
    'version 2 (\ud83d\udd3a stylization, \ud83d\udd3b robustness)'
  ],
  'JoJoGAN': [
    'https://hf.space/gradioiframe/akhaliq/JoJoGAN/api/predict',
    'Disney'
  ],
  'GFP-GAN': ['https://hf.space/gradioiframe/akhaliq/GFPGAN/api/predict'],
  'Apocalyptify': [
    'https://hf.space/gradioiframe/Norod78/Apocalyptify/+/api/predict'
  ],
};

Future<Uint8List> animefyImage(String imageBase64, String model) async {
  var data = [imageBase64];
  // Check if the model requires additional parameters
  if (urls[model]!.length > 1) {
    data.add(urls[model]![1]);
  }
  // Animefy the given image by requesting the gradio API of AnimeGANv2
  final response = await http.post(
    Uri.parse(urls[model]![0]),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, List<String>>{
      'data': data,
    }),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 CREATED response,
    // then decode the image and return it.
    final imageData = jsonDecode(response.body)["data"][0]
        .replaceAll('data:image/png;base64,', '')
        .replaceAll('data:image/jpeg;base64,', ''); // Some models return jpeg
    return base64Decode(imageData);
  } else {
    // If the server did not return a 200 OKAY response,
    // then throw an exception.
    throw Exception('Failed to animefy the image.');
  }
}

Future<void> applyRotationFix(File imgFile) async {
  // Fix the rotation of the image based on its orientation metadata
  // code from: https://stackoverflow.com/a/62807277
  final bytes = imgFile.readAsBytesSync();
  final img.Image? capturedImage = img.decodeImage(bytes);
  final img.Image orientedImage = img.bakeOrientation(capturedImage!);
  await imgFile.writeAsBytes(img.encodeJpg(orientedImage));
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({
    Key? key,
    required this.cameras,
  }) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String dropdownValue = 'ArcaneGAN';
  bool isLoading = false;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    initializeCamera(selectedCamera); //Initially selectedCamera = 0
    super.initState();
  }

  late CameraController _controller; //To control the camera
  late Future<void>
      _initializeControllerFuture; //Future to wait until camera initializes
  int selectedCamera = 0;
  List<File> capturedImages = [];

  initializeCamera(int cameraIndex) async {
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.cameras[cameraIndex],
      // Define the resolution to use.
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                // code from: https://stackoverflow.com/a/57584580
                // Handle screen rotations.
                return NativeDeviceOrientationReader(
                  useSensor: true,
                  builder: (context) {
                    NativeDeviceOrientation orientation =
                        NativeDeviceOrientationReader.orientation(context);

                    // Determine number of turns based on screen orientation.
                    int turns;
                    switch (orientation) {
                      case NativeDeviceOrientation.landscapeLeft:
                        turns = 1;
                        break;
                      case NativeDeviceOrientation.landscapeRight:
                        turns = -1;
                        break;
                      case NativeDeviceOrientation.portraitDown:
                        turns = 2;
                        break;
                      default:
                        turns = 0;
                        break;
                    }
                    return RotatedBox(
                      quarterTurns: turns,
                      child: CameraPreview(_controller),
                    );
                  },
                );
              } else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          const Spacer(),
          Center(
            child: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.black,
              ),
              child: DropdownButton<String>(
                  value: dropdownValue,
                  icon: const Icon(Icons.arrow_downward),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                    });
                  },
                  items:
                      urls.keys.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList()),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    // If there is another camera available on device,
                    // toggle to the other camera. If this is the only
                    // camera, toggle to the camera at index 0.
                    if (widget.cameras.length > 1) {
                      setState(() {
                        selectedCamera = selectedCamera == 0 ? 1 : 0;
                        initializeCamera(selectedCamera);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('No secondary camera found'),
                        duration: Duration(seconds: 2),
                      ));
                    }
                  },
                  icon: const Icon(Icons.switch_camera_rounded,
                      color: Colors.white),
                ),
                // Switch between loading indicator and capture button.
                AnimatedSwitcher(
                  // From: https://stackoverflow.com/a/62779504
                  duration: const Duration(milliseconds: 300),
                  child: isLoading
                      ? const SpinKitSpinningLines(
                          key: Key("loading"),
                          color: Colors.white,
                          size: 50.0,
                        )
                      : GestureDetector(
                          key: const Key("normal"),
                          onTap: () async {
                            _toggle();
                            await _initializeControllerFuture;

                            // Take photo and fix any rotation issues
                            final xFile = await _controller.takePicture();
                            final imgFile = File(xFile.path);
                            await applyRotationFix(imgFile);

                            // Animefy the image
                            final imgBytes = imgFile.readAsBytesSync();
                            String base64Image = "data:image/png;base64," +
                                base64Encode(imgBytes);

                            try {
                              final animeBytes = await animefyImage(
                                  base64Image, dropdownValue);

                              // Save the image
                              imgFile.writeAsBytesSync(animeBytes);
                              GallerySaver.saveImage(imgFile.path);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Image saved to gallery'),
                                duration: Duration(seconds: 2),
                              ));

                              setState(() {
                                capturedImages.add(imgFile);
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('An Error Occurred'),
                                duration: Duration(seconds: 2),
                              ));
                            }
                            _toggle();
                          },
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
                GestureDetector(
                  onTap: () {
                    if (capturedImages.isEmpty) return;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GalleryScreen(
                                images: capturedImages.reversed.toList())));
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      image: capturedImages.isNotEmpty
                          ? DecorationImage(
                              image: FileImage(capturedImages.last),
                              fit: BoxFit.cover)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  _toggle() {
    // Toggle the loading indicator.
    setState(() {
      isLoading = !isLoading;
    });
  }
}
