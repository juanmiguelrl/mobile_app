import 'package:flutter/material.dart';

import 'homepage.dart';

void main() => runApp(PhotoTaggingApp());

class PhotoTaggingApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhotoTaggingApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,

        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: new HomePage(),
    );
  }
}

