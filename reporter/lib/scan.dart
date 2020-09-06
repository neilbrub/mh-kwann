import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:reporter/credentials.dart';
import 'package:googleapis/vision/v1.dart' as Vision;


// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  final Function(bool, String) updateForm;

  const TakePictureScreen({
    Key key,
    @required this.camera,
    this.updateForm
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.high,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Construct the path where the image should be saved using the
            // pattern package.
            final path = join(
              // Store the picture in the temp directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );

            // Attempt to take a picture and log where it's been saved.
            await _controller.takePicture(path);

            // If the picture was taken, display it on a new screen.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(imagePath: path, callback: widget.updateForm),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final Function(bool, String) callback;

  const DisplayPictureScreen({Key key, this.imagePath, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
      floatingActionButton: FloatingActionButton(
        child: Text("Scan"),
        onPressed: () async {
          try {
            // Send encoded image to vision API for DOCUMENT_TEXT_DETECTION
            final base64Str = base64.encode(File(imagePath).readAsBytesSync());

            var _client = CredentialsProvider().client;

            var _vision = Vision.VisionApi(await _client);
            var _api = _vision.images;
            var _response = await _api.annotate(Vision.BatchAnnotateImagesRequest.fromJson({
              "requests": [
                {
                  "image": {"content": base64Str},
                  "features": [
                    {"type": "DOCUMENT_TEXT_DETECTION"}
                  ]
                }
              ]
            }));
            
            /**
             * This is where a trained NLP model could offer extensible comprehension
             * of Paramedic remarks. Currently, it looks only for one remark specific to
             * Naloxone administration.
             */
            LineSplitter ls = new LineSplitter();
            List<String> blocks = ls.convert(_response.responses[0].fullTextAnnotation.text);
            int remarksIdx = -1;
            blocks.asMap().forEach((index, value) {
              if (value == "Remarks") {
                remarksIdx = index;
              }
            });
            
            String remark = "";
            if (remarksIdx > -1) remark = blocks[remarksIdx+1];
            print("\nRemarks:");
            print(remark);

            bool naloxoneAdministeredFlag = false;
            // For now, if remark exists assume it refers to Naloxone administration
            if (remark != "") naloxoneAdministeredFlag = true;

            callback(naloxoneAdministeredFlag, remark);
            Navigator.pop(context);
            Navigator.pop(context);

          } catch (e) {
            print(e);
          }
        }
      ),
    );
  }
}

