library api_client.gallery.v0_1.test;

import "dart:core" as core;
import "dart:collection" as collection;
import "dart:async" as async;
import "dart:convert" as convert;

import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:test/test.dart' as unittest;

import 'package:api_client/gallery/v0_1.dart' as api;

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
    core.int status, core.Map<core.String, core.String> headers, core.String body) {
  var stream = new async.Stream.fromIterable([convert.UTF8.encode(body)]);
  return new http.StreamedResponse(stream, status, headers: headers);
}

core.int buildCounterCountResponse = 0;
buildCountResponse() {
  var o = new api.CountResponse();
  buildCounterCountResponse++;
  if (buildCounterCountResponse < 3) {
    o.count = 42;
  }
  buildCounterCountResponse--;
  return o;
}

checkCountResponse(api.CountResponse o) {
  buildCounterCountResponse++;
  if (buildCounterCountResponse < 3) {
    unittest.expect(o.count, unittest.equals(42));
  }
  buildCounterCountResponse--;
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

core.int buildCounterExtensionData = 0;
buildExtensionData() {
  var o = new api.ExtensionData();
  buildCounterExtensionData++;
  if (buildCounterExtensionData < 3) {
    o.primaryId = "foo";
    o.secondaryId = "foo";
    o.value = "foo";
  }
  buildCounterExtensionData--;
  return o;
}

checkExtensionData(api.ExtensionData o) {
  buildCounterExtensionData++;
  if (buildCounterExtensionData < 3) {
    unittest.expect(o.primaryId, unittest.equals('foo'));
    unittest.expect(o.secondaryId, unittest.equals('foo'));
    unittest.expect(o.value, unittest.equals('foo'));
  }
  buildCounterExtensionData--;
}

core.int buildCounterIdRequest = 0;
buildIdRequest() {
  var o = new api.IdRequest();
  buildCounterIdRequest++;
  if (buildCounterIdRequest < 3) {
    o.id = "foo";
  }
  buildCounterIdRequest--;
  return o;
}

checkIdRequest(api.IdRequest o) {
  buildCounterIdRequest++;
  if (buildCounterIdRequest < 3) {
    unittest.expect(o.id, unittest.equals('foo'));
  }
  buildCounterIdRequest--;
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

core.int buildCounterImportPathRequest = 0;
buildImportPathRequest() {
  var o = new api.ImportPathRequest();
  buildCounterImportPathRequest++;
  if (buildCounterImportPathRequest < 3) {
    o.interpretShimmieNames = true;
    o.mergeExisting = true;
    o.path = "foo";
    o.stopOnError = true;
  }
  buildCounterImportPathRequest--;
  return o;
}

checkImportPathRequest(api.ImportPathRequest o) {
  buildCounterImportPathRequest++;
  if (buildCounterImportPathRequest < 3) {
    unittest.expect(o.interpretShimmieNames, unittest.isTrue);
    unittest.expect(o.mergeExisting, unittest.isTrue);
    unittest.expect(o.path, unittest.equals('foo'));
    unittest.expect(o.stopOnError, unittest.isTrue);
  }
  buildCounterImportPathRequest--;
}

core.int buildCounterImportResult = 0;
buildImportResult() {
  var o = new api.ImportResult();
  buildCounterImportResult++;
  if (buildCounterImportResult < 3) {
    o.batchTimestamp = core.DateTime.parse("2002-02-27T14:01:02");
    o.error = "foo";
    o.fileName = "foo";
    o.id = "foo";
    o.result = "foo";
    o.source = "foo";
    o.thumbnailCreated = true;
    o.timestamp = core.DateTime.parse("2002-02-27T14:01:02");
  }
  buildCounterImportResult--;
  return o;
}

checkImportResult(api.ImportResult o) {
  buildCounterImportResult++;
  if (buildCounterImportResult < 3) {
    unittest.expect(o.batchTimestamp, unittest.equals(core.DateTime.parse("2002-02-27T14:01:02")));
    unittest.expect(o.error, unittest.equals('foo'));
    unittest.expect(o.fileName, unittest.equals('foo'));
    unittest.expect(o.id, unittest.equals('foo'));
    unittest.expect(o.result, unittest.equals('foo'));
    unittest.expect(o.source, unittest.equals('foo'));
    unittest.expect(o.thumbnailCreated, unittest.isTrue);
    unittest.expect(o.timestamp, unittest.equals(core.DateTime.parse("2002-02-27T14:01:02")));
  }
  buildCounterImportResult--;
}

buildUnnamed0() {
  var o = new core.List<core.String>();
  o.add("foo");
  o.add("foo");
  return o;
}

checkUnnamed0(core.List<core.String> o) {
  unittest.expect(o, unittest.hasLength(2));
  unittest.expect(o[0], unittest.equals('foo'));
  unittest.expect(o[1], unittest.equals('foo'));
}

buildUnnamed1() {
  var o = new core.List<core.int>();
  o.add(42);
  o.add(42);
  return o;
}

checkUnnamed1(core.List<core.int> o) {
  unittest.expect(o, unittest.hasLength(2));
  unittest.expect(o[0], unittest.equals(42));
  unittest.expect(o[1], unittest.equals(42));
}

buildUnnamed2() {
  var o = new core.Map<core.String, core.String>();
  o["x"] = "foo";
  o["y"] = "foo";
  return o;
}

checkUnnamed2(core.Map<core.String, core.String> o) {
  unittest.expect(o, unittest.hasLength(2));
  unittest.expect(o["x"], unittest.equals('foo'));
  unittest.expect(o["y"], unittest.equals('foo'));
}

buildUnnamed3() {
  var o = new core.List<api.Tag>();
  o.add(buildTag());
  o.add(buildTag());
  return o;
}

checkUnnamed3(core.List<api.Tag> o) {
  unittest.expect(o, unittest.hasLength(2));
  checkTag(o[0]);
  checkTag(o[1]);
}

core.int buildCounterItem = 0;
buildItem() {
  var o = new api.Item();
  buildCounterItem++;
  if (buildCounterItem < 3) {
    o.audio = true;
    o.downloadName = "foo";
    o.duration = 42;
    o.errors = buildUnnamed0();
    o.extension = "foo";
    o.fileData = buildUnnamed1();
    o.fileName = "foo";
    o.fullFileAvailable = true;
    o.height = 42;
    o.id = "foo";
    o.length = "foo";
    o.metadata = buildUnnamed2();
    o.mime = "foo";
    o.source = "foo";
    o.tags = buildUnnamed3();
    o.uploaded = core.DateTime.parse("2002-02-27T14:01:02");
    o.uploader = "foo";
    o.video = true;
    o.width = 42;
  }
  buildCounterItem--;
  return o;
}

checkItem(api.Item o) {
  buildCounterItem++;
  if (buildCounterItem < 3) {
    unittest.expect(o.audio, unittest.isTrue);
    unittest.expect(o.downloadName, unittest.equals('foo'));
    unittest.expect(o.duration, unittest.equals(42));
    checkUnnamed0(o.errors);
    unittest.expect(o.extension, unittest.equals('foo'));
    checkUnnamed1(o.fileData);
    unittest.expect(o.fileName, unittest.equals('foo'));
    unittest.expect(o.fullFileAvailable, unittest.isTrue);
    unittest.expect(o.height, unittest.equals(42));
    unittest.expect(o.id, unittest.equals('foo'));
    unittest.expect(o.length, unittest.equals('foo'));
    checkUnnamed2(o.metadata);
    unittest.expect(o.mime, unittest.equals('foo'));
    unittest.expect(o.source, unittest.equals('foo'));
    checkUnnamed3(o.tags);
    unittest.expect(o.uploaded, unittest.equals(core.DateTime.parse("2002-02-27T14:01:02")));
    unittest.expect(o.uploader, unittest.equals('foo'));
    unittest.expect(o.video, unittest.isTrue);
    unittest.expect(o.width, unittest.equals(42));
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

buildListOfTagInfo() {
  var o = new api.ListOfTagInfo();
  o.add(buildTagInfo());
  o.add(buildTagInfo());
  return o;
}

checkListOfTagInfo(api.ListOfTagInfo o) {
  unittest.expect(o, unittest.hasLength(2));
  checkTagInfo(o[0]);
  checkTagInfo(o[1]);
}

buildUnnamed4() {
  var o = new core.List<core.int>();
  o.add(42);
  o.add(42);
  return o;
}

checkUnnamed4(core.List<core.int> o) {
  unittest.expect(o, unittest.hasLength(2));
  unittest.expect(o[0], unittest.equals(42));
  unittest.expect(o[1], unittest.equals(42));
}

buildUnnamed5() {
  var o = new core.Map<core.String, core.String>();
  o["x"] = "foo";
  o["y"] = "foo";
  return o;
}

checkUnnamed5(core.Map<core.String, core.String> o) {
  unittest.expect(o, unittest.hasLength(2));
  unittest.expect(o["x"], unittest.equals('foo'));
  unittest.expect(o["y"], unittest.equals('foo'));
}

core.int buildCounterMediaMessage = 0;
buildMediaMessage() {
  var o = new api.MediaMessage();
  buildCounterMediaMessage++;
  if (buildCounterMediaMessage < 3) {
    o.bytes = buildUnnamed4();
    o.cacheControl = "foo";
    o.contentEncoding = "foo";
    o.contentLanguage = "foo";
    o.contentType = "foo";
    o.md5Hash = "foo";
    o.metadata = buildUnnamed5();
    o.updated = core.DateTime.parse("2002-02-27T14:01:02");
  }
  buildCounterMediaMessage--;
  return o;
}

checkMediaMessage(api.MediaMessage o) {
  buildCounterMediaMessage++;
  if (buildCounterMediaMessage < 3) {
    checkUnnamed4(o.bytes);
    unittest.expect(o.cacheControl, unittest.equals('foo'));
    unittest.expect(o.contentEncoding, unittest.equals('foo'));
    unittest.expect(o.contentLanguage, unittest.equals('foo'));
    unittest.expect(o.contentType, unittest.equals('foo'));
    unittest.expect(o.md5Hash, unittest.equals('foo'));
    checkUnnamed5(o.metadata);
    unittest.expect(o.updated, unittest.equals(core.DateTime.parse("2002-02-27T14:01:02")));
  }
  buildCounterMediaMessage--;
}

buildUnnamed6() {
  var o = new core.List<api.ExtensionData>();
  o.add(buildExtensionData());
  o.add(buildExtensionData());
  return o;
}

checkUnnamed6(core.List<api.ExtensionData> o) {
  unittest.expect(o, unittest.hasLength(2));
  checkExtensionData(o[0]);
  checkExtensionData(o[1]);
}

core.int buildCounterPaginatedExtensionDataResponse = 0;
buildPaginatedExtensionDataResponse() {
  var o = new api.PaginatedExtensionDataResponse();
  buildCounterPaginatedExtensionDataResponse++;
  if (buildCounterPaginatedExtensionDataResponse < 3) {
    o.items = buildUnnamed6();
    o.page = 42;
    o.pageCount = 42;
    o.startIndex = 42;
    o.totalCount = 42;
    o.totalPages = 42;
  }
  buildCounterPaginatedExtensionDataResponse--;
  return o;
}

checkPaginatedExtensionDataResponse(api.PaginatedExtensionDataResponse o) {
  buildCounterPaginatedExtensionDataResponse++;
  if (buildCounterPaginatedExtensionDataResponse < 3) {
    checkUnnamed6(o.items);
    unittest.expect(o.page, unittest.equals(42));
    unittest.expect(o.pageCount, unittest.equals(42));
    unittest.expect(o.startIndex, unittest.equals(42));
    unittest.expect(o.totalCount, unittest.equals(42));
    unittest.expect(o.totalPages, unittest.equals(42));
  }
  buildCounterPaginatedExtensionDataResponse--;
}

buildUnnamed7() {
  var o = new core.List<api.ImportResult>();
  o.add(buildImportResult());
  o.add(buildImportResult());
  return o;
}

checkUnnamed7(core.List<api.ImportResult> o) {
  unittest.expect(o, unittest.hasLength(2));
  checkImportResult(o[0]);
  checkImportResult(o[1]);
}

core.int buildCounterPaginatedImportResultsResponse = 0;
buildPaginatedImportResultsResponse() {
  var o = new api.PaginatedImportResultsResponse();
  buildCounterPaginatedImportResultsResponse++;
  if (buildCounterPaginatedImportResultsResponse < 3) {
    o.items = buildUnnamed7();
    o.page = 42;
    o.pageCount = 42;
    o.startIndex = 42;
    o.totalCount = 42;
    o.totalPages = 42;
  }
  buildCounterPaginatedImportResultsResponse--;
  return o;
}

checkPaginatedImportResultsResponse(api.PaginatedImportResultsResponse o) {
  buildCounterPaginatedImportResultsResponse++;
  if (buildCounterPaginatedImportResultsResponse < 3) {
    checkUnnamed7(o.items);
    unittest.expect(o.page, unittest.equals(42));
    unittest.expect(o.pageCount, unittest.equals(42));
    unittest.expect(o.startIndex, unittest.equals(42));
    unittest.expect(o.totalCount, unittest.equals(42));
    unittest.expect(o.totalPages, unittest.equals(42));
  }
  buildCounterPaginatedImportResultsResponse--;
}

buildUnnamed8() {
  var o = new core.List<core.String>();
  o.add("foo");
  o.add("foo");
  return o;
}

checkUnnamed8(core.List<core.String> o) {
  unittest.expect(o, unittest.hasLength(2));
  unittest.expect(o[0], unittest.equals('foo'));
  unittest.expect(o[1], unittest.equals('foo'));
}

buildUnnamed9() {
  var o = new core.List<api.Tag>();
  o.add(buildTag());
  o.add(buildTag());
  return o;
}

checkUnnamed9(core.List<api.Tag> o) {
  unittest.expect(o, unittest.hasLength(2));
  checkTag(o[0]);
  checkTag(o[1]);
}

core.int buildCounterPaginatedItemResponse = 0;
buildPaginatedItemResponse() {
  var o = new api.PaginatedItemResponse();
  buildCounterPaginatedItemResponse++;
  if (buildCounterPaginatedItemResponse < 3) {
    o.items = buildUnnamed8();
    o.page = 42;
    o.pageCount = 42;
    o.queryTags = buildUnnamed9();
    o.startIndex = 42;
    o.totalCount = 42;
    o.totalPages = 42;
  }
  buildCounterPaginatedItemResponse--;
  return o;
}

checkPaginatedItemResponse(api.PaginatedItemResponse o) {
  buildCounterPaginatedItemResponse++;
  if (buildCounterPaginatedItemResponse < 3) {
    checkUnnamed8(o.items);
    unittest.expect(o.page, unittest.equals(42));
    unittest.expect(o.pageCount, unittest.equals(42));
    checkUnnamed9(o.queryTags);
    unittest.expect(o.startIndex, unittest.equals(42));
    unittest.expect(o.totalCount, unittest.equals(42));
    unittest.expect(o.totalPages, unittest.equals(42));
  }
  buildCounterPaginatedItemResponse--;
}

buildUnnamed10() {
  var o = new core.List<api.TagInfo>();
  o.add(buildTagInfo());
  o.add(buildTagInfo());
  return o;
}

checkUnnamed10(core.List<api.TagInfo> o) {
  unittest.expect(o, unittest.hasLength(2));
  checkTagInfo(o[0]);
  checkTagInfo(o[1]);
}

core.int buildCounterPaginatedTagResponse = 0;
buildPaginatedTagResponse() {
  var o = new api.PaginatedTagResponse();
  buildCounterPaginatedTagResponse++;
  if (buildCounterPaginatedTagResponse < 3) {
    o.items = buildUnnamed10();
    o.page = 42;
    o.pageCount = 42;
    o.startIndex = 42;
    o.totalCount = 42;
    o.totalPages = 42;
  }
  buildCounterPaginatedTagResponse--;
  return o;
}

checkPaginatedTagResponse(api.PaginatedTagResponse o) {
  buildCounterPaginatedTagResponse++;
  if (buildCounterPaginatedTagResponse < 3) {
    checkUnnamed10(o.items);
    unittest.expect(o.page, unittest.equals(42));
    unittest.expect(o.pageCount, unittest.equals(42));
    unittest.expect(o.startIndex, unittest.equals(42));
    unittest.expect(o.totalCount, unittest.equals(42));
    unittest.expect(o.totalPages, unittest.equals(42));
  }
  buildCounterPaginatedTagResponse--;
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

buildUnnamed11() {
  var o = new core.List<api.Tag>();
  o.add(buildTag());
  o.add(buildTag());
  return o;
}

checkUnnamed11(core.List<api.Tag> o) {
  unittest.expect(o, unittest.hasLength(2));
  checkTag(o[0]);
  checkTag(o[1]);
}

buildUnnamed12() {
  var o = new core.List<api.Tag>();
  o.add(buildTag());
  o.add(buildTag());
  return o;
}

checkUnnamed12(core.List<api.Tag> o) {
  unittest.expect(o, unittest.hasLength(2));
  checkTag(o[0]);
  checkTag(o[1]);
}

core.int buildCounterReplaceTagsRequest = 0;
buildReplaceTagsRequest() {
  var o = new api.ReplaceTagsRequest();
  buildCounterReplaceTagsRequest++;
  if (buildCounterReplaceTagsRequest < 3) {
    o.newTags = buildUnnamed11();
    o.originalTags = buildUnnamed12();
  }
  buildCounterReplaceTagsRequest--;
  return o;
}

checkReplaceTagsRequest(api.ReplaceTagsRequest o) {
  buildCounterReplaceTagsRequest++;
  if (buildCounterReplaceTagsRequest < 3) {
    checkUnnamed11(o.newTags);
    checkUnnamed12(o.originalTags);
  }
  buildCounterReplaceTagsRequest--;
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

core.int buildCounterStringResponse = 0;
buildStringResponse() {
  var o = new api.StringResponse();
  buildCounterStringResponse++;
  if (buildCounterStringResponse < 3) {
    o.data = "foo";
  }
  buildCounterStringResponse--;
  return o;
}

checkStringResponse(api.StringResponse o) {
  buildCounterStringResponse++;
  if (buildCounterStringResponse < 3) {
    unittest.expect(o.data, unittest.equals('foo'));
  }
  buildCounterStringResponse--;
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

core.int buildCounterTagInfo = 0;
buildTagInfo() {
  var o = new api.TagInfo();
  buildCounterTagInfo++;
  if (buildCounterTagInfo < 3) {
    o.category = "foo";
    o.count = 42;
    o.id = "foo";
    o.redirect = buildTag();
  }
  buildCounterTagInfo--;
  return o;
}

checkTagInfo(api.TagInfo o) {
  buildCounterTagInfo++;
  if (buildCounterTagInfo < 3) {
    unittest.expect(o.category, unittest.equals('foo'));
    unittest.expect(o.count, unittest.equals(42));
    unittest.expect(o.id, unittest.equals('foo'));
    checkTag(o.redirect);
  }
  buildCounterTagInfo--;
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
  unittest.group("obj-schema-CountResponse", () {
    unittest.test("to-json--from-json", () {
      var o = buildCountResponse();
      var od = new api.CountResponse.fromJson(o.toJson());
      checkCountResponse(od);
    });
  });


  unittest.group("obj-schema-CreateItemRequest", () {
    unittest.test("to-json--from-json", () {
      var o = buildCreateItemRequest();
      var od = new api.CreateItemRequest.fromJson(o.toJson());
      checkCreateItemRequest(od);
    });
  });


  unittest.group("obj-schema-ExtensionData", () {
    unittest.test("to-json--from-json", () {
      var o = buildExtensionData();
      var od = new api.ExtensionData.fromJson(o.toJson());
      checkExtensionData(od);
    });
  });


  unittest.group("obj-schema-IdRequest", () {
    unittest.test("to-json--from-json", () {
      var o = buildIdRequest();
      var od = new api.IdRequest.fromJson(o.toJson());
      checkIdRequest(od);
    });
  });


  unittest.group("obj-schema-IdResponse", () {
    unittest.test("to-json--from-json", () {
      var o = buildIdResponse();
      var od = new api.IdResponse.fromJson(o.toJson());
      checkIdResponse(od);
    });
  });


  unittest.group("obj-schema-ImportPathRequest", () {
    unittest.test("to-json--from-json", () {
      var o = buildImportPathRequest();
      var od = new api.ImportPathRequest.fromJson(o.toJson());
      checkImportPathRequest(od);
    });
  });


  unittest.group("obj-schema-ImportResult", () {
    unittest.test("to-json--from-json", () {
      var o = buildImportResult();
      var od = new api.ImportResult.fromJson(o.toJson());
      checkImportResult(od);
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


  unittest.group("obj-schema-ListOfTagInfo", () {
    unittest.test("to-json--from-json", () {
      var o = buildListOfTagInfo();
      var od = new api.ListOfTagInfo.fromJson(o.toJson());
      checkListOfTagInfo(od);
    });
  });


  unittest.group("obj-schema-MediaMessage", () {
    unittest.test("to-json--from-json", () {
      var o = buildMediaMessage();
      var od = new api.MediaMessage.fromJson(o.toJson());
      checkMediaMessage(od);
    });
  });


  unittest.group("obj-schema-PaginatedExtensionDataResponse", () {
    unittest.test("to-json--from-json", () {
      var o = buildPaginatedExtensionDataResponse();
      var od = new api.PaginatedExtensionDataResponse.fromJson(o.toJson());
      checkPaginatedExtensionDataResponse(od);
    });
  });


  unittest.group("obj-schema-PaginatedImportResultsResponse", () {
    unittest.test("to-json--from-json", () {
      var o = buildPaginatedImportResultsResponse();
      var od = new api.PaginatedImportResultsResponse.fromJson(o.toJson());
      checkPaginatedImportResultsResponse(od);
    });
  });


  unittest.group("obj-schema-PaginatedItemResponse", () {
    unittest.test("to-json--from-json", () {
      var o = buildPaginatedItemResponse();
      var od = new api.PaginatedItemResponse.fromJson(o.toJson());
      checkPaginatedItemResponse(od);
    });
  });


  unittest.group("obj-schema-PaginatedTagResponse", () {
    unittest.test("to-json--from-json", () {
      var o = buildPaginatedTagResponse();
      var od = new api.PaginatedTagResponse.fromJson(o.toJson());
      checkPaginatedTagResponse(od);
    });
  });


  unittest.group("obj-schema-PasswordChangeRequest", () {
    unittest.test("to-json--from-json", () {
      var o = buildPasswordChangeRequest();
      var od = new api.PasswordChangeRequest.fromJson(o.toJson());
      checkPasswordChangeRequest(od);
    });
  });


  unittest.group("obj-schema-ReplaceTagsRequest", () {
    unittest.test("to-json--from-json", () {
      var o = buildReplaceTagsRequest();
      var od = new api.ReplaceTagsRequest.fromJson(o.toJson());
      checkReplaceTagsRequest(od);
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


  unittest.group("obj-schema-StringResponse", () {
    unittest.test("to-json--from-json", () {
      var o = buildStringResponse();
      var od = new api.StringResponse.fromJson(o.toJson());
      checkStringResponse(od);
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


  unittest.group("obj-schema-TagInfo", () {
    unittest.test("to-json--from-json", () {
      var o = buildTagInfo();
      var od = new api.TagInfo.fromJson(o.toJson());
      checkTagInfo(od);
    });
  });


  unittest.group("obj-schema-User", () {
    unittest.test("to-json--from-json", () {
      var o = buildUser();
      var od = new api.User.fromJson(o.toJson());
      checkUser(od);
    });
  });


  unittest.group("resource-ExtensionDataResourceApi", () {
    unittest.test("method--delete", () {

      var mock = new HttpServerMock();
      api.ExtensionDataResourceApi res = new api.GalleryApi(mock).extensionData;
      var arg_extensionId = "foo";
      var arg_key = "foo";
      var arg_primaryId = "foo";
      var arg_secondaryId = "foo";
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 15), unittest.equals("extension_data/"));
        pathOffset += 15;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_extensionId"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_key"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_primaryId"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_secondaryId"));
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
      res.delete(arg_extensionId, arg_key, arg_primaryId, arg_secondaryId).then(unittest.expectAsync1((_) {}));
    });

    unittest.test("method--get", () {

      var mock = new HttpServerMock();
      api.ExtensionDataResourceApi res = new api.GalleryApi(mock).extensionData;
      var arg_extensionId = "foo";
      var arg_key = "foo";
      var arg_orderByValues = true;
      var arg_orderDescending = true;
      var arg_page = 42;
      var arg_perPage = 42;
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 15), unittest.equals("extension_data/"));
        pathOffset += 15;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_extensionId"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_key"));
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
        unittest.expect(queryMap["orderByValues"].first, unittest.equals("$arg_orderByValues"));
        unittest.expect(queryMap["orderDescending"].first, unittest.equals("$arg_orderDescending"));
        unittest.expect(core.int.parse(queryMap["page"].first), unittest.equals(arg_page));
        unittest.expect(core.int.parse(queryMap["perPage"].first), unittest.equals(arg_perPage));


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildPaginatedExtensionDataResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.get(arg_extensionId, arg_key, orderByValues: arg_orderByValues, orderDescending: arg_orderDescending, page: arg_page, perPage: arg_perPage).then(unittest.expectAsync1(((api.PaginatedExtensionDataResponse response) {
        checkPaginatedExtensionDataResponse(response);
      })));
    });

    unittest.test("method--getByPrimaryAndSecondaryId", () {

      var mock = new HttpServerMock();
      api.ExtensionDataResourceApi res = new api.GalleryApi(mock).extensionData;
      var arg_extensionId = "foo";
      var arg_key = "foo";
      var arg_primaryId = "foo";
      var arg_secondaryId = "foo";
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 15), unittest.equals("extension_data/"));
        pathOffset += 15;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_extensionId"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_key"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_primaryId"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_secondaryId"));
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
        var resp = convert.JSON.encode(buildPaginatedExtensionDataResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.getByPrimaryAndSecondaryId(arg_extensionId, arg_key, arg_primaryId, arg_secondaryId).then(unittest.expectAsync1(((api.PaginatedExtensionDataResponse response) {
        checkPaginatedExtensionDataResponse(response);
      })));
    });

    unittest.test("method--getByPrimaryId", () {

      var mock = new HttpServerMock();
      api.ExtensionDataResourceApi res = new api.GalleryApi(mock).extensionData;
      var arg_extensionId = "foo";
      var arg_key = "foo";
      var arg_primaryId = "foo";
      var arg_bidirectional = true;
      var arg_orderByValues = true;
      var arg_orderDescending = true;
      var arg_page = 42;
      var arg_perPage = 42;
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 15), unittest.equals("extension_data/"));
        pathOffset += 15;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_extensionId"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_key"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_primaryId"));
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
        unittest.expect(queryMap["bidirectional"].first, unittest.equals("$arg_bidirectional"));
        unittest.expect(queryMap["orderByValues"].first, unittest.equals("$arg_orderByValues"));
        unittest.expect(queryMap["orderDescending"].first, unittest.equals("$arg_orderDescending"));
        unittest.expect(core.int.parse(queryMap["page"].first), unittest.equals(arg_page));
        unittest.expect(core.int.parse(queryMap["perPage"].first), unittest.equals(arg_perPage));


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildPaginatedExtensionDataResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.getByPrimaryId(arg_extensionId, arg_key, arg_primaryId, bidirectional: arg_bidirectional, orderByValues: arg_orderByValues, orderDescending: arg_orderDescending, page: arg_page, perPage: arg_perPage).then(unittest.expectAsync1(((api.PaginatedExtensionDataResponse response) {
        checkPaginatedExtensionDataResponse(response);
      })));
    });

  });


  unittest.group("resource-ImportResourceApi", () {
    unittest.test("method--clearResults", () {

      var mock = new HttpServerMock();
      api.ImportResourceApi res = new api.GalleryApi(mock).import;
      var arg_everything = true;
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 15), unittest.equals("import/results/"));
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
        unittest.expect(queryMap["everything"].first, unittest.equals("$arg_everything"));


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = "";
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.clearResults(everything: arg_everything).then(unittest.expectAsync1((_) {}));
    });

    unittest.test("method--getResults", () {

      var mock = new HttpServerMock();
      api.ImportResourceApi res = new api.GalleryApi(mock).import;
      var arg_page = 42;
      var arg_perPage = 42;
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 15), unittest.equals("import/results/"));
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
        unittest.expect(core.int.parse(queryMap["page"].first), unittest.equals(arg_page));
        unittest.expect(core.int.parse(queryMap["perPage"].first), unittest.equals(arg_perPage));


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildPaginatedImportResultsResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.getResults(page: arg_page, perPage: arg_perPage).then(unittest.expectAsync1(((api.PaginatedImportResultsResponse response) {
        checkPaginatedImportResultsResponse(response);
      })));
    });

    unittest.test("method--importFromPath", () {

      var mock = new HttpServerMock();
      api.ImportResourceApi res = new api.GalleryApi(mock).import;
      var arg_request = buildImportPathRequest();
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var obj = new api.ImportPathRequest.fromJson(json);
        checkImportPathRequest(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 15), unittest.equals("import/results/"));
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
        var resp = convert.JSON.encode(buildStringResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.importFromPath(arg_request).then(unittest.expectAsync1(((api.StringResponse response) {
        checkStringResponse(response);
      })));
    });

  });


  unittest.group("resource-ItemsResourceApi", () {
    unittest.test("method--createItem", () {

      var mock = new HttpServerMock();
      api.ItemsResourceApi res = new api.GalleryApi(mock).items;
      var arg_request = buildCreateItemRequest();
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var obj = new api.CreateItemRequest.fromJson(json);
        checkCreateItemRequest(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
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
      res.createItem(arg_request).then(unittest.expectAsync1(((api.IdResponse response) {
        checkIdResponse(response);
      })));
    });

    unittest.test("method--delete", () {

      var mock = new HttpServerMock();
      api.ItemsResourceApi res = new api.GalleryApi(mock).items;
      var arg_id = "foo";
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
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
      res.delete(arg_id).then(unittest.expectAsync1((_) {}));
    });

    unittest.test("method--getById", () {

      var mock = new HttpServerMock();
      api.ItemsResourceApi res = new api.GalleryApi(mock).items;
      var arg_id = "foo";
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
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
      res.getById(arg_id).then(unittest.expectAsync1(((api.Item response) {
        checkItem(response);
      })));
    });

    unittest.test("method--getTagsByItemId", () {

      var mock = new HttpServerMock();
      api.ItemsResourceApi res = new api.GalleryApi(mock).items;
      var arg_id = "foo";
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("items/"));
        pathOffset += 6;
        index = path.indexOf("/tags/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_id"));
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("/tags/"));
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
        var resp = convert.JSON.encode(buildListOfTag());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.getTagsByItemId(arg_id).then(unittest.expectAsync1(((api.ListOfTag response) {
        checkListOfTag(response);
      })));
    });

    unittest.test("method--getVisibleIds", () {

      var mock = new HttpServerMock();
      api.ItemsResourceApi res = new api.GalleryApi(mock).items;
      var arg_page = 42;
      var arg_perPage = 42;
      var arg_cutoffDate = "foo";
      var arg_inTrash = true;
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
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
        unittest.expect(queryMap["cutoffDate"].first, unittest.equals(arg_cutoffDate));
        unittest.expect(queryMap["inTrash"].first, unittest.equals("$arg_inTrash"));


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildPaginatedItemResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.getVisibleIds(page: arg_page, perPage: arg_perPage, cutoffDate: arg_cutoffDate, inTrash: arg_inTrash).then(unittest.expectAsync1(((api.PaginatedItemResponse response) {
        checkPaginatedItemResponse(response);
      })));
    });

    unittest.test("method--mergeItems", () {

      var mock = new HttpServerMock();
      api.ItemsResourceApi res = new api.GalleryApi(mock).items;
      var arg_request = buildIdRequest();
      var arg_targetItemId = "foo";
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var obj = new api.IdRequest.fromJson(json);
        checkIdRequest(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("items/"));
        pathOffset += 6;
        index = path.indexOf("/merge/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_targetItemId"));
        unittest.expect(path.substring(pathOffset, pathOffset + 7), unittest.equals("/merge/"));
        pathOffset += 7;

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
      res.mergeItems(arg_request, arg_targetItemId).then(unittest.expectAsync1(((api.Item response) {
        checkItem(response);
      })));
    });

    unittest.test("method--searchVisible", () {

      var mock = new HttpServerMock();
      api.ItemsResourceApi res = new api.GalleryApi(mock).items;
      var arg_tags = "foo";
      var arg_page = 42;
      var arg_perPage = 42;
      var arg_cutoffDate = "foo";
      var arg_inTrash = true;
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 13), unittest.equals("search/items/"));
        pathOffset += 13;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_tags"));
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
        unittest.expect(queryMap["cutoffDate"].first, unittest.equals(arg_cutoffDate));
        unittest.expect(queryMap["inTrash"].first, unittest.equals("$arg_inTrash"));


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildPaginatedItemResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.searchVisible(arg_tags, page: arg_page, perPage: arg_perPage, cutoffDate: arg_cutoffDate, inTrash: arg_inTrash).then(unittest.expectAsync1(((api.PaginatedItemResponse response) {
        checkPaginatedItemResponse(response);
      })));
    });

    unittest.test("method--update", () {

      var mock = new HttpServerMock();
      api.ItemsResourceApi res = new api.GalleryApi(mock).items;
      var arg_request = buildItem();
      var arg_id = "foo";
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var obj = new api.Item.fromJson(json);
        checkItem(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
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
      res.update(arg_request, arg_id).then(unittest.expectAsync1(((api.IdResponse response) {
        checkIdResponse(response);
      })));
    });

    unittest.test("method--updateTagsForItemId", () {

      var mock = new HttpServerMock();
      api.ItemsResourceApi res = new api.GalleryApi(mock).items;
      var arg_request = buildListOfTag();
      var arg_id = "foo";
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var obj = new api.ListOfTag.fromJson(json);
        checkListOfTag(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("items/"));
        pathOffset += 6;
        index = path.indexOf("/tags/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_id"));
        unittest.expect(path.substring(pathOffset, pathOffset + 6), unittest.equals("/tags/"));
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
        var resp = "";
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.updateTagsForItemId(arg_request, arg_id).then(unittest.expectAsync1((_) {}));
    });

  });


  unittest.group("resource-SetupResourceApi", () {
    unittest.test("method--apply", () {

      var mock = new HttpServerMock();
      api.SetupResourceApi res = new api.GalleryApi(mock).setup;
      var arg_request = buildSetupRequest();
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var obj = new api.SetupRequest.fromJson(json);
        checkSetupRequest(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
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
      res.apply(arg_request).then(unittest.expectAsync1(((api.SetupResponse response) {
        checkSetupResponse(response);
      })));
    });

    unittest.test("method--get", () {

      var mock = new HttpServerMock();
      api.SetupResourceApi res = new api.GalleryApi(mock).setup;
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
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
      res.get().then(unittest.expectAsync1(((api.SetupResponse response) {
        checkSetupResponse(response);
      })));
    });

  });


  unittest.group("resource-TagCategoriesResourceApi", () {
    unittest.test("method--create", () {

      var mock = new HttpServerMock();
      api.TagCategoriesResourceApi res = new api.GalleryApi(mock).tagCategories;
      var arg_request = buildTagCategory();
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var obj = new api.TagCategory.fromJson(json);
        checkTagCategory(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
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
      res.create(arg_request).then(unittest.expectAsync1(((api.IdResponse response) {
        checkIdResponse(response);
      })));
    });

    unittest.test("method--delete", () {

      var mock = new HttpServerMock();
      api.TagCategoriesResourceApi res = new api.GalleryApi(mock).tagCategories;
      var arg_id = "foo";
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
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
      res.delete(arg_id).then(unittest.expectAsync1((_) {}));
    });

    unittest.test("method--getAllIds", () {

      var mock = new HttpServerMock();
      api.TagCategoriesResourceApi res = new api.GalleryApi(mock).tagCategories;
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
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
      res.getAllIds().then(unittest.expectAsync1(((api.ListOfString response) {
        checkListOfString(response);
      })));
    });

    unittest.test("method--getById", () {

      var mock = new HttpServerMock();
      api.TagCategoriesResourceApi res = new api.GalleryApi(mock).tagCategories;
      var arg_id = "foo";
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
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
      res.getById(arg_id).then(unittest.expectAsync1(((api.TagCategory response) {
        checkTagCategory(response);
      })));
    });

    unittest.test("method--update", () {

      var mock = new HttpServerMock();
      api.TagCategoriesResourceApi res = new api.GalleryApi(mock).tagCategories;
      var arg_request = buildTagCategory();
      var arg_id = "foo";
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var obj = new api.TagCategory.fromJson(json);
        checkTagCategory(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
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
      res.update(arg_request, arg_id).then(unittest.expectAsync1(((api.IdResponse response) {
        checkIdResponse(response);
      })));
    });

  });


  unittest.group("resource-TagsResourceApi", () {
    unittest.test("method--clearRedirect", () {

      var mock = new HttpServerMock();
      api.TagsResourceApi res = new api.GalleryApi(mock).tags;
      var arg_id = "foo";
      var arg_category = "foo";
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 14), unittest.equals("tag_redirects/"));
        pathOffset += 14;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_id"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_category"));
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
      res.clearRedirect(arg_id, arg_category).then(unittest.expectAsync1((_) {}));
    });

    unittest.test("method--clearRedirectWithoutCategory", () {

      var mock = new HttpServerMock();
      api.TagsResourceApi res = new api.GalleryApi(mock).tags;
      var arg_id = "foo";
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 14), unittest.equals("tag_redirects/"));
        pathOffset += 14;
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
      res.clearRedirectWithoutCategory(arg_id).then(unittest.expectAsync1((_) {}));
    });

    unittest.test("method--delete", () {

      var mock = new HttpServerMock();
      api.TagsResourceApi res = new api.GalleryApi(mock).tags;
      var arg_id = "foo";
      var arg_category = "foo";
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 4), unittest.equals("tag/"));
        pathOffset += 4;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_id"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_category"));
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
        var resp = convert.JSON.encode(buildCountResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.delete(arg_id, arg_category).then(unittest.expectAsync1(((api.CountResponse response) {
        checkCountResponse(response);
      })));
    });

    unittest.test("method--deleteWithoutCategory", () {

      var mock = new HttpServerMock();
      api.TagsResourceApi res = new api.GalleryApi(mock).tags;
      var arg_id = "foo";
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 4), unittest.equals("tag/"));
        pathOffset += 4;
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
        var resp = convert.JSON.encode(buildCountResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.deleteWithoutCategory(arg_id).then(unittest.expectAsync1(((api.CountResponse response) {
        checkCountResponse(response);
      })));
    });

    unittest.test("method--getAllTagInfo", () {

      var mock = new HttpServerMock();
      api.TagsResourceApi res = new api.GalleryApi(mock).tags;
      var arg_page = 42;
      var arg_perPage = 42;
      var arg_countAsc = true;
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 5), unittest.equals("tags/"));
        pathOffset += 5;

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
        unittest.expect(queryMap["countAsc"].first, unittest.equals("$arg_countAsc"));


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildPaginatedTagResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.getAllTagInfo(page: arg_page, perPage: arg_perPage, countAsc: arg_countAsc).then(unittest.expectAsync1(((api.PaginatedTagResponse response) {
        checkPaginatedTagResponse(response);
      })));
    });

    unittest.test("method--getRedirects", () {

      var mock = new HttpServerMock();
      api.TagsResourceApi res = new api.GalleryApi(mock).tags;
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 14), unittest.equals("tag_redirects/"));
        pathOffset += 14;

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
        var resp = convert.JSON.encode(buildListOfTagInfo());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.getRedirects().then(unittest.expectAsync1(((api.ListOfTagInfo response) {
        checkListOfTagInfo(response);
      })));
    });

    unittest.test("method--getTagInfo", () {

      var mock = new HttpServerMock();
      api.TagsResourceApi res = new api.GalleryApi(mock).tags;
      var arg_id = "foo";
      var arg_category = "foo";
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 5), unittest.equals("tags/"));
        pathOffset += 5;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_id"));
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        index = path.indexOf("/", pathOffset);
        unittest.expect(index >= 0, unittest.isTrue);
        subPart = core.Uri.decodeQueryComponent(path.substring(pathOffset, index));
        pathOffset = index;
        unittest.expect(subPart, unittest.equals("$arg_category"));
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
        var resp = convert.JSON.encode(buildTagInfo());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.getTagInfo(arg_id, arg_category).then(unittest.expectAsync1(((api.TagInfo response) {
        checkTagInfo(response);
      })));
    });

    unittest.test("method--getTagInfoWithoutCategory", () {

      var mock = new HttpServerMock();
      api.TagsResourceApi res = new api.GalleryApi(mock).tags;
      var arg_id = "foo";
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 5), unittest.equals("tags/"));
        pathOffset += 5;
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
        var resp = convert.JSON.encode(buildTagInfo());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.getTagInfoWithoutCategory(arg_id).then(unittest.expectAsync1(((api.TagInfo response) {
        checkTagInfo(response);
      })));
    });

    unittest.test("method--replace", () {

      var mock = new HttpServerMock();
      api.TagsResourceApi res = new api.GalleryApi(mock).tags;
      var arg_request = buildReplaceTagsRequest();
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var obj = new api.ReplaceTagsRequest.fromJson(json);
        checkReplaceTagsRequest(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 5), unittest.equals("tags/"));
        pathOffset += 5;

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
        var resp = convert.JSON.encode(buildCountResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.replace(arg_request).then(unittest.expectAsync1(((api.CountResponse response) {
        checkCountResponse(response);
      })));
    });

    unittest.test("method--resetTagInfo", () {

      var mock = new HttpServerMock();
      api.TagsResourceApi res = new api.GalleryApi(mock).tags;
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 9), unittest.equals("tag_info/"));
        pathOffset += 9;

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
      res.resetTagInfo().then(unittest.expectAsync1((_) {}));
    });

    unittest.test("method--search", () {

      var mock = new HttpServerMock();
      api.TagsResourceApi res = new api.GalleryApi(mock).tags;
      var arg_query = "foo";
      var arg_page = 42;
      var arg_perPage = 42;
      var arg_countAsc = true;
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 12), unittest.equals("search/tags/"));
        pathOffset += 12;
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
        unittest.expect(core.int.parse(queryMap["page"].first), unittest.equals(arg_page));
        unittest.expect(core.int.parse(queryMap["perPage"].first), unittest.equals(arg_perPage));
        unittest.expect(queryMap["countAsc"].first, unittest.equals("$arg_countAsc"));


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildPaginatedTagResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.search(arg_query, page: arg_page, perPage: arg_perPage, countAsc: arg_countAsc).then(unittest.expectAsync1(((api.PaginatedTagResponse response) {
        checkPaginatedTagResponse(response);
      })));
    });

    unittest.test("method--setRedirect", () {

      var mock = new HttpServerMock();
      api.TagsResourceApi res = new api.GalleryApi(mock).tags;
      var arg_request = buildTagInfo();
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var obj = new api.TagInfo.fromJson(json);
        checkTagInfo(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
        unittest.expect(path.substring(pathOffset, pathOffset + 14), unittest.equals("tag_redirects/"));
        pathOffset += 14;

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
      res.setRedirect(arg_request).then(unittest.expectAsync1((_) {}));
    });

  });


  unittest.group("resource-UsersResourceApi", () {
    unittest.test("method--changePassword", () {

      var mock = new HttpServerMock();
      api.UsersResourceApi res = new api.GalleryApi(mock).users;
      var arg_request = buildPasswordChangeRequest();
      var arg_uuid = "foo";
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var obj = new api.PasswordChangeRequest.fromJson(json);
        checkPasswordChangeRequest(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
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
      res.changePassword(arg_request, arg_uuid).then(unittest.expectAsync1((_) {}));
    });

    unittest.test("method--create", () {

      var mock = new HttpServerMock();
      api.UsersResourceApi res = new api.GalleryApi(mock).users;
      var arg_request = buildUser();
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var obj = new api.User.fromJson(json);
        checkUser(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
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
      res.create(arg_request).then(unittest.expectAsync1(((api.IdResponse response) {
        checkIdResponse(response);
      })));
    });

    unittest.test("method--delete", () {

      var mock = new HttpServerMock();
      api.UsersResourceApi res = new api.GalleryApi(mock).users;
      var arg_uuid = "foo";
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
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
      res.delete(arg_uuid).then(unittest.expectAsync1((_) {}));
    });

    unittest.test("method--getById", () {

      var mock = new HttpServerMock();
      api.UsersResourceApi res = new api.GalleryApi(mock).users;
      var arg_uuid = "foo";
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
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
      res.getById(arg_uuid).then(unittest.expectAsync1(((api.User response) {
        checkUser(response);
      })));
    });

    unittest.test("method--getMe", () {

      var mock = new HttpServerMock();
      api.UsersResourceApi res = new api.GalleryApi(mock).users;
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
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
      res.getMe().then(unittest.expectAsync1(((api.User response) {
        checkUser(response);
      })));
    });

    unittest.test("method--update", () {

      var mock = new HttpServerMock();
      api.UsersResourceApi res = new api.GalleryApi(mock).users;
      var arg_request = buildUser();
      var arg_uuid = "foo";
      mock.register(unittest.expectAsync2((http.BaseRequest req, json) {
        var obj = new api.User.fromJson(json);
        checkUser(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 17), unittest.equals("api/gallery/v0.1/"));
        pathOffset += 17;
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
      res.update(arg_request, arg_uuid).then(unittest.expectAsync1(((api.IdResponse response) {
        checkIdResponse(response);
      })));
    });

  });


}

