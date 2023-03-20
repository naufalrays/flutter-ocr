import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class RecognizePage extends StatefulWidget {
  const RecognizePage({
    Key? key,
    required this.path,
  }) : super(key: key);
  final String? path;

  @override
  State<RecognizePage> createState() => _RecognizePageState();
}

class _RecognizePageState extends State<RecognizePage> {
  bool _isBusy = false;
  String data = '';

  @override
  void initState() {
    super.initState();
    final InputImage inputImage = InputImage.fromFilePath(widget.path!);
    processImage(inputImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Recognize Page"),
        ),
        body: _isBusy == true
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Text(data));
  }

  void processImage(InputImage image) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    setState(() {
      _isBusy = true;
    });

    final RecognizedText recognizedText =
        await textRecognizer.processImage(image);
    data = recognizedText.text;

    setState(() {
      _isBusy = false;
    });
  }
}
