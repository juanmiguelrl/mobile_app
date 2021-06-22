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
    ScreenUtil.init(context, designSize: Size(1080, 2220), allowFontScaling: true);

    return Scaffold(
      appBar: AppBar(
          title: Text('Results')
      ),
      body: SingleChildScrollView(
          child: Column(
              children: <Widget>[
                _buildStaticWidgets(context),

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
                ),

                SizedBox(
                  child: Consumer<TagsProvider>(
                    builder: (context, provider, child) {
                      if (provider.filteredList.length < 1)
                        return Text(
                          'No tags with that level of confidence.\nTry to reduce the threshold with the slider',
                          style: TextStyle(
                              fontSize: 40.sp
                          )
                        );
                      else {
                        return charts.BarChart(
                          [
                            charts.Series<Tag, String>(
                              id: 'Tags confidence',
                              domainFn: (Tag tags, _) => tags.tagName,
                              measureFn: (Tag tags, _) => tags.confidence,
                              data: provider.filteredList,
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
                  ),
                  height: 256.h + _chartSizeFactor * context.watch<TagsProvider>().filteredList.length,
                )
              ]
          )
      ),
    );
  }

  Widget _buildStaticWidgets(BuildContext context) {
    return Column(
      children: <Widget> [
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
                  image: FileImage(Provider.of<RequestProvider>(context, listen: false).file),
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
      ]
    );
  }
}