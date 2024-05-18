// ignore_for_file: prefer_typing_uninitialized_variables
// stub for conditional import of html.dart, required so that non web versions
// continue to compile.
class Notification {
  static var permission;

  Notification(String s, {required String body});

  static requestPermission() {}
}
