import 'dart:async';
import 'dart:convert';
import 'package:eagler/services/request_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'constants.dart' as constants;

String defaultUrl = constants.defaultUrl;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Timer debounce = Timer(Duration(milliseconds: 0), () {});
    const int delayTime = 500; // in milliseconds
    var appState = context.watch<MyAppState>();

    var content = Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(height: 40),
        Text('Welcome to Eagler!',
            style: Theme.of(context).textTheme.headlineMedium),
        SizedBox(height: 20),
        SizedBox(
          width: 400,
          child: Text('Enter a url that returns a JSON response. '
              'You can define an path the the data you want to alert on. '
              'If the condition is met, '
              'the app will alert you with a local notification. '
              'The recurring option will send a request once a minute.'),
        ),
        SizedBox(height: 20),
        TextField(
          onChanged: (value) {
            if (value != '') {
              appState.prefs?.setString('url', value);
            } else {
              appState.prefs?.setString('url', defaultUrl);
            }
          },
          maxLines: 3,
          decoration: InputDecoration(
            hintText: appState.prefs?.getString('url'),
            constraints: BoxConstraints(maxWidth: 400),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            labelText: 'Http URL',
            border: Theme.of(context).inputDecorationTheme.border,
          ),
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: () async {
            makeRequest(appState, context);
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
            Flexible(
              fit: FlexFit.loose,
              child: TextField(
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
                      appState.prefs?.setString('extractorPath', value);
                      appState.updatePathValidatorText('');
                    }
                  });
                },
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: appState.prefs?.getString('extractorPath'),
                  errorText: appState.pathValidatorString.isNotEmpty
                      ? appState.pathValidatorString
                      : null,
                  errorMaxLines: 5,
                  helperText:
                      'Default url: ${jsonEncode(defaultExtractorPath)}',
                  constraints: BoxConstraints(maxWidth: 350),
                  helperMaxLines: 10,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  labelText: 'Extractor Path',
                  border: Theme.of(context).inputDecorationTheme.border,
                ),
              ),
            ),
            SizedBox(width: 10),
            ConditionDropdownMenu(),
            SizedBox(width: 10),
            TextField(
              onChanged: (value) {
                if (value != '' && int.tryParse(value) is int) {
                  appState.conditionThresholdValue =
                      int.parse(value).toDouble();
                } else if (value != '' && double.tryParse(value) is double) {
                  appState.conditionThresholdValue = double.parse(value);
                } else if (value != '') {
                  appState.conditionThresholdValue = value;
                } else {
                  appState.conditionThresholdValue = 0;
                }
                appState.prefs
                    ?.setDouble('threshold', appState.conditionThresholdValue);
              },
              maxLines: 1,
              decoration: InputDecoration(
                hintText: appState.conditionThresholdValue.toString(),
                constraints: BoxConstraints(maxWidth: 75),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                labelText: 'Threshold',
                border: Theme.of(context).inputDecorationTheme.border,
              ),
            ),
            SizedBox(width: 5),
            Column(
              children: [
                Text('Recurring'),
                Switch(
                  activeColor: Theme.of(context).colorScheme.primary,
                  value: appState.recurring,
                  onChanged: (bool value) {
                    appState.updateRecurringState(value, appState, context);
                    appState.prefs?.setBool('recurring', value);
                  },
                ),
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
                    child: Text('URL:\n\n${appState.prefs?.getString('url')}')),
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

    return Center(
      child: SingleChildScrollView(
          child: Container(
        padding: EdgeInsets.all(20),
        child: content,
      )),
    );
  }
}

class ConditionDropdownMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Flexible(
      fit: FlexFit.loose,
      child: DropdownMenu(
        trailingIcon: Icon(Icons.arrow_drop_down, size: 15),
        inputDecorationTheme: Theme.of(context).inputDecorationTheme,
        label: Text('Condition', style: TextStyle()),
        width: 75,
        dropdownMenuEntries: [
          DropdownMenuEntry(value: '0', label: ' ', enabled: true),
          DropdownMenuEntry(value: '>', label: '>', enabled: true),
          DropdownMenuEntry(value: '<', label: '<', enabled: true),
          DropdownMenuEntry(value: '=', label: '=', enabled: true),
          DropdownMenuEntry(value: 'includes', label: 'includes', enabled: true)
        ],
        initialSelection: appState.condition,
        menuStyle: Theme.of(context).dropdownMenuTheme.menuStyle,
        onSelected: (label) {
          appState.updateCondition(label.toString());
          appState.prefs?.setString('condition', label.toString());
        },
      ),
    );
  }
}
