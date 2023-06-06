import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home.dart';
import 'login.dart';
import 'main.dart';

class PageLoader extends StatefulWidget {
  @override
  State<PageLoader> createState() => _PageLoaderState();
}

class _PageLoaderState extends State<PageLoader> {
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
        page = HomePage();
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
      color: colorScheme.primaryContainer,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );
    // Check if the current page is the login page
    var isLoginPage = page is LoginPage;

    // Conditionally render the navbar
    var navbar = isLoginPage
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
      appBar: AppBar(
        title: const Text('Eagler'),
      ),
      body: Row(
        children: [
          Expanded(child: mainArea),
        ],
      ),
      bottomNavigationBar: navbar,
    );
  }
}
