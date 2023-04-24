import 'dart:convert';
import 'package:http/http.dart';

/// Returns a value from a JSON response based on the user provided path.
dynamic extractValueFromResponse(Response response, String path) {
  dynamic body = response.body;
  return traverseJsonObject(body, path);
}

// function to parse the body recursively
dynamic traverseJsonObject(dynamic body, String path) {
  print(body);
  print(path);
  List<String> properties = path.split('.');

  if (properties.length == 1) {
    if (properties[0].contains('body[')) {
      // return selected item when the path is body[i]
      int index = int.parse(properties[0].split('[')[1].split(']')[0]);
      return jsonDecode(body)[index];
    } else if (properties[0].contains('[')) {
      // return the selected item of array[i] when there's only one property left
      return body;
    } else if (properties[0] == 'first') {
      // return first item in "values"
      return body;
    } else if (body is num) {
      return body;
    } else if (body[0] == '{' && properties[0] != 'body') {
      // return objects when there's only one property left
      return jsonDecode(body);
    } else if (properties[0] != 'body') {
      // return value when there's only one property left
      return body;
    } else {
      // default also handles when path == 'body'
      return body;
    }
  } else {
    // necessary to remove first property if calling traversing JSON recursively
    path = removeFirstPropertyFromPath(path);
    if (properties[0].contains('[') && properties[1].contains('[')) {
      // handle body[]
      int index = int.parse(properties[0].split('[')[1].split(']')[0]);
      String nextProperty = properties[1].split('[')[0];
      // find selected item in array, and return the next property in path
      Map selectedItem = jsonDecode(body)[index];
      body = selectedItem[nextProperty];
      return traverseJsonObject(body, path);
    } else if (properties[0].contains('[')) {
      // handle body[]
      int index = int.parse(properties[0].split('[')[1].split(']')[0]);

      if (body is String) {
        body = json.decode(body)[index][properties[1]];
      } else if (body is Map) {
        body = body[properties[1]];
      } else {
        body = body[index][properties[1]];
      }

      return traverseJsonObject(body, path);
    } else if (properties[1].contains('[')) {
      // handle lists
      String arrayProp = properties[1].split('[')[0];
      int index = int.parse(properties[1].split('[')[1].split(']')[0]);
      body = jsonDecode(body)[arrayProp][index];
      if (body is int) {
        body = body.toString();
      }
      return traverseJsonObject(body, path);
    } else if (properties[1] == 'values') {
      return traverseJsonObject(body.values.toList(), path);
    } else if (properties[1] == 'first') {
      return traverseJsonObject(body.first, path);
    } else {
      body;
      if (body is String) {
        body = json.decode(body)[properties[1]];
      } else {
        body = body[properties[1]];
      }

      if (body is Map<String, dynamic> || body is List<dynamic>) {
        body = json.encode(body);
      }
      if (body is int) {
        body = body.toString();
      }
      return traverseJsonObject(body, path);
    }
  }
}

String removeFirstPropertyFromPath(String path) {
  if (path.contains('.')) {
    return path.substring(path.indexOf('.') + 1, path.length);
  } else {
    return path;
  }
}
