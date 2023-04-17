/// This function extracts a value from a JSON response based on a user provided
/// schema.
/// ```
/// {
///   'type': 'array', // array, object, or value (string, int, etc)
///   'arrayElement': 0, // ignored if type is not 'array'
///   'objectProperty': null, // ignored if type is not 'object'
///   'child': { 'type': 'value'} // recursive structure, value terminates recursion
/// }```
extractValue(dynamic data, Map<String, dynamic> schema) {
  if (schema['type'] == 'array') {
    int elementIndex = schema['arrayElement'];
    if (data is List && elementIndex < data.length) {
      return extractValue(data[elementIndex], schema['child']);
    } else {
      print('array element $elementIndex not found');
      return null;
    }
  } else if (schema['type'] == 'object') {
    String propertyName = schema['objectProperty'];
    if (data is Map && data.containsKey(propertyName)) {
      return extractValue(data[propertyName], schema['child']);
    } else if (propertyName == 'values') {
      return extractValue(data.values, schema['child']);
    } else if (propertyName == 'first') {
      return extractValue(data.first, schema['child']);
    } else {
      return null;
    }
  } else {
    return data;
  }
}
