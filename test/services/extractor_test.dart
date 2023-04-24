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

  test("successful parse properties of a list", () {
    Response res = Response('[{"subdeviceGuid":"1234"}]', 200);

    expect((jsonDecode(extractValueFromResponse(res, 'body[0].subdeviceGuid'))),
        1234);
  });

  test("successful parse properties of objects", () {
    Response res = Response('{"entries":{"unknownProp": 1.74}}', 200);
    expect(
        extractValueFromResponse(res, 'body.entries'), {"unknownProp": 1.74});
  });

  test("successful parse string values from list", () {
    Response res = Response(
        '{"entries":{"unknownProp": 1.74}, "another": [ "test", "test2" ]}',
        200);
    expect(extractValueFromResponse(res, 'body.another[1]'), "test2");
  });

  test("successful parse int from a list", () {
    Response res = Response(
        '{"entries":{"unknownProp": 1.74}, "another": [ 12, 13 ]}', 200);
    expect(extractValueFromResponse(res, 'body.another[1]'), 13);
  });
  test("successful parse 'values' keyword", () {
    Response res = Response('[{"entries":{"unknownProp": 1.74}}]', 200);
    expect(extractValueFromResponse(res, 'body[0].entries.values'), [1.74]);
  });

  test("successful parse 'first' keyword", () {
    Response res = Response('[{"entries":{"unknownProp": 1.74}}]', 200);
    expect(extractValueFromResponse(res, 'body[0].entries.values.first'), 1.74);
  });

  test("successfully parse properties of list items", () {
    Response res = Response('{"entries":[{"API": 1.74}]}', 200);
    expect((extractValueFromResponse(res, 'body.entries[0].API')), 1.74);
  });

  test("successfully parse lists of lists", () {
    Response res = Response('[{"entries":[{"API": 1.74}]}]', 200);
    expect((extractValueFromResponse(res, 'body[0].entries[0].API')), 1.74);
  });

//body.results[0].location.street
  test("successfully parse lists of lists", () {
    Response res = Response(
        '{"results":[{"location":{"street":{"someObject":"test"}}}]}', 200);
    expect((extractValueFromResponse(res, 'body.results[0].location.street')),
        {"someObject": "test"});
  });
}
