import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_ocr/recognize_page.dart';
import 'package:flutter_ocr/widgets/image_cropper.dart';
import 'package:flutter_ocr/widgets/image_picker.dart';
import 'package:flutter_ocr/widgets/modal_dialog.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter OCR"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          imagePickerModal(context, onCameraTap: () {
            log("Camera");
            pickImage(source: ImageSource.camera).then((value) => {
                  if (value != '')
                    {
                      imageCropperView(context, value).then(
                        (value) => {
                          if (value != '')
                            {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RecognizePage(path: value),
                                ),
                              ),
                            },
                        },
                      ),
                    },
                });
          }, onGalleryTap: () {
            log("Gallery");
            pickImage(source: ImageSource.gallery).then((value) => {
                  if (value != '')
                    {
                      imageCropperView(context, value).then(
                        (value) => {
                          if (value != '')
                            {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RecognizePage(path: value),
                                ),
                              ),
                            },
                        },
                      ),
                    }
                });
          });
        },
        label: const Text("Scan photo"),
      ),
    );
  }
}
