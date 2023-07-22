// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:eagler/services/request_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

const String defaultExtractorPath = 'body.content';

@pragma('vm:entry-point')
backgroundAlarmCallback() {
  // push notification to UI from background isolate
  SendPort? uiSendPort = IsolateNameServer.lookupPortByName('notify');
  uiSendPort?.send(null);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  late SharedPreferences? prefs;
  String defaultUrl = 'https://api.quotable.io/random';
  String token = '';
  String url = '';
  String extractorPath = defaultExtractorPath;
  String response = '';
  String pathValidatorString = '';
  bool recurring = false;
  Timer? task;
  String condition = '0';
  dynamic conditionThresholdValue = 0;

  startRequestTimer(appState, context) async {
    await AndroidAlarmManager.periodic(
        Duration(seconds: 60), 0, backgroundAlarmCallback,
        wakeup: true, rescheduleOnReboot: true, allowWhileIdle: true);

    // Create port to receive messages from alarm timer isolate
    ReceivePort rcPort = ReceivePort();
    IsolateNameServer.registerPortWithName(rcPort.sendPort, 'notify');

    rcPort.listen((v) {
      // listen for background alarm timer isolate messages
      makeRequest(appState, context);
    });
  }

  void updateRecurringState(bool state, appState, context) {
    if (state) {
      startRequestTimer(appState, context);
    } else {
      AndroidAlarmManager.cancel(0);
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

  initializeData() async {
    AndroidAlarmManager.initialize();

    prefs = await SharedPreferences.getInstance();
    prefs?.getString('url') ?? prefs?.setString('url', defaultUrl);
    prefs?.getString('extractorPath') ??
        prefs?.setString('extractorPath', defaultExtractorPath);
    prefs?.getString('token') ?? prefs?.setString('token', "");
  }
}
