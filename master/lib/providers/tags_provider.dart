import 'package:flutter/material.dart';

import '../models/client_model.dart';
import 'request_provider.dart';

class TagsProvider with ChangeNotifier {
  final double _defaultConfidence = 50;

  RequestProvider requestProvider;

  List<Tag> _filteredList;
  double _confidenceValue;

  TagsProvider(this.requestProvider) {
    filterByConfidence(_defaultConfidence);  // default confidence
  }

  get filteredList => _filteredList;
  get confidence => _confidenceValue;

  void filterByConfidence(double confidence) {
    if (confidence == _confidenceValue)
      return;
    _confidenceValue = confidence;

    var _newList = requestProvider.tags.where((e) => e.confidence >= confidence).toList();
    if (_newList != _filteredList) {
      _filteredList = _newList;
      notifyListeners();
    }
  }
}