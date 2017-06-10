import 'package:test/test.dart';
import 'shared/api.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/server.dart';
import 'package:dartlery/api/gallery/gallery_api.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery/model/model.dart' as model;

Server server;
GalleryApi get api => server.galleryApi;

void main() {
  TagCategory tagCategory;

  setUp(() async {
    if (server != null) throw new Exception("Server already exists");

    server = await setUpServer();
    tagCategory = createTagCategory();
  });

  tearDown(() async {
    await tearDownServer(server);
    server = null;
  });

  group("Tag Category validation", () {
    test("Null ID", () async {
      tagCategory.id = null;
      expect(
          api.tagCategories.create(tagCategory), throwsDataValidationException);
    });
    test("Blank ID", () async {
      tagCategory.id = "";
      expect(
          api.tagCategories.create(tagCategory), throwsDataValidationException);
    });
    test("Null color", () async {
      tagCategory.color = null;
      expect(
          api.tagCategories.create(tagCategory), throwsDataValidationException);
    });
    test("Blank color", () async {
      tagCategory.color = "";
      expect(
          api.tagCategories.create(tagCategory), throwsDataValidationException);
    });
    test("Invalid color", () async {
      tagCategory.color = "not a valid color";
      expect(
          api.tagCategories.create(tagCategory), throwsDataValidationException);
    });
  });

  group("Method tests", () {
    test("create()", () async {
      final IdResponse response = await api.tagCategories.create(tagCategory);
      validateIdResponse(response);
    });
    test("getByUuid()", () async {
      final IdResponse response = await api.tagCategories.create(tagCategory);
      final TagCategory item = await api.tagCategories.getById(response.id);
      expect(item, isNotNull);
    });
    test("getAllIds()", () async {
      await api.tagCategories.create(tagCategory);
      tagCategory = createTagCategory();
      await api.tagCategories.create(tagCategory);

      final List<String> data = await api.tagCategories.getAllIds();
      expect(data, isNotNull);
      expect(data.length, 2);
    });

    test("update()", () async {
      IdResponse response = await api.tagCategories.create(tagCategory);
      final TagCategory item = await api.tagCategories.getById(response.id);
      item.color = "#111111";
      response = await api.tagCategories.update(item.id, item);
      validateIdResponse(response);
    });

    test("delete()", () async {
      final IdResponse response = await api.tagCategories.create(tagCategory);
      await api.tagCategories.delete(response.id);
      expect(api.tagCategories.getById(response.id), throwsNotFoundException);
    });
  });
}
