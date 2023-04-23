import 'dart:convert';

import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:eagler/services/response_extractor.dart';

void main() {
  test("successful parse the body when it's a list", () {
    Response res = Response('[{"entries":{"unknownProp": 1.74}}]', 200);
    expect(jsonDecode(extractValueFromResponse(res, 'body')), [
      {
        "entries": {"unknownProp": 1.74}
      }
    ]);
  });
  test("successful parse an element of the body when its a list", () {
    Response res = Response('[{"entries":{"unknownProp": 1.74}}]', 200);
    expect(extractValueFromResponse(res, 'body[0]'), {
      "entries": {"unknownProp": 1.74}
    });
  });
  test("successful parse properties of an item in list response", () {
    Response res = Response('[{"subdeviceGuid":"1234"}]', 200);

    expect((jsonDecode(extractValueFromResponse(res, 'body[0].subdeviceGuid'))),
        1234);
  });
  test("successful parse properties from an object response", () {
    Response res = Response('{"entries":{"unknownProp": 1.74}}', 200);
    expect(
        extractValueFromResponse(res, 'body.entries'), {"unknownProp": 1.74});
  });
  test("successful parse array strings from response object", () {
    Response res = Response(
        '{"entries":{"unknownProp": 1.74}, "another": [ "test", "test2" ]}',
        200);
    expect(extractValueFromResponse(res, 'body.another[1]'), "test2");
  });
  test("successful parse array ints fro from response object", () {
    Response res = Response(
        '{"entries":{"unknownProp": 1.74}, "another": [ 12, 13 ]}', 200);
    expect(int.parse(extractValueFromResponse(res, 'body.another[1]')), 13);
  });
  test("successful parse 'values' keyword", () {
    Response res = Response('[{"entries":{"unknownProp": 1.74}}]', 200);
    expect(extractValueFromResponse(res, 'body[0].entries.values'), [1.74]);
  });
  test(
      "successfully parse properties of array items that are past body in the path",
      () {
    Response res = Response('{"entries":[{"API": 1.74}]}', 200);
    expect((extractValueFromResponse(res, 'body.entries[0].API')), 1.74);
  });
}
