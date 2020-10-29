import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maskcheck/util/MySlide.dart';
import 'decision_screen.dart';
import 'package:tflite/tflite.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  String label;
  File image;
  double conf;
  classifyImage() async {
    var output = await Tflite.runModelOnImage(
        path: widget.imagePath,
        // required
        imageMean: 0.0,
        // defaults to 117.0
        imageStd: 255.0,
        // defaults to 1.0
        numResults: 2,
        // defaults to 5
        threshold: 0.2,
        // defaults to 0.1
        asynch: true // defaults to true
        );
    setState(() {
      label = output[0]['label'];
      conf = output[0]['confidence'] * 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1B20),
      body: ListView(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.file(
              File(widget.imagePath),
            ),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith(
                      (states) => Color(0xFF13161D),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 35,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith(
                      (states) => Color(0xFF13161D),
                    ),
                  ),
                  onPressed: () async {
                    await classifyImage();
                    Navigator.push(context, MySlide(builder: (context) {
                      return DecisionScreen(
                        imagePath: widget.imagePath,
                        label: label,
                        conf: conf,
                      );
                    }));
                  },
                  child: Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 35,
                  ),
                ),
              ),
              // FlatButton(
              //   shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(10)),
              //   color: Colors.white30,
              //   onPressed: () {},
              //   child: Icon(
              //     Icons.close,
              //     color: Colors.red,
              //     size: 35,
              //   ),
              // ),
              // FlatButton(
              //   color: Colors.white30,
              //   shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(10)),
              //   onPressed: () async {
              //     await classifyImage();
              //     Navigator.push(context, MySlide(builder: (context) {
              //       return DecisionScreen(
              //         imagePath: widget.imagePath,
              //         label: label,
              //         conf: conf,
              //       );
              //     }));
              //   },
              //   child: Icon(
              //     Icons.check,
              //     color: Colors.green,
              //     size: 35,
              //   ),
              // ),
            ],
          )
        ],
      ),
    );
  }
}
