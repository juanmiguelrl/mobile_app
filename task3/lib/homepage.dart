import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'client.dart' show Client, Response;
import 'resultspage.dart' show ResultPage;

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final picker = ImagePicker();

  bool _isProcessingImage, _connectionFailed;
  String errorMsg;

  // Take a photo from the source (typically camera or gallery)
  Future<void> _getImage(ImageSource imageSource) async {

    // Check for permissions
    if (imageSource == ImageSource.camera && !(await Permission.camera.request().isGranted))
      return;
    if (imageSource == ImageSource.gallery && !(await Permission.storage.request().isGranted))
      return;

    // Pick the image
    final PickedFile pickedFile = await picker.getImage(source: imageSource);

    if (pickedFile != null) {
      try {
        setState(() {
          _isProcessingImage = true;
          _connectionFailed = false;
        });

        // Process the request
        File file = new File(pickedFile.path);
        Response response = await Client.fetchResult(file);

        // Any exception was thrown, navigate to the result page
        Navigator.push(context, MaterialPageRoute(builder: (context) => ResultPage(pickedFile: file, tagsList: response.tags)));

      } on TimeoutException catch (_) {
        setState(() => _showDialogError('Timeout expired', 'Could not process your request'));
      } on SocketException {
        setState(() => _showDialogError('Connection failed', 'Cannot establish connection'));
      } on Exception catch (e) {
        print("Error fetching the result: $e");
        setState(() => _showDialogError('Error', 'Something went wrong. Please, try again.'));
      } finally {
        setState(() => _isProcessingImage = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _isProcessingImage = false;
    _connectionFailed = false;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(1080, 2220), allowFontScaling: true);

    return Scaffold(
      appBar: AppBar(
          title: Text('Home')
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 400.h),
            Text(
                'PhotoTaggingApp',
                style: TextStyle(
                    fontSize: 100.sp,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic
                )
            ),
            SizedBox(height: 200.h),

            if (!_isProcessingImage)
              _buildStartWidgets()
            else
              _buildLoadingWidgets(),
          ],
        ),
      ),
    );
  }

  Widget _buildStartWidgets() {
    return Column(
      children: <Widget> [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Ink(
              width: 128.h,
              height: 128.h,
              decoration: const ShapeDecoration(
                color: Colors.lightBlue,
                shape: CircleBorder(),
              ),
              child: IconButton(
                icon: Icon(Icons.camera_alt),
                iconSize: 70.h,
                color: Colors.white,
                tooltip: 'Open the camera',
                onPressed: () => _getImage(ImageSource.camera),
              ),
            ),
            SizedBox(width: 0.075.sw),
            Text(
              'Take a picture!',
              style: TextStyle(
                fontSize: 70.sp,
              )
            ),
          ],
        ),
        SizedBox(height: 30.h),
        Divider(
          color: Colors.black,
          thickness: 2.h,
          indent: 0.1.sw,
          endIndent: 0.1.sw,
        ),
        SizedBox(height: 30.h),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Select from \n the gallery',
                style: TextStyle(
                  fontSize: 70.sp,
                )
              ),
              SizedBox(width: 0.075.sw),
              Ink(
                width: 128.h,
                height: 128.h,
                decoration: const ShapeDecoration(
                  color: Colors.lightBlue,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                    icon: Icon(Icons.photo_library),
                    iconSize: 70.h,
                    color: Colors.white,
                    tooltip: 'Open the gallery',
                    onPressed: () {
                      _getImage(ImageSource.gallery);
                    }
                )
              )
            ]
        ),
      ]
    );
  }

  Widget _buildLoadingWidgets() {
    return Center(
        child: Column(
            children: <Widget>[
              SizedBox(height: 100.h),
              CircularProgressIndicator(),
              SizedBox(height: 50.h),
              Text(
                'Processing your image...',
                style: TextStyle(
                    fontSize: 40.sp
                )
              ),
            ]
        )
    );
  }

  void _showDialogError(String title, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              '$title',
          style: TextStyle(
            fontSize: 60.sp
            )
          ),
          content: Text(
            '$msg',
            style: TextStyle(
              fontSize: 50.sp
            )
          ),
          actions: <Widget> [
            TextButton(
              child: Text(
                'Return home',
                style: TextStyle(
                  fontSize: 50.sp
                )
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}