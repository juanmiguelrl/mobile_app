import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../providers/request_provider.dart';
import '../providers/tags_provider.dart';

import '../models/client_model.dart' show Tag;

class ResultPage extends StatefulWidget {
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final double _chartSizeFactor = 20;  // adapt depending on the amount of tags

  @override
  Widget build(BuildContext context) {
    Provider.of<RequestProvider>(context, listen: false).reset();
    ScreenUtil.init(context, designSize: Size(1080, 2220), allowFontScaling: true);
    bool horizontal = (MediaQuery.of(context).orientation == Orientation.landscape);

    return Scaffold(
      appBar: AppBar(
          title: Text('Results'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          )
      ),
      body: horizontal ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
              children: <Widget>[
                _buildPhotoWidgets(context),
                _buildSlider(context),
              ]
          ),

          SizedBox(width: 20.w),
          VerticalDivider(
            color: Colors.black,
            thickness: 1.w,
            indent: 40.w,
            endIndent: 40.w,
          ),
          SizedBox(width: 5.w),
          _buildChart(context),
        ]
    ) : Column(
      children: <Widget>[
        _buildPhotoWidgets(context),
        _buildSlider(context),
        _buildChart(context),
      ]
    ),
      /*OrientationBuilder(builder: (_, orientation)
        {
          if (orientation == Orientation.portrait)
            return _portraitView(context);
          else
            return _landscapeView(context);
        }
    )
       */
    );
  }

  Widget _landscapeView(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
              children: <Widget>[
                _buildPhotoWidgets(context),
                _buildSlider(context),
              ]
          ),

          SizedBox(width: 20.w),
          VerticalDivider(
            color: Colors.black,
            thickness: 1.w,
            indent: 40.w,
            endIndent: 40.w,
          ),
          SizedBox(width: 5.w),
          _buildChart(context),
        ]
    );
  }

  Widget _portraitView(BuildContext context) {
    return Column(
        children: <Widget>[
          _buildPhotoWidgets(context),
          _buildSlider(context),
          _buildChart(context),
        ]
    );
  }

  Widget _buildPhotoWidgets(BuildContext context) {
    bool horizontal = (MediaQuery.of(context).orientation == Orientation.landscape);

    return IntrinsicHeight(child: Column(
      children: <Widget> [
        horizontal ? SizedBox(height: 50.w) : SizedBox(height: 50.h),
        FittedBox(
            fit: BoxFit.fitWidth,
            child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 1,
                  minHeight: 1,
                  maxHeight: horizontal ? MediaQuery.of(context).size.height / 2.5 : 500.h,
                  //maxWidth: horizontal ? 0.4.sw : 400,
                ),
                child: Image(
                  image: FileImage(Provider.of<RequestProvider>(context, listen: false).file),
                )
            )
        ),

        SizedBox(height: 20.h),
        Divider(
          color: Colors.black,
          thickness: 1.w,
          indent: 0.1.sw,
          endIndent: 0.1.sw,
        ),
        SizedBox(height: 40.h),
      ]
    ));
  }

  Widget _buildSlider(BuildContext context) {
    bool horizontal = (MediaQuery.of(context).orientation == Orientation.landscape);

    return Column(
      children: <Widget> [
        Text(
          'Confidence level',
          style: TextStyle(
            fontSize: horizontal ? 40.sp : 60.sp
          )
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackShape: RoundedRectSliderTrackShape(),
            trackHeight: 10.h,
            valueIndicatorShape: PaddleSliderValueIndicatorShape(),
          ),
          child: Slider(
            value: context.watch<TagsProvider>().confidence,
            min: 5,
            max: 80,
            divisions: 80,
            label: '${context.watch<TagsProvider>().confidence.round().toString()}%',
            onChanged: (double value) => Provider.of<TagsProvider>(context, listen: false).filterByConfidence(value),
          ),
        )
      ]
    );
  }

  Widget _buildChart(BuildContext context) {
    bool horizontal = (MediaQuery.of(context).orientation == Orientation.landscape);

    return SizedBox(
      height: horizontal ? null : MediaQuery.of(context).size.height * 0.4,
      width: horizontal ? 0.5.sw : MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 0.4.sh + _chartSizeFactor * context.watch<TagsProvider>().filteredList.length,
              child: Consumer<TagsProvider>(
                builder: (context, provider, child) {
                  return Stack(
                    children: <Widget> [
                      charts.BarChart(
                        [
                          charts.Series<Tag, String>(
                              id: 'Tags confidence',
                              domainFn: (Tag tags, _) => tags.tagName,
                              measureFn: (Tag tags, _) => tags.confidence,
                              data: provider.filteredList,
                              colorFn: (Tag tag, _) {
                                var secondaryColor = Theme.of(context).accentColor;
                                return charts.Color(r: secondaryColor.red, g: secondaryColor.green, b: secondaryColor.blue, a: 255);
                              }
                          ),
                        ],
                        animate: true,
                        vertical: false,
                        // Put the domain text above the graphic
                        barRendererDecorator: charts.BarLabelDecorator<String>(),
                        // Hide the domain axis
                        domainAxis: charts.OrdinalAxisSpec(renderSpec: charts.NoneRenderSpec()),
                      ),
                      if (provider.filteredList.length < 1)
                         Center(
                           child: Text(
                            'No tags with that level of confidence.\nTry to reduce the threshold with the slider',
                            style: TextStyle(
                              fontSize: 40.sp
                            )
                           )
                         )
                    ]
                  );

                }
              ),
            )
          ]
        )
      )
    );
  }

}