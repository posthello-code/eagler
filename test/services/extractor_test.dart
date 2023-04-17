import 'package:test/test.dart';
import 'package:eagler/services/response_extractor.dart';

dynamic extractorSchemaExample = {
  'type': 'array',
  'arrayElement': 0,
  'objectProperty': null,
  'child': {
    'type': 'object',
    'objectProperty': 'entries',
    'child': {
      'type': 'object',
      'objectProperty': 'values',
      'child': {
        'type': 'object',
        'objectProperty': 'first',
        'child': {'type': 'value'}
      }
    }
  }
};

dynamic data = [
  {
    "subdeviceGuid": "00078100025c288f",
    "componentId": "all",
    "entries": {"1681718544000": 1.74}
  }
];

void main() {
  test('the extractor can extract a user provided extractorSchema', () {
    expect(extractValue(data, extractorSchemaExample), 1.74);
  });
}
