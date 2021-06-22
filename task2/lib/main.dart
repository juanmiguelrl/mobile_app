import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/request_provider.dart' show RequestProvider;
import 'providers/tags_provider.dart' show TagsProvider;
import 'screens/home_screen.dart';

void main() => runApp(PhotoTaggingApp());

class PhotoTaggingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RequestProvider>(
          create: (_) => RequestProvider()
        ),
        ChangeNotifierProxyProvider<RequestProvider, TagsProvider>(
          create: (context) => TagsProvider(context.read<RequestProvider>()),
          update: (context, request, tags) => TagsProvider(request),
        ),
      ],
      child: MaterialApp(
        title: 'PhotoTaggingApp',
        theme: ThemeData(
          primarySwatch: Theme.of(context).primaryColor,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: {
          '/': (_) => HomeScreen(),
        }
      ),
    );
  }
}