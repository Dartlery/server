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

const String testTagName = "TEST TAG";
const String testCategoryName = "TEST CATEGORY";

void main() {
  //Tag tag;

  CreateItemRequest request;
  Tag initialTag, initialCategoryTag;

  setUp(() async {
    if (server != null) throw new Exception("Server already exists");

    server = await setUpServer();
    initialTag = new Tag.withValues(testTagName);
    initialCategoryTag = new Tag.withValues(testTagName, category: testCategoryName);
    await api.tagCategories.create(new TagCategory.withValues(testCategoryName));
    request = await createItemRequest(tags: <Tag>[initialTag, initialCategoryTag, new Tag.withValues(generateUuid())]);
  });

  tearDown(() async {
    await tearDownServer(server);
    server = null;
  });


  group("Method tests", () {
    test("search()", () async {
      //final IdResponse response =
      await api.items.createItem(request);

      final List<Tag> tags = await api.tags.search(testTagName);

      expect(tags.length, 2);
      expect(tags.first.id, testTagName);
    });

    test("update()", () async {
      final IdResponse response =
      await api.items.createItem(request);

      final Tag newTag = new Tag.withValues(generateUuid());

      await api.tags.update(initialCategoryTag.id, initialCategoryTag.category, newTag);

      final Item i = await api.items.getById(response.id);

      expect(i.tags.length, 3);
      expect(i.tags.where((Tag t) => t.id==newTag.id&&t.category==newTag.category).length, 1);
      expect(i.tags.where((Tag t) => t.id!=newTag.id||t.category!=newTag.category).length, 2);
    });

    test("updateWithoutCategory()", () async {
      final IdResponse response =
      await api.items.createItem(request);

      final Tag newTag = new Tag.withValues(generateUuid());

      await api.tags.updateWithoutCategory(initialTag.id, newTag);

      final Item i = await api.items.getById(response.id);

      expect(i.tags.length, 3);
      expect(i.tags.where((Tag t) => t.id==newTag.id&&t.category==newTag.category).length, 1);
      expect(i.tags.where((Tag t) => t.id!=newTag.id||t.category!=newTag.category).length, 2);
    });

    test("replace()", () async {
      final IdResponse response =
      await api.items.createItem(request);

      final Tag newTag = new Tag.withValues(generateUuid());

      final ReplaceTagsRequest replaceRequest = new ReplaceTagsRequest();
      replaceRequest.originalTags = [initialTag, initialCategoryTag];
      replaceRequest.newTags = [newTag];

      await api.tags.replace(replaceRequest);

      final Item i = await api.items.getById(response.id);

      expect(i.tags.length, 2);
      expect(i.tags.where((Tag t) => t.id==newTag.id&&t.category==newTag.category).length, 1);
      expect(i.tags.where((Tag t) => t.id!=newTag.id||t.category!=newTag.category).length, 1);
    });


    test("setRedirect()", () async {
      final IdResponse response =
      await api.items.createItem(request);

      final Tag newTag = new Tag.withValues(generateUuid());

      final TagRedirectRequest redirectRequest = new TagRedirectRequest();
      redirectRequest.startTag = initialTag;
      redirectRequest.endTag = initialCategoryTag;

      await api.tags.setRedirect(redirectRequest);

      final Item i = await api.items.getById(response.id);

      expect(i.tags.length, 2);
      expect(i.tags.where((Tag t) => t.id==initialCategoryTag.id&&t.category==initialCategoryTag.category).length, 1);
      expect(i.tags.where((Tag t) => t.id!=initialCategoryTag.id||t.category!=initialCategoryTag.category).length, 1);
    });


  });
}
