import 'dart:convert';
import 'package:eagler/services/local_notifications.dart';
import 'package:eagler/services/response_extractor.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter, using this only for web

triggerAlert(appState, context) {
  String alertMsg =
      'Alert condition triggered! Value ${appState.condition.toString()} ${appState.conditionThresholdValue.toString()}';
  SnackBar snackBar = SnackBar(
    content: Text(alertMsg),
  );
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
  if (kIsWeb) {
    sendWeb(alertMsg);
  } else {
    send(alertMsg);
  }
}

makeRequest(appState, context) async {
  dynamic extractedValue;
  String url = appState.prefs?.getString('url');
  String token = appState.prefs?.getString('token');
  String extractorPath = appState.prefs?.getString('extractorPath');

  try {
    Response response;
    if (appState.prefs?.getString('token') != '') {
      response = await http.get(Uri.parse(url), headers: {
        "Authorization": 'Bearer $token',
      });
    } else {
      response = await http.get(Uri.parse(url));
    }

    if (response.statusCode == 200) {
      extractedValue = extractValueFromResponse(
        response,
        extractorPath,
      );

      if (extractedValue is String || extractedValue is num) {
        appState.updateResponseText(extractedValue);
      } else if (extractedValue != null) {
        appState.updateResponseText(jsonEncode(extractedValue));
      } else {
        appState.updateResponseText(
            'The parser could not find a value for the path:\n\n'
            '${jsonEncode(extractorPath)}');
      }

      if (appState.condition.toString() == '>' &&
          double.tryParse(appState.response) is double &&
          double.parse(appState.response) > appState.conditionThresholdValue) {
        triggerAlert(appState, context);
      } else if (appState.condition.toString() == '<' &&
          double.tryParse(appState.response) is double &&
          double.parse(appState.response) < appState.conditionThresholdValue) {
        triggerAlert(appState, context);
      } else if (appState.condition.toString() == '=' &&
          appState.response.toString() ==
              appState.conditionThresholdValue.toString()) {
        triggerAlert(appState, context);
      } else if (appState.condition.toString() == 'includes' &&
          appState.response
              .toString()
              .contains(appState.conditionThresholdValue.toString())) {
        triggerAlert(appState, context);
      } else {
        SnackBar snackBar = SnackBar(
          content: Text('Requested new data, alert condition not met'),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      appState.updateResponseText(response.body);
      appState.updateResponseText(
          'Request failed with status: ${response.statusCode}.');
    }
  } catch (e) {
    appState.updateResponseText('Error: $e');
  }
}
