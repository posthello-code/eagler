import 'dart:convert';
import 'package:http/http.dart';

/// Returns a value from a JSON response based on the user provided path.
dynamic extractValueFromResponse(Response response, String path) {
  dynamic body = response.body;
  return traverseJsonObject(body, path);
}

// function to parse the body recursively
dynamic traverseJsonObject(dynamic body, String path) {
  List<String> properties = path.split('.');

  if (properties.length == 1) {
    if (properties[0].contains('body[')) {
      // get the index of the item in the body[i] array
      int index = int.parse(properties[0].split('[')[1].split(']')[0]);
      return jsonDecode(body)[index];
    } else if (body is String && body[0] == '{' && properties[0] != 'body') {
      // return objects when there's only one property left in the path
      return jsonDecode(body);
    } else {
      // return the value of the last property in the path
      return body;
    }
  }
  // handle when there is more than one property in the path
  else {
    // necessary to remove first property if calling traversing JSON recursively
    path = removeFirstPropertyFromPath(path);
    if (properties[0].contains('[') && properties[1].contains('[')) {
      // handle whent the next two properties are lists
      int index = int.parse(properties[0].split('[')[1].split(']')[0]);
      String nextProperty = properties[1].split('[')[0];
      // find selected item in list, and return the next property in path
      Map selectedItem = jsonDecode(body)[index];
      body = selectedItem[nextProperty];
      return traverseJsonObject(body, path);
    } else if (properties[0].contains('[')) {
      // handle when the list is the first property in the path,
      // and the next property is not a list
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
      // handle object property is a list
      String arrayProp = properties[1].split('[')[0];
      int index = int.parse(properties[1].split('[')[1].split(']')[0]);
      body = jsonDecode(body)[arrayProp][index];
      return traverseJsonObject(body, path);
    } else if (properties[1] == 'values') {
      // special case for 'values' keyword
      return traverseJsonObject(body.values.toList(), path);
    } else if (properties[1] == 'first') {
      // special case for 'first' keyword
      return traverseJsonObject(body.first, path);
    } else if (body is Map<String, dynamic>) {
      // handle when object property is a also an object
      body = json.encode(body);
      body = json.decode(body)[properties[1]];
      return traverseJsonObject(body, path);
    } else {
      // handle when object property is any other type
      body = json.decode(body)[properties[1]];
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
