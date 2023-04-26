// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:async';

import 'package:eagler/services/request_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login.dart';

String defaultExtractorPath = 'body.content';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Eagler App',
        theme: ThemeData(
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: Size(400, 100),
          )),
          useMaterial3: false,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
          ),
        ),
        home: LoginPage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  String token = '';
  String url = '';
  String extractorPath = defaultExtractorPath;
  String response = '';
  String pathValidatorString = '';
  bool recurring = false;
  Timer? task;

  void startRequestTimer(appState) {
    task = Timer.periodic(Duration(seconds: 60), (timer) async {
      makeRequest(appState);
    });
  }

  void updateRecurringState(bool state, appState) {
    if (state) {
      startRequestTimer(appState);
    } else {
      task?.cancel();
    }

    recurring = state;
    notifyListeners();
  }

  void updatePathValidatorText(String errorText) {
    pathValidatorString = errorText;
    notifyListeners();
  }

  void updateResponseText(response) {
    if (response is num) {
    } else if (response.length > 600) {
      response = response.substring(0, 1000) +
          '...\n\n\n'
              'response was limited to 1000 characters';
    }
    this.response = response.toString();
    notifyListeners();
  }
}
