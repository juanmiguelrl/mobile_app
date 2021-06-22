import 'dart:io';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'client.dart' show Tag;

class ResultPage extends StatefulWidget {
  final File pickedFile;
  final List<Tag> tagsList;

  final double defaultConfidenceValue = 50.00;
  final double _chartSizeFactor = 20;  // adapt depending on the amount of tags
  
  ResultPage({Key key, this.pickedFile, this.tagsList}): super(key: key);

  _ResultPageState createState() => _ResultPageState(defaultConfidenceValue);
}

class _ResultPageState extends State<ResultPage> {
  double _currentConfidenceValue;
  double _heightChartBox;

  _ResultPageState(this._currentConfidenceValue);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(1080, 2220), allowFontScaling: true);

    return Scaffold(
      appBar: AppBar(
          title: Text('Results')
      ),
      body: SingleChildScrollView(
          child: Column(
              children: <Widget>[
                SizedBox(height: 60.h),
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 1,
                        minHeight: 1,
                        maxHeight: 500.h
                      ),
                      child: Image(
                        image: FileImage(widget.pickedFile)
                      )
                  )
                ),
                SizedBox(height: 20.h),
                Divider(
                  color: Colors.black,
                  thickness: 2.h,
                  indent: 0.1.sw,
                  endIndent: 0.1.sw,
                ),
                SizedBox(height: 40.h),
                Text(
                  'Confidence level',
                  style: TextStyle(
                    fontSize: 60.sp
                  )
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackShape: RoundedRectSliderTrackShape(),
                    trackHeight: 10.h,
                    valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                  ),
                  child: Slider(
                    value: _currentConfidenceValue,
                    min: 5,
                    max: 80,
                    divisions: 80,
                    label: '${_currentConfidenceValue.round().toString()}%',
                    onChanged: (double value) {
                      setState(() {
                        _currentConfidenceValue = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  child: _createChart(),
                  height: _heightChartBox,
                )
              ]
          )
      ),
    );
  }

  Widget _createChart() {
    var filteredList = widget.tagsList.where((e) => e.confidence >= _currentConfidenceValue).toList();
    int lengthList = filteredList.length;
    _heightChartBox = 256.h + widget._chartSizeFactor * lengthList;

    if (lengthList < 1)
      return Text(
        'No tags with that level of confidence.\nTry to reduce the threshold with the slider',
        style: TextStyle(
          fontSize: 40.sp
        )
      );
    else
      return charts.BarChart(
        [
          charts.Series<Tag, String>(
            id: 'Tags confidence',
            domainFn: (Tag tags, _) => tags.tagName,
            measureFn: (Tag tags, _) => tags.confidence,
            data: widget.tagsList.where((e) => e.confidence >= _currentConfidenceValue).toList(),
          ),
        ],
        animate: true,
        vertical: false,
        // Put the domain text above the graphic
        barRendererDecorator: charts.BarLabelDecorator<String>(),
        // Hide the domain axis
        domainAxis: charts.OrdinalAxisSpec(renderSpec: charts.NoneRenderSpec()),
      );
  }
}