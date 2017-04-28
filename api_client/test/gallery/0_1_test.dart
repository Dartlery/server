library api_client.gallery.D0_1.test;

import "dart:core" as core;
import "dart:collection" as collection;
import "dart:async" as async;
import "dart:convert" as convert;

import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:unittest/unittest.dart' as unittest;

import 'package:api_client/gallery/0_1.dart' as api;

class HttpServerMock extends http.BaseClient {
  core.Function _callback;
  core.bool _expectJson;

  void register(core.Function callback, core.bool expectJson) {
    _callback = callback;
    _expectJson = expectJson;
  }

  async.Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (_expectJson) {
      return request.finalize()
          .transform(convert.UTF8.decoder)
          .join('')
          .then((core.String jsonString) {
        if (jsonString.isEmpty) {
          return _callback(request, null);
        } else {
          return _callback(request, convert.JSON.decode(jsonString));
        }
      });
    } else {
      var stream = request.finalize();
      if (stream == null) {
        return _callback(request, []);
      } else {
        return stream.toBytes().then((data) {
          return _callback(request, data);
        });
      }
    }
  }
}

http.StreamedResponse stringResponse(
    core.int status, core.Map headers, core.String body) {
  var stream = new async.Stream.fromIterable([convert.UTF8.encode(body)]);
  return new http.StreamedResponse(stream, status, headers: headers);
}

core.int buildCounterCreateItemRequest = 0;
buildCreateItemRequest() {
  var o = new api.CreateItemRequest();
  buildCounterCreateItemRequest++;
  if (buildCounterCreateItemRequest < 3) {
    o.file = buildMediaMessage();
    o.item = buildItem();
  }
  buildCounterCreateItemRequest--;
  return o;
}

checkCreateItemRequest(api.CreateItemRequest o) {
  buildCounterCreateItemRequest++;
  if (buildCounterCreateItemRequest < 3) {
    checkMediaMessage(o.file);
    checkItem(o.item);
  }
  buildCounterCreateItemRequest--;
}

core.int buildCounterIdResponse = 0;
buildIdResponse() {
  var o = new api.IdResponse();
  buildCounterIdResponse++;
  if (buildCounterIdResponse < 3) {
    o.id = "foo";
    o.location = "foo";
  }
  buildCounterIdResponse--;
  return o;
}

checkIdResponse(api.IdResponse o) {
  buildCounterIdResponse++;
  if (buildCounterIdResponse < 3) {
    unittest.expect(o.id, unittest.equals('foo'));
    unittest.expect(o.location, unittest.equals('foo'));
  }
  buildCounterIdResponse--;
}

buildUnnamed0() {
  var o = new core.List<core.int>();
  o.add(42);
  o.add(42);
  return o;
}

checkUnnamed0(core.List<core.int> o) {
  unittest.expect(o, unittest.hasLength(2));
  unittest.expect(o[0], unittest.equals(42));
  unittest.expect(o[1], unittest.equals(42));
}

buildUnnamed1() {
  var o = new core.Map<core.String, core.String>();
  o["x"] = "foo";
  o["y"] = "foo";
  return o;
}

checkUnnamed1(core.Map<core.String, core.String> o) {
  unittest.expect(o, unittest.hasLength(2));
  unittest.expect(o["x"], unittest.equals('foo'));
  unittest.expect(o["y"], unittest.equals('foo'));
}

buildUnnamed2() {
  var o = new core.List<api.Tag>();
  o.add(buildTag());
  o.add(buildTag());
  return o;
}

checkUnnamed2(core.List<api.Tag> o) {
  unittest.expect(o, unittest.hasLength(2));
  checkTag(o[0]);
  checkTag(o[1]);
}

core.int buildCounterItem = 0;
buildItem() {
  var o = new api.Item();
  buildCounterItem++;
  if (buildCounterItem < 3) {
    o.fileData = buildUnnamed0();
    o.id = "foo";
    o.metadata = buildUnnamed1();
    o.tags = buildUnnamed2();
  }
  buildCounterItem--;
  return o;
}

checkItem(api.Item o) {
  buildCounterItem++;
  if (buildCounterItem < 3) {
    checkUnnamed0(o.fileData);
    unittest.expect(o.id, unittest.equals('foo'));
    checkUnnamed1(o.metadata);
    checkUnnamed2(o.tags);
  }
  buildCounterItem--;
}

buildListOfString() {
  var o = new api.ListOfString();
  o.add("foo");
  o.add("foo");
  return o;
}

checkListOfString(api.ListOfString o) {
  unittest.expect(o, unittest.hasLength(2));
  unittest.expect(o[0], unittest.equals('foo'));
  unittest.expect(o[1], unittest.equals('foo'));
}

buildListOfTag() {
  var o = new api.ListOfTag();
  o.add(buildTag());
  o.add(buildTag());
  return o;
}

checkListOfTag(api.ListOfTag o) {
  unittest.expect(o, unittest.hasLength(2));
  checkTag(o[0]);
  checkTag(o[1]);
}

buildUnnamed3() {
  var o = new core.List<core.int>();
  o.add(42);
  o.add(42);
  return o;
}

checkUnnamed3(core.List<core.int> o) {
  unittest.expect(o, unittest.hasLength(2));
  unittest.expect(o[0], unittest.equals(42));
  unittest.expect(o[1], unittest.equals(42));
}

buildUnnamed4() {
  var o = new core.Map<core.String, core.String>();
  o["x"] = "foo";
  o["y"] = "foo";
  return o;
}

checkUnnamed4(core.Map<core.String, core.String> o) {
  unittest.expect(o, unittest.hasLength(2));
  unittest.expect(o["x"], unittest.equals('foo'));
  unittest.expect(o["y"], unittest.equals('foo'));
}

core.int buildCounterMediaMessage = 0;
buildMediaMessage() {
  var o = new api.MediaMessage();
  buildCounterMediaMessage++;
  if (buildCounterMediaMessage < 3) {
    o.bytes = buildUnnamed3();
    o.cacheControl = "foo";
    o.contentEncoding = "foo";
    o.contentLanguage = "foo";
    o.contentType = "foo";
    o.md5Hash = "foo";
    o.metadata = buildUnnamed4();
    o.updated = core.DateTime.parse("2002-02-27T14:01:02");
  }
  buildCounterMediaMessage--;
  return o;
}

checkMediaMessage(api.MediaMessage o) {
  buildCounterMediaMessage++;
  if (buildCounterMediaMessage < 3) {
    checkUnnamed3(o.bytes);
    unittest.expect(o.cacheControl, unittest.equals('foo'));
    unittest.expect(o.contentEncoding, unittest.equals('foo'));
    unittest.expect(o.contentLanguage, unittest.equals('foo'));
    unittest.expect(o.contentType, unittest.equals('foo'));
    unittest.expect(o.md5Hash, unittest.equals('foo'));
    checkUnnamed4(o.metadata);
    unittest.expect(o.updated, unittest.equals(core.DateTime.parse("2002-02-27T14:01:02")));
  }
  buildCounterMediaMessage--;
}

buildUnnamed5() {
  var o = new core.List<core.String>();
  o.add("foo");
  o.add("foo");
  return o;
}

checkUnnamed5(core.List<core.String> o) {
  unittest.expect(o, unittest.hasLength(2));
  unittest.expect(o[0], unittest.equals('foo'));
  unittest.expect(o[1], unittest.equals('foo'));
}

core.int buildCounterPaginatedResponse = 0;
buildPaginatedResponse() {
  var o = new api.PaginatedResponse();
  buildCounterPaginatedResponse++;
  if (buildCounterPaginatedResponse < 3) {
    o.items = buildUnnamed5();
    o.page = 42;
    o.pageCount = 42;
    o.startIndex = 42;
    o.totalCount = 42;
    o.totalPages = 42;
  }
  buildCounterPaginatedResponse--;
  return o;
}

checkPaginatedResponse(api.PaginatedResponse o) {
  buildCounterPaginatedResponse++;
  if (buildCounterPaginatedResponse < 3) {
    checkUnnamed5(o.items);
    unittest.expect(o.page, unittest.equals(42));
    unittest.expect(o.pageCount, unittest.equals(42));
    unittest.expect(o.startIndex, unittest.equals(42));
    unittest.expect(o.totalCount, unittest.equals(42));
    unittest.expect(o.totalPages, unittest.equals(42));
  }
  buildCounterPaginatedResponse--;
}

core.int buildCounterPasswordChangeRequest = 0;
buildPasswordChangeRequest() {
  var o = new api.PasswordChangeRequest();
  buildCounterPasswordChangeRequest++;
  if (buildCounterPasswordChangeRequest < 3) {
    o.currentPassword = "foo";
    o.newPassword = "foo";
  }
  buildCounterPasswordChangeRequest--;
  return o;
}

