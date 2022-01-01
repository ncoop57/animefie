import 'dart:io';

import 'package:flutter/material.dart';

class GalleryScreen extends StatelessWidget {
  final List<File> images;
  const GalleryScreen({Key? key, required this.images}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        backgroundColor: const Color(0xFF2D3035),
      ),
      body: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        children: images
            .asMap()
            .entries
            .map((entry) => GestureDetector(
                  // Setup ontap for each image to show the selected image in full screen
                  // Code from: https://stackoverflow.com/a/60846537
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GalleryImageScreen(
                            key: Key('${entry.key}'),
                            image: Image.file(entry.value),
                            tag: entry.key.toString()),
                      ),
                    );
                  },
                  child: Hero(
                    child: Image.file(entry.value),
                    tag: entry.key.toString(),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// Code from: https://stackoverflow.com/a/60846537
class GalleryImageScreen extends StatelessWidget {
  final Image image;
  final String tag;

  const GalleryImageScreen(
      {required Key key, required this.image, required this.tag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: tag,
            child: image,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
