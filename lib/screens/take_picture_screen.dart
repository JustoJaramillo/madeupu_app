import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:madeupu_app/models/response.dart';

import 'display_picture_screen.dart';

class TakePictureScreen extends StatefulWidget {
  final List<CameraDescription> camera;

  // ignore: use_key_in_widget_constructors
  const TakePictureScreen({required this.camera});

  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRearCamera = true;
  //var _cameraSelected;

  @override
  void initState() {
    super.initState();
    _selectCamera();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take picture'),
      ),
      body: Column(
        children: <Widget>[
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  child: Text(_isRearCamera ? 'Rear camera' : 'Main camera'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      return const Color(0xFF120E43);
                    }),
                  ),
                  onPressed: () {
                    _selectCamera();
                    setState(() {
                      _isRearCamera;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            Response? response =
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => DisplayPictureScreen(
                          image: image,
                        )));
            if (response != null) {
              Navigator.pop(context, response);
            }
          } catch (e) {
            await showAlertDialog(
                context: context,
                title: 'Error',
                message: 'An error has occurred, please try again.',
                actions: <AlertDialogAction>[
                  const AlertDialogAction(key: null, label: 'Accept'),
                ]);
          }
        },
      ),
    );
  }

  void _selectCamera() {
    /* _isRearCamera
        ? _cameraSelected = widget.camera[1]
        : _cameraSelected = widget.camera[0]; */
    _controller = CameraController(
      _isRearCamera ? widget.camera[1] : widget.camera[0],
      ResolutionPreset.low,
    );
    _initializeControllerFuture = _controller.initialize();
    _isRearCamera = !_isRearCamera;
  }
}