checkPasswordChangeRequest(api.PasswordChangeRequest o) {
  buildCounterPasswordChangeRequest++;
  if (buildCounterPasswordChangeRequest < 3) {
    unittest.expect(o.currentPassword, unittest.equals('foo'));
    unittest.expect(o.newPassword, unittest.equals('foo'));
  }
  buildCounterPasswordChangeRequest--;
}

core.int buildCounterSetupRequest = 0;
buildSetupRequest() {
  var o = new api.SetupRequest();
  buildCounterSetupRequest++;
  if (buildCounterSetupRequest < 3) {
    o.adminPassword = "foo";
    o.adminUser = "foo";
  }
  buildCounterSetupRequest--;
  return o;
}

checkSetupRequest(api.SetupRequest o) {
  buildCounterSetupRequest++;
  if (buildCounterSetupRequest < 3) {
    unittest.expect(o.adminPassword, unittest.equals('foo'));
    unittest.expect(o.adminUser, unittest.equals('foo'));
  }
  buildCounterSetupRequest--;
}

core.int buildCounterSetupResponse = 0;
buildSetupResponse() {
  var o = new api.SetupResponse();
  buildCounterSetupResponse++;
  if (buildCounterSetupResponse < 3) {
    o.adminUser = true;
  }
  buildCounterSetupResponse--;
  return o;
}

checkSetupResponse(api.SetupResponse o) {
  buildCounterSetupResponse++;
  if (buildCounterSetupResponse < 3) {
    unittest.expect(o.adminUser, unittest.isTrue);
  }
  buildCounterSetupResponse--;
}

core.int buildCounterTag = 0;
buildTag() {
  var o = new api.Tag();
  buildCounterTag++;
  if (buildCounterTag < 3) {
    o.category = "foo";
    o.id = "foo";
  }
  buildCounterTag--;
  return o;
}

checkTag(api.Tag o) {
  buildCounterTag++;
  if (buildCounterTag < 3) {
    unittest.expect(o.category, unittest.equals('foo'));
    unittest.expect(o.id, unittest.equals('foo'));
  }
  buildCounterTag--;
}

core.int buildCounterTagCategory = 0;
buildTagCategory() {
  var o = new api.TagCategory();
  buildCounterTagCategory++;
  if (buildCounterTagCategory < 3) {
    o.color = "foo";
    o.id = "foo";
  }
  buildCounterTagCategory--;
  return o;
}

checkTagCategory(api.TagCategory o) {
  buildCounterTagCategory++;
  if (buildCounterTagCategory < 3) {
    unittest.expect(o.color, unittest.equals('foo'));
    unittest.expect(o.id, unittest.equals('foo'));
  }
  buildCounterTagCategory--;
}

buildUnnamed6() {
  var o = new core.List<api.MediaMessage>();
  o.add(buildMediaMessage());
  o.add(buildMediaMessage());
  return o;
}

checkUnnamed6(core.List<api.MediaMessage> o) {
  unittest.expect(o, unittest.hasLength(2));
  checkMediaMessage(o[0]);
  checkMediaMessage(o[1]);
}

core.int buildCounterUpdateItemRequest = 0;
buildUpdateItemRequest() {
  var o = new api.UpdateItemRequest();
  buildCounterUpdateItemRequest++;
  if (buildCounterUpdateItemRequest < 3) {
    o.files = buildUnnamed6();
    o.item = buildItem();
  }
  buildCounterUpdateItemRequest--;
  return o;
}

checkUpdateItemRequest(api.UpdateItemRequest o) {
  buildCounterUpdateItemRequest++;
  if (buildCounterUpdateItemRequest < 3) {
    checkUnnamed6(o.files);
    checkItem(o.item);
  }
  buildCounterUpdateItemRequest--;
}

core.int buildCounterUser = 0;
buildUser() {
  var o = new api.User();
  buildCounterUser++;
  if (buildCounterUser < 3) {
    o.id = "foo";
    o.name = "foo";
    o.password = "foo";
    o.type = "foo";
  }
  buildCounterUser--;
  return o;
}

checkUser(api.User o) {
  buildCounterUser++;
  if (buildCounterUser < 3) {
    unittest.expect(o.id, unittest.equals('foo'));
    unittest.expect(o.name, unittest.equals('foo'));
    unittest.expect(o.password, unittest.equals('foo'));
    unittest.expect(o.type, unittest.equals('foo'));
  }
  buildCounterUser--;
}


main() {
  unittest.group("obj-schema-CreateItemRequest", () {
    unittest.test("to-json--from-json", () {
      var o = buildCreateItemRequest();
      var od = new api.CreateItemRequest.fromJson(o.toJson());
      checkCreateItemRequest(od);
    });
  });


  unittest.group("obj-schema-IdResponse", () {
    unittest.test("to-json--from-json", () {
      var o = buildIdResponse();
      var od = new api.IdResponse.fromJson(o.toJson());
      checkIdResponse(od);
    });
  });


  unittest.group("obj-schema-Item", () {
    unittest.test("to-json--from-json", () {
      var o = buildItem();
      var od = new api.Item.fromJson(o.toJson());
      checkItem(od);
    });
  });


  unittest.group("obj-schema-ListOfString", () {
    unittest.test("to-json--from-json", () {
      var o = buildListOfString();
      var od = new api.ListOfString.fromJson(o.toJson());
      checkListOfString(od);
    });
  });


  unittest.group("obj-schema-ListOfTag", () {
    unittest.test("to-json--from-json", () {
      var o = buildListOfTag();
      var od = new api.ListOfTag.fromJson(o.toJson());
      checkListOfTag(od);
    });
  });


  unittest.group("obj-schema-MediaMessage", () {
    unittest.test("to-json--from-json", () {
      var o = buildMediaMessage();
      var od = new api.MediaMessage.fromJson(o.toJson());
      checkMediaMessage(od);
    });
  });


  unittest.group("obj-schema-PaginatedResponse", () {
    unittest.test("to-json--from-json", () {
      var o = buildPaginatedResponse();
      var od = new api.PaginatedResponse.fromJson(o.toJson());
      checkPaginatedResponse(od);
    });
  });


  unittest.group("obj-schema-PasswordChangeRequest", () {
    unittest.test("to-json--from-json", () {
      var o = buildPasswordChangeRequest();
      var od = new api.PasswordChangeRequest.fromJson(o.toJson());
      checkPasswordChangeRequest(od);
    });
  });


  unittest.group("obj-schema-SetupRequest", () {
    unittest.test("to-json--from-json", () {
      var o = buildSetupRequest();
      var od = new api.SetupRequest.fromJson(o.toJson());
      checkSetupRequest(od);
    });
  });


  unittest.group("obj-schema-SetupResponse", () {
    unittest.test("to-json--from-json", () {
      var o = buildSetupResponse();
      var od = new api.SetupResponse.fromJson(o.toJson());
      checkSetupResponse(od);
    });
  });


  unittest.group("obj-schema-Tag", () {
    unittest.test("to-json--from-json", () {
      var o = buildTag();
      var od = new api.Tag.fromJson(o.toJson());
      checkTag(od);
    });
  });


  unittest.group("obj-schema-TagCategory", () {
    unittest.test("to-json--from-json", () {
      var o = buildTagCategory();
      var od = new api.TagCategory.fromJson(o.toJson());
      checkTagCategory(od);
    });
  });


  unittest.group("obj-schema-UpdateItemRequest", () {
    unittest.test("to-json--from-json", () {
      var o = buildUpdateItemRequest();
      var od = new api.UpdateItemRequest.fromJson(o.toJson());
      checkUpdateItemRequest(od);
    });
  });


  unittest.group("obj-schema-User", () {
    unittest.test("to-json--from-json", () {
      var o = buildUser();
      var od = new api.User.fromJson(o.toJson());
      checkUser(od);
    });
  });


  unittest.group("resource-ItemsResourceApi", () {
    unittest.test("method--createItem", () {

      var mock = new HttpServerMock();
      api.ItemsResourceApi res = new api.GalleryApi(mock).items;
      var arg_request = buildCreateItemRequest();
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var obj = new api.CreateItemRequest.fromJson(json);
        checkCreateItemRequest(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("api/gallery/0.1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("items/"));
        pathOffset += 6;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildIdResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.createItem(arg_request).then(unittest.expectAsync(((api.IdResponse response) {
        checkIdResponse(response);
      })));
    });

    unittest.test("method--delete", () {

      var mock = new HttpServerMock();
      api.ItemsResourceApi res = new api.GalleryApi(mock).items;
      var arg_id = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("api/gallery/0.1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("items/"));
        pathOffset += 6;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_id"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = "";
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.delete(arg_id).then(unittest.expectAsync((_) {}));
    });

    unittest.test("method--getById", () {

      var mock = new HttpServerMock();
      api.ItemsResourceApi res = new api.GalleryApi(mock).items;
      var arg_id = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("api/gallery/0.1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("items/"));
        pathOffset += 6;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_id"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildItem());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.getById(arg_id).then(unittest.expectAsync(((api.Item response) {
        checkItem(response);
      })));
    });

    unittest.test("method--getVisibleIds", () {

      var mock = new HttpServerMock();
      api.ItemsResourceApi res = new api.GalleryApi(mock).items;
      var arg_page = 42;
      var arg_perPage = 42;
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("api/gallery/0.1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("items/"));
        pathOffset += 6;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }
        unittest.expect(core.int.parse(queryMap["page"].first), unittest.equals(arg_page));
        unittest.expect(core.int.parse(queryMap["perPage"].first), unittest.equals(arg_perPage));


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildPaginatedResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.getVisibleIds(page: arg_page, perPage: arg_perPage).then(unittest.expectAsync(((api.PaginatedResponse response) {
        checkPaginatedResponse(response);
      })));
    });

    unittest.test("method--searchVisible", () {

      var mock = new HttpServerMock();
      api.ItemsResourceApi res = new api.GalleryApi(mock).items;
      var arg_query = "foo";
      var arg_page = 42;
      var arg_perPage = 42;
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("api/gallery/0.1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 7), unittest.equals("search/"));
        pathOffset += 7;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_query"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }
        unittest.expect(core.int.parse(queryMap["page"].first), unittest.equals(arg_page));
        unittest.expect(core.int.parse(queryMap["perPage"].first), unittest.equals(arg_perPage));


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildPaginatedResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.searchVisible(arg_query, page: arg_page, perPage: arg_perPage).then(unittest.expectAsync(((api.PaginatedResponse response) {
        checkPaginatedResponse(response);
      })));
    });

    unittest.test("method--updateItem", () {

      var mock = new HttpServerMock();
      api.ItemsResourceApi res = new api.GalleryApi(mock).items;
      var arg_request = buildUpdateItemRequest();
      var arg_id = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var obj = new api.UpdateItemRequest.fromJson(json);
        checkUpdateItemRequest(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("api/gallery/0.1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("items/"));
        pathOffset += 6;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_id"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildIdResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.updateItem(arg_request, arg_id).then(unittest.expectAsync(((api.IdResponse response) {
        checkIdResponse(response);
      })));
    });

  });


  unittest.group("resource-SetupResourceApi", () {
    unittest.test("method--apply", () {

      var mock = new HttpServerMock();
      api.SetupResourceApi res = new api.GalleryApi(mock).setup;
      var arg_request = buildSetupRequest();
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var obj = new api.SetupRequest.fromJson(json);
        checkSetupRequest(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("api/gallery/0.1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("setup/"));
        pathOffset += 6;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildSetupResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.apply(arg_request).then(unittest.expectAsync(((api.SetupResponse response) {
        checkSetupResponse(response);
      })));
    });

    unittest.test("method--get", () {

      var mock = new HttpServerMock();
      api.SetupResourceApi res = new api.GalleryApi(mock).setup;
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("api/gallery/0.1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("setup/"));
        pathOffset += 6;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildSetupResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.get().then(unittest.expectAsync(((api.SetupResponse response) {
        checkSetupResponse(response);
      })));
    });

  });


  unittest.group("resource-TagCategoriesResourceApi", () {
    unittest.test("method--create", () {

      var mock = new HttpServerMock();
      api.TagCategoriesResourceApi res = new api.GalleryApi(mock).tagCategories;
      var arg_request = buildTagCategory();
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var obj = new api.TagCategory.fromJson(json);
        checkTagCategory(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("api/gallery/0.1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 15), unittest.equals("tag_categories/"));
        pathOffset += 15;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildIdResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.create(arg_request).then(unittest.expectAsync(((api.IdResponse response) {
        checkIdResponse(response);
      })));
    });

    unittest.test("method--delete", () {

      var mock = new HttpServerMock();
      api.TagCategoriesResourceApi res = new api.GalleryApi(mock).tagCategories;
      var arg_id = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("api/gallery/0.1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 15), unittest.equals("tag_categories/"));
        pathOffset += 15;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_id"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = "";
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.delete(arg_id).then(unittest.expectAsync((_) {}));
    });

    unittest.test("method--getAllIds", () {

      var mock = new HttpServerMock();
      api.TagCategoriesResourceApi res = new api.GalleryApi(mock).tagCategories;
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("api/gallery/0.1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 15), unittest.equals("tag_categories/"));
        pathOffset += 15;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildListOfString());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.getAllIds().then(unittest.expectAsync(((api.ListOfString response) {
        checkListOfString(response);
      })));
    });

    unittest.test("method--getById", () {

      var mock = new HttpServerMock();
      api.TagCategoriesResourceApi res = new api.GalleryApi(mock).tagCategories;
      var arg_id = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("api/gallery/0.1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 15), unittest.equals("tag_categories/"));
        pathOffset += 15;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_id"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildTagCategory());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.getById(arg_id).then(unittest.expectAsync(((api.TagCategory response) {
        checkTagCategory(response);
      })));
    });

    unittest.test("method--update", () {

      var mock = new HttpServerMock();
      api.TagCategoriesResourceApi res = new api.GalleryApi(mock).tagCategories;
      var arg_request = buildTagCategory();
      var arg_id = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var obj = new api.TagCategory.fromJson(json);
        checkTagCategory(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("api/gallery/0.1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 15), unittest.equals("tag_categories/"));
        pathOffset += 15;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_id"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildIdResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.update(arg_request, arg_id).then(unittest.expectAsync(((api.IdResponse response) {
        checkIdResponse(response);
      })));
    });

  });


  unittest.group("resource-TagsResourceApi", () {
    unittest.test("method--search", () {

      var mock = new HttpServerMock();
      api.TagsResourceApi res = new api.GalleryApi(mock).tags;
      var arg_query = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("api/gallery/0.1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 13), unittest.equals("setup/search/"));
        pathOffset += 13;
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset));
        pathOffset = path.length;
        unittest.expect(subPart, unittest.equals("$arg_query"));

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildListOfTag());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.search(arg_query).then(unittest.expectAsync(((api.ListOfTag response) {
        checkListOfTag(response);
      })));
    });

  });


  unittest.group("resource-UsersResourceApi", () {
    unittest.test("method--changePassword", () {

      var mock = new HttpServerMock();
      api.UsersResourceApi res = new api.GalleryApi(mock).users;
      var arg_request = buildPasswordChangeRequest();
      var arg_uuid = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var obj = new api.PasswordChangeRequest.fromJson(json);
        checkPasswordChangeRequest(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("api/gallery/0.1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("users/"));
        pathOffset += 6;
        index = path.indexOf("/password/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_uuid"));
        unittest.expect(path.substring(pathOffset, pathOffset + 10), unittest.equals("/password/"));
        pathOffset += 10;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = "";
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.changePassword(arg_request, arg_uuid).then(unittest.expectAsync((_) {}));
    });

    unittest.test("method--create", () {

      var mock = new HttpServerMock();
      api.UsersResourceApi res = new api.GalleryApi(mock).users;
      var arg_request = buildUser();
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var obj = new api.User.fromJson(json);
        checkUser(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("api/gallery/0.1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("users/"));
        pathOffset += 6;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildIdResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.create(arg_request).then(unittest.expectAsync(((api.IdResponse response) {
        checkIdResponse(response);
      })));
    });

    unittest.test("method--delete", () {

      var mock = new HttpServerMock();
      api.UsersResourceApi res = new api.GalleryApi(mock).users;
      var arg_uuid = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("api/gallery/0.1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("users/"));
        pathOffset += 6;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_uuid"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = "";
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.delete(arg_uuid).then(unittest.expectAsync((_) {}));
    });

    unittest.test("method--getById", () {

      var mock = new HttpServerMock();
      api.UsersResourceApi res = new api.GalleryApi(mock).users;
      var arg_uuid = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("api/gallery/0.1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("users/"));
        pathOffset += 6;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_uuid"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildUser());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.getById(arg_uuid).then(unittest.expectAsync(((api.User response) {
        checkUser(response);
      })));
    });

    unittest.test("method--getMe", () {

      var mock = new HttpServerMock();
      api.UsersResourceApi res = new api.GalleryApi(mock).users;
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("api/gallery/0.1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 13), unittest.equals("current_user/"));
        pathOffset += 13;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildUser());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.getMe().then(unittest.expectAsync(((api.User response) {
        checkUser(response);
      })));
    });

    unittest.test("method--update", () {

      var mock = new HttpServerMock();
      api.UsersResourceApi res = new api.GalleryApi(mock).users;
      var arg_request = buildUser();
      var arg_uuid = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var obj = new api.User.fromJson(json);
        checkUser(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 16), unittest.equals("api/gallery/0.1/"));
        pathOffset += 16;
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("users/"));
        pathOffset += 6;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_uuid"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildIdResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.update(arg_request, arg_uuid).then(unittest.expectAsync(((api.IdResponse response) {
        checkIdResponse(response);
      })));
    });

  });


}

