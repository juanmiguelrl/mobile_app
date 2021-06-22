import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:async';

import '../models/client_model.dart';

enum RequestStatus { PROCESSING, SUCCESS, ERROR }

class RequestProvider with ChangeNotifier {
  File _file;
  RequestStatus _status;
  List<Tag> _tags;
  Map<String,String> _errorStatus = {'name' : '', 'msg' : ''};

  File get file => _file;
  List<Tag> get tags => _tags;
  RequestStatus get status => _status;
  Map<String,String> get error => _errorStatus;

  void reset() => _status = null;

  void _updateStatus(RequestStatus status, String errorName, String errorMsg) {
    if (status == _status)
      return;

    _status = status;
    _errorStatus['name'] = errorName;
    _errorStatus['msg'] = errorMsg;
    notifyListeners();
  }

  void fetchResult(File file) async {
    try {
      _file = file;

      _updateStatus(RequestStatus.PROCESSING, '', '');
      Response response = await ClientModel.fetchResult(file);
      _updateStatus(RequestStatus.SUCCESS, '', '');

      _tags = response.tags;

    } on TimeoutException catch (e) {
      _updateStatus(RequestStatus.ERROR, 'Timeout expired', 'Check your internet coverage');
    } on SocketException catch (e) {
      _updateStatus(RequestStatus.ERROR, 'Socket exception', 'Cannot establish a connection');
    } on Exception catch (e) {
      _updateStatus(RequestStatus.ERROR, 'Fatal error', e.toString().split(':')[1]);
      print("Error fetching the result: $e");
    }
  }
}









