import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ocr/result_screen.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePagePart1 extends StatefulWidget {
  const HomePagePart1({super.key});

  @override
  State<HomePagePart1> createState() => HomePagePart1State();
}

class HomePagePart1State extends State<HomePagePart1>
    with WidgetsBindingObserver {
  bool _isPermissionGranted = false;

  late final Future<void> _future;
  CameraController? _cameraController;
  final _textRecognizer = TextRecognizer();

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  @override
  void initState() {
    _future = _requestCameraPermission();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
    // super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return Stack(
          children: [
            if (_isPermissionGranted)
              FutureBuilder<List<CameraDescription>>(
                future: availableCameras(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _initCameraController(snapshot.data!);
                    return Center(
                      child: CameraPreview(_cameraController!),
                    );
                  } else {
                    return const LinearProgressIndicator();
                  }
                },
              ),
            Scaffold(
              appBar: AppBar(
                title: const Text("Flutter OCR"),
              ),
              backgroundColor: _isPermissionGranted ? Colors.transparent : null,
              body: _isPermissionGranted
                  ? Column(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: _scanImage,
                              child: const Text("Scan Text"),
                            ),
                          ),
                        )
                      ],
                    )
                  : Center(
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                        ),
                        child: const Text(
                          "Camera permission denied",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }
    CameraDescription? camera;
    for (var i = 0; i <= cameras.length; i++) {
      final CameraDescription current = cameras[i];

      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }
    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController =
        CameraController(camera, ResolutionPreset.max, enableAudio: false);

    await _cameraController?.initialize();

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _scanImage() async {
    if (_cameraController == null) return;

    final navigator = Navigator.of(context);

    try {
      final pictureFile = await _cameraController!.takePicture();

      final file = File(pictureFile.path);

      final inputImage = InputImage.fromFile(file);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      await navigator.push(
        MaterialPageRoute(
          builder: (BuildContext context) =>
              ResultScreen(text: recognizedText.text),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred when scanning text'),
        ),
      );
    }
  }
}
