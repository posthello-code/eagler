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
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            isDense: true,
            labelStyle: TextStyle(
              color: Colors.black,
              fontSize: 12,
            ),
            floatingLabelAlignment: FloatingLabelAlignment.start,
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          dropdownMenuTheme: DropdownMenuThemeData(
            textStyle: TextStyle(
              height: 1.6,
              color: Colors.black,
              fontSize: 12,
            ),
          ),
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

  String condition = '0';
  int conditionThresholdValue = 0;

  void startRequestTimer(appState, context) {
    task = Timer.periodic(Duration(seconds: 60), (timer) async {
      makeRequest(appState, context);
    });
  }

  void updateRecurringState(bool state, appState, context) {
    if (state) {
      startRequestTimer(appState, context);
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

  updateCondition(String newCondition) {
    condition = newCondition;
    notifyListeners();
  }
}
