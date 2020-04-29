import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

List<CameraDescription> camerasList;

class CameraTest extends StatefulWidget {
  const CameraTest({Key key}) : super(key: key);

  @override
  _CameraTestState createState() => new _CameraTestState();
}

class _CameraTestState extends State<CameraTest> {
  CameraController controller;
  List<String> imageList = <String>[];
  String imagePath;
  double _animatedHeight = 0.0;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  void initCamera() async {
    camerasList = await availableCameras();
    controller = new CameraController(camerasList[0], ResolutionPreset.medium);
    await controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    setState(() {
      _animatedHeight = 30.0;
      _errorMsg = message;
    });

    Future<void>.delayed(const Duration(seconds: 1), _hideErrorMsg);
  }

  void _hideErrorMsg() {
    setState(() {
      _animatedHeight = 0.0;
      _errorMsg = '';
    });
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final PermissionStatus writeAccess = await Permission.storage.request();

    Directory extDir;
    // if user disagrees to allow storage access the use app storage
    if (writeAccess.isGranted) {
      extDir = await getExternalStorageDirectory();
    } else {
      extDir = await getApplicationDocumentsDirectory();
    }
    final String dirPath = '${extDir.path}/Pictures/pics';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      print('Exception -> $e');
      return null;
    }
    final File makeFile = new File(filePath);
    setState(() {
      imageList.add(makeFile.absolute.path);
    });
    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return new Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }
    return new Stack(
      alignment: Alignment.center,
      children: <Widget>[
        new AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: new CameraPreview(controller)),
        new Positioned(
          child: new GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.close,
              color: Colors.grey,
              size: 30.0,
            ),
          ),
          top: 30.0,
          right: 10.0,
        ),
        new Container(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Container(
                height: 60.0,
                child: new ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext c, int i) {
                    return Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: new Image.asset(imageList[i]),
                    );
                  },
                  itemCount: imageList.length,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new GestureDetector(
                    onTap: () async {
                      final File galleryImagePath = await ImagePicker.pickImage(
                          source: ImageSource.gallery);
                      if (galleryImagePath != null) {
                        setState(() {
                          imageList.add(galleryImagePath.absolute.path);
                        });
                      }
                    },
                    child: const Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      child: const Icon(
                        Icons.add_box,
                        color: Colors.white,
                        size: 40.0,
                      ),
                    ),
                  ),
                  new FlatButton(
                    padding: const EdgeInsets.all(10.0),
                    onPressed: () {
                      takePicture();
                    },
                    child: const Icon(
                      Icons.camera,
                      color: Colors.blue,
                      size: 40.0,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(imageList);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: new BoxDecoration(
                        color: imageList.isEmpty ? Colors.grey : Colors.blue,
                        borderRadius: new BorderRadius.circular(40.0),
                      ),
                      child: const Icon(Icons.done),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
