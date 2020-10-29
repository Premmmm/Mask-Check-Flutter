import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:maskcheck/util/MySlide.dart';
import 'package:tflite/tflite.dart';
import 'display_picture_screen.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.ultraHigh,
    );

    _initializeControllerFuture = _controller.initialize();

    loadModel().then((value) {
      setState(() {});
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/converted_model.tflite",
        labels: "assets/labels.txt",
        numThreads: 1 // defaults to 1
        );
  }

  @override
  void dispose() {
    Tflite.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xFF1A1B20),
          ),
          child: Column(
            children: <Widget>[
              Container(
                height: 650,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                ),
                child: FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: CameraPreview(_controller),
                        ),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                    (states) => Color(0xFF13161D),
                  ),
                ),
                onPressed: () async {
                  try {
                    await _initializeControllerFuture;
                    final path = join(
                      (await getTemporaryDirectory()).path,
                      '${DateTime.now()}.png',
                    );
                    await _controller.takePicture(path);
                    Navigator.push(
                      context,
                      MySlide(
                        builder: (context) =>
                            DisplayPictureScreen(imagePath: path),
                      ),
                    );
                  } catch (e) {
                    print(e);
                  }
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                  child: Icon(
                    Icons.photo_camera,
                    size: 30,
                  ),
                ),
              ),
              // Container(
              //   decoration: BoxDecoration(
              //     color: Colors.black87,
              //     borderRadius: BorderRadius.all(Radius.elliptical(10, 20)),
              //   ),
              //   child: RawMaterialButton(
              //     elevation: 10,
              //     child: Icon(
              //       Icons.photo_camera,
              //       size: 35,
              //       color: Colors.grey[400],
              //     ),
              //     onPressed: () async {
              //       try {
              //         await _initializeControllerFuture;
              //         final path = join(
              //           (await getTemporaryDirectory()).path,
              //           '${DateTime.now()}.png',
              //         );
              //         await _controller.takePicture(path);
              //         Navigator.push(
              //           context,
              //           MySlide(
              //             builder: (context) =>
              //                 DisplayPictureScreen(imagePath: path),
              //           ),
              //         );
              //       } catch (e) {
              //         print(e);
              //       }
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
