import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'login.dart';
import 'main.dart';

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
        page = RequesterPage();
        break;
      case 1:
        appState.token = '';
        appState.response = '';
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
    var appState = context.watch<MyAppState>();

    var content = Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('Welcome to Eagler!'),
        SizedBox(height: 20),
        TextField(
          onChanged: (value) {
            appState.url = value;
          },
          maxLines: 3,
          decoration: InputDecoration(
            constraints: BoxConstraints(maxWidth: 400),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            labelText: 'Http URL',
            border: OutlineInputBorder(gapPadding: 2),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
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
                print(response.body);
                // f below parses a json response for a specific API, left here for debugging.
                // Object f = jsonDecode(response.body)[0]['entries'].values.first;
                appState.updateResponseText(response.body);
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
          height: 20,
        ),
        Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            border: Border(
              top: BorderSide(),
              left: BorderSide(),
              right: BorderSide(),
              bottom: BorderSide(),
            ),
          ),
          constraints: BoxConstraints(maxWidth: 400),
          padding: EdgeInsets.all(10),
          child: Text(appState.response),
        ),
      ]),
    );

    return Container(child: content);
  }
}
