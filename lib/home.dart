import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'login.dart';
import 'main.dart';
import 'services/response_extractor.dart';

String defaultUrl = 'https://api.quotable.io/random';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (selectedIndex) {
      case 0:
        if (appState.url == '') {
          appState.url = defaultUrl;
        }
        page = RequesterPage();
        break;
      case 1:
        appState.token = '';
        appState.response = 'Waiting for request...';
        appState.url = '';
        page = LoginPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    // The container for the current page, with its background color
    // and subtle switching animation.
    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );
    // Check if the current page is the login page
    var isLoginPage = page is LoginPage;

    // Conditionally render the navbar
    var sidebar = isLoginPage
        ? null
        : BottomAppBar(
            child: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.logout),
                  label: 'Logout',
                ),
              ],
              currentIndex: selectedIndex,
              onTap: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          );

    return Scaffold(
      body: Row(
        children: [
          //Container(child: sidebar),
          Expanded(child: mainArea),
        ],
      ),
      bottomNavigationBar: sidebar,
    );
  }
}

class RequesterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Timer debounce = Timer(Duration(milliseconds: 0), () {});
    const int delayTime = 1000; // in milliseconds
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
                dynamic extractedValue = extractValue(
                    jsonDecode(response.body), appState.extractorSchema);
                if (extractedValue != null) {
                  appState.updateResponseText('$extractedValue');
                } else {
                  appState.updateResponseText(
                      'The parser could not find a value for the schema:\n\n'
                      '${jsonEncode(appState.extractorSchema)}');
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
        TextField(
          onEditingComplete: () => {},
          onChanged: (value) {
            debounce.cancel();
            debounce = Timer(Duration(milliseconds: delayTime), () {
              try {
                appState.extractorSchema = (jsonDecode(value));
                appState.updateSchemaValidatorText('');
              } catch (e) {
                appState.extractorSchema = defaultExtractorSchema;
                appState.updateSchemaValidatorText('Invalid schema: $e');
              }
            });
          },
          maxLines: 3,
          decoration: InputDecoration(
            errorText: appState.schemaValidatorString.isNotEmpty
                ? appState.schemaValidatorString
                : null,
            errorMaxLines: 4,
            helperText: 'Default: ${jsonEncode(defaultExtractorSchema)}'
                '\n\n'
                'The extractor schema helps you parse JSON responses. '
                'Documentation should go here in the future.',
            constraints: BoxConstraints(maxWidth: 400),
            helperMaxLines: 5,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            labelText: 'Extractor Schema',
            border: OutlineInputBorder(gapPadding: 2),
          ),
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
                    child: Text('Response:\n\n${appState.response}')),
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
