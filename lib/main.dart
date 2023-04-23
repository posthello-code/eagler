// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login.dart';

String defaultExtractorPath = 'body.content';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Eagler App',
        theme: ThemeData(
          useMaterial3: false,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
