//Login page for the app
import 'package:eagler/main.dart';
import 'package:eagler/page_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  // login button widget
  Widget loginButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton(
        style: Theme.of(context).elevatedButtonTheme.style,
      onPressed: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => PageLoader()),
        );
      },
      child: Text('Login'),
      ),
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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Eagler',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            SizedBox(height: 40),
            tokenInput(context),
            SizedBox(height: 20),
            loginButton(context),
            SizedBox(height: 30),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox(
              width: 400,
              child: Text(
                  'Eagler can make an API request for you. You can provide '
                  'a bearer token if you need to. Or just press the button to '
                  'continue'),
            ),
                      ),
          ],
        ),
      ),
    );
  }
}
