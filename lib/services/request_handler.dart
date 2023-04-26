import 'dart:convert';

import 'package:eagler/services/response_extractor.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

makeRequest(appState) async {
  dynamic extractedValue;
  try {
    Response response;
    if (appState.token != '') {
      response = await http.get(Uri.parse(appState.url), headers: {
        "Authorization": 'Bearer ${appState.token}',
      });
    } else {
      response = await http.get(Uri.parse(appState.url));
    }

    if (response.statusCode == 200) {
      extractedValue =
          extractValueFromResponse(response, appState.extractorPath);

      if (extractedValue is String || extractedValue is num) {
        appState.updateResponseText(extractedValue);
      } else if (extractedValue != null) {
        appState.updateResponseText(jsonEncode(extractedValue));
      } else {
        appState.updateResponseText(
            'The parser could not find a value for the path:\n\n'
            '${jsonEncode(appState.extractorPath)}');
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