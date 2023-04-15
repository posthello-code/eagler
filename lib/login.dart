//Login page for the app
import 'package:eagler/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home.dart';

class LoginPage extends StatelessWidget {
  // login button widget
  Widget loginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      },
      child: Text('Login'),
    );
  }

  Widget tokenInput(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return TextFormField(
      onChanged: (value) {
        appState.token = value;
      },
      decoration: InputDecoration(
        constraints: BoxConstraints(maxWidth: 300),
        contentPadding: EdgeInsets.all(10),
        labelText: 'Token',
        border: OutlineInputBorder(gapPadding: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Eagler',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
            tokenInput(context),
            SizedBox(height: 20),
            loginButton(context),
            SizedBox(height: 30),
            SizedBox(
              width: 400,
              child: Text(
                  'Eagler can make an API request for you. You can provide '
                  'a bearer token if you need to. Or just press the button to '
                  'continue'),
            ),
          ],
        ),
      ),
    );
  }
}
