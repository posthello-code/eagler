// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:eagler/services/request_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'constants.dart' as constants;

const String defaultExtractorPath = 'body.profiles';

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
  late bool recurring;
  late String condition;
  String defaultUrl = constants.defaultUrl;
  String token = '';
  String url = '';
  String extractorPath = defaultExtractorPath;
  String response = '';
  String pathValidatorString = '';
  Timer? task;
  dynamic conditionThresholdValue; // int or double

  startRequestTimer(appState, context) async {
    defaultTimer() {
      task = Timer.periodic(Duration(seconds: 60), (timer) {
        makeRequest(appState, context);
      });
    }

    if (kIsWeb) {
      // dumb thing to fix bug where isPlatform doesn't work on web
      defaultTimer();
    } else if (Platform.isAndroid) {
      AndroidAlarmManager.periodic(
          Duration(seconds: 60), 0, backgroundAlarmCallback,
          wakeup: true, rescheduleOnReboot: true, allowWhileIdle: true);

      // Create port to receive messages from alarm timer isolate
      ReceivePort rcPort = ReceivePort();
      IsolateNameServer.registerPortWithName(rcPort.sendPort, 'notify');

      rcPort.listen((v) {
        // listen for background alarm timer isolate messages
        makeRequest(appState, context);
      });
    } else {
      defaultTimer();
    }
  }

  void updateRecurringState(bool state, appState, context) {
    if (state) {
      startRequestTimer(appState, context);
    } else {
      if (kIsWeb) {
        // dumb thing to fix bug where isPlatform doesn't work on web
        task?.cancel();
      } else if (Platform.isAndroid) {
        AndroidAlarmManager.cancel(0);
      } else {
        task?.cancel();
      }
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
    prefs?.getString('token') ?? prefs?.setString('token', ' ');
    prefs?.getString('condition') ?? prefs?.setString('condition', ' ');
    prefs?.getBool('recurring') ?? prefs?.setBool('recurring', false);
    prefs?.getDouble('threshold') ?? prefs?.setDouble('threshold', 0);

    condition = prefs!.getString('condition')!;
    conditionThresholdValue = prefs!.getDouble('threshold')!;
    recurring = prefs!.getBool('recurring')!;
  }
}
