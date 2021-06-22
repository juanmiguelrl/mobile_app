import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'dart:io';
import 'dart:async';

import '../providers/request_provider.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker picker = ImagePicker();

  void _getImage(ImageSource source) async {
    if (source == ImageSource.camera && !(await Permission.camera.request().isGranted))
      return;
    if (source == ImageSource.gallery && !(await Permission.storage.request().isGranted))
      return;

    final PickedFile file = await picker.getImage(source: source);

    if (file != null)
      Provider.of<RequestProvider>(context, listen: false).fetchResult(File(file.path));
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(1080, 2220), allowFontScaling: true);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Theme.of(context).primaryColor,
      ),

      body: Center(
        child: Column(
          children: <Widget> [
            _buildLogoWidgets(),

            Consumer<RequestProvider>(
              builder: (context, provider, child) {
                // Async callbacks (executed after build is completed)
                if (provider.status == RequestStatus.SUCCESS)
                  WidgetsBinding.instance.addPostFrameCallback((_) =>
                      _navigateToResultPage());

                else if (provider.status == RequestStatus.ERROR)
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) {
                      var error = Provider.of<RequestProvider>(context, listen: false).error;
                      _showDialogError(error['name'], error['msg']);
                    }
                  );

                // Sync callbacks, construct the UI
                if (provider.status == RequestStatus.PROCESSING)
                  return _buildLoadingWidgets();
                else
                  return _buildStartWidgets();
              }
            ),
          ]
        ),
      )
    );
  }

  Future<void> _navigateToResultPage() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => ResultPage())
    );
  }
  Future<void> _showDialogError(String title, String msg) async {
    await showDialog(
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

  Widget _buildLogoWidgets() {
    return Column(
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
      ],
    );
  }
  Widget _buildStartWidgets() {
    return Column(
        children: <Widget>[
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
                        onPressed: () => _getImage(ImageSource.gallery),
                    )
                )
              ]
          ),
        ]
    );
  }
  Widget _buildLoadingWidgets() {
    return Column(
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
    );
  }
}