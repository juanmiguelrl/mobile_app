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

  File file;

  void _getImage(ImageSource source) async {
    if (source == ImageSource.camera && !(await Permission.camera.request().isGranted))
      return;
    if (source == ImageSource.gallery && !(await Permission.storage.request().isGranted))
      return;

    final PickedFile picked = await picker.getImage(source: source);

    if (picked != null) {
      file = File(picked.path);
      _sendRequest(file);
    }
  }

  void _sendRequest(File file) => Provider.of<RequestProvider>(context, listen: false).fetchResult(file);

  Future<void> _navigateToResultPage() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => ResultPage())
    );
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
            children: <Widget>[
              _buildLogoWidgets(context),

              Consumer<RequestProvider>(
                  builder: (context, provider, child) {
                    // Async callbacks (executed after build is completed)
                    if (provider.status == RequestStatus.SUCCESS)
                      WidgetsBinding.instance.addPostFrameCallback((_) =>
                          _navigateToResultPage());

                    else if (provider.status == RequestStatus.ERROR)
                      WidgetsBinding.instance.addPostFrameCallback(
                              (_) =>
                              Scaffold.of(context).showSnackBar(_buildSnackBar(
                                  context,
                                  Provider.of<RequestProvider>(context, listen: false).error['msg'],
                                  5)
                              )
                      );

                    // Sync callbacks, construct the UI
                    if (provider.status == RequestStatus.PROCESSING)
                      return _buildLoadingWidgets(context);
                    else
                      return _buildStartWidgets(context);
                  }
              ),
            ]
        ),
      ),

    );

  }

  Widget _buildSnackBar(BuildContext context, String msg, int duration) {
    return SnackBar(
        content: Text(msg),
        duration: Duration(seconds: duration),
        backgroundColor: Theme.of(context).errorColor,
        action: SnackBarAction(
          label: 'RETRY',
          onPressed: () {
            _sendRequest(file);
            Scaffold.of(context).hideCurrentSnackBar();
          },
        )
    );
  }

  Widget _buildLogoWidgets(BuildContext context) {
    bool horizontal = (MediaQuery.of(context).orientation == Orientation.landscape);

    return Column(
      children: <Widget>[
        SizedBox(height: horizontal ? 200.h : 400.h),
        Text(
          'PhotoTaggingApp',
          style: TextStyle(
              fontSize: horizontal ? 50.sp : 100.sp,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic
          )
        ),
        SizedBox(height: horizontal ? 100.h : 200.h),
      ],
    );
  }

  Widget _buildText(BuildContext context, String text) {
    bool horizontal = (MediaQuery.of(context).orientation == Orientation.landscape);

    return Text(
        text,
        style: TextStyle(
          fontSize: horizontal ? 60.sp : 65.sp,
            //fontFamily:
        )
    );
  }
  Widget _buildButton(BuildContext context, IconData icon, String tooltip, ImageSource source) {
    bool horizontal = (MediaQuery.of(context).orientation == Orientation.landscape);

    return Ink(
      width: horizontal ? 128.w : 128.h,
      height: horizontal ? 128.w : 128.h,
      decoration: const ShapeDecoration(
        color: Colors.lightBlue,
        shape: CircleBorder(),
      ),
      child: IconButton(
        icon: Icon(icon),
        iconSize: horizontal ? 64.w : 64.h,
        color: Colors.white,
        tooltip: tooltip,
        onPressed: () => _getImage(source),
      ),
    );
  }

  Widget _buildStartWidgets(BuildContext context) {
    bool horizontal = (MediaQuery.of(context).orientation == Orientation.landscape);

    return horizontal ? IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
          Column(
            children: <Widget> [
              SizedBox(height: 50.h),
              _buildText(context, 'Take a picture!'),
              SizedBox(height: 0.075.sh),
              _buildButton(context, Icons.camera_alt, 'Open the camera', ImageSource.camera),
            ]
          ),

          SizedBox(width: 30.w),
          VerticalDivider(
            color: Colors.black,
            thickness: 1.w,
            indent: 40.w,
          ),
          SizedBox(width: 30.w),

          Column(
            children: <Widget> [
              SizedBox(height: 50.h),
              _buildText(context, 'Select one image'),
              SizedBox(height: 0.075.sh),
              _buildButton(context, Icons.photo_library, 'Open the gallery', ImageSource.gallery),
            ]
          ),
        ]
      )
    ) : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget> [
              _buildButton(context, Icons.camera_alt, 'Open the camera', ImageSource.camera),
              SizedBox(width: 0.075.sw),
              _buildText(context, 'Take a picture!'),
            ]
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
            children: <Widget> [
              _buildText(context, 'Select from \n the gallery'),
              SizedBox(width: 0.075.sw),
              _buildButton(context, Icons.photo_library, 'Open the gallery', ImageSource.gallery),
            ]
          ),
        ]
    );
  }

  Widget _buildLoadingWidgets(BuildContext context) {
    bool horizontal = (MediaQuery.of(context).orientation == Orientation.landscape);

    return Column(
      children: <Widget>[
        SizedBox(height: horizontal ? 200.h : 100.h),
        CircularProgressIndicator(),
        SizedBox(height: horizontal ? 100.h : 50.h),
        Text(
            'Processing your image...',
            style: TextStyle(
                fontSize: horizontal ? 20.sp : 40.sp
            )
        ),
      ]
    );
  }
}