import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'main.dart';
import 'services/response_extractor.dart';

String defaultUrl = 'https://api.quotable.io/random';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Timer debounce = Timer(Duration(milliseconds: 0), () {});
    const int delayTime = 500; // in milliseconds
    var appState = context.watch<MyAppState>();

    var content = Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('Welcome to Eagler!',
            style: Theme.of(context).textTheme.headlineMedium),
        SizedBox(height: 20),
        SizedBox(
          width: 400,
          child: Text(
              'This is where you put a url. In the future you will be able to '
              'make requests on a schedule, and other fancy things.'),
        ),
        SizedBox(height: 20),
        TextField(
          onChanged: (value) {
            if (value != '') {
              appState.url = 'https://$value';
            } else {
              appState.url = defaultUrl;
            }
          },
          maxLines: 3,
          decoration: InputDecoration(
            prefixText: 'https://',
            helperText: 'Default: $defaultUrl',
            constraints: BoxConstraints(maxWidth: 400),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            labelText: 'Http URL',
            border: OutlineInputBorder(gapPadding: 2),
          ),
        ),
        SizedBox(height: 30),
        ElevatedButton(
          style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(Size(400, 100)),
          ),
          onPressed: () async {
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
                dynamic extractedValue =
                    extractValueFromResponse(response, appState.extractorPath);
                print('extractedValue $extractedValue');

                if (extractedValue is String || extractedValue is num) {
                  appState.updateResponseText(extractedValue);
                } else if (extractedValue != null) {
                  print(extractedValue.runtimeType);
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
          },
          child: Text('Send'),
        ),
        SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onEditingComplete: () => {},
              onChanged: (value) {
                debounce.cancel();
                debounce = Timer(Duration(milliseconds: delayTime), () {
                  if (value.endsWith('.') ||
                      value.contains(' ') ||
                      value.endsWith(' ')) {
                    appState.updatePathValidatorText('Invalid path');
                  } else if (!value.split('.')[0].contains('body') ||
                      !(value.split('.')[0].contains('body'))) {
                    appState
                        .updatePathValidatorText('Must begin with "body" or '
                            '"body[i]"');
                  } else {
                    appState.extractorPath = value;
                    appState.updatePathValidatorText('');
                  }
                });
              },
              maxLines: 1,
              decoration: InputDecoration(
                errorText: appState.pathValidatorString.isNotEmpty
                    ? appState.pathValidatorString
                    : null,
                errorMaxLines: 5,
                helperText: 'Default: ${jsonEncode(defaultExtractorPath)}'
                    '\n\n'
                    'Example:\n'
                    'body.content would return "a profound quote" from the JSON below\n\n'
                    '{ "content": "a profound quote" }',
                constraints: BoxConstraints(maxWidth: 350),
                helperMaxLines: 10,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                labelText: 'Extractor Path',
                border: OutlineInputBorder(gapPadding: 2),
              ),
            ),
            SizedBox(width: 20),
            Column(
              children: [
                Text('Recurring'),
                Switch(
                  activeColor: Theme.of(context).colorScheme.primary,
                  value: appState.recurring,
                  onChanged: (bool value) {
                    appState.updateRecurringState(value);
                  },
                )
              ],
            ),
          ],
        ),
        SizedBox(height: 30),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          padding: EdgeInsets.all(10),
          child: SizedBox(
            width: 400,
            child: Column(
              children: [
                Container(
                    alignment: Alignment.centerLeft,
                    child: Text('URL:\n\n${appState.url}')),
                SizedBox(height: 20),
                Container(
                    alignment: Alignment.centerLeft,
                    child: Text('Extracted Text:\n\n${appState.response}')),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
      ]),
    );

    return Container(child: content);
  }
}
