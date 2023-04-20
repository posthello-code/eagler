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

dynamic responseExample = [
  {
    "id": "1234",
    "componentId": "1234",
    "entries": {"someValue": 1.74}
  }
];

void main() {
  test('the extractor can extract a user provided extractorSchema', () {
    expect(extractValue(responseExample, extractorSchemaExample), 1.74);
  });
}
