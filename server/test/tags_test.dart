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
  Tag initialTag, initialCategoryTag, randomTag;
  IdResponse initialItemId;
  setUp(() async {
    if (server != null) throw new Exception("Server already exists");

    server = await setUpServer();
    initialTag = new Tag.withValues(testTagName);
    initialCategoryTag = new Tag.withValues(testTagName, testCategoryName);
    randomTag = new Tag.withValues(generateUuid());
    await api.tagCategories.create(new TagCategory.withValues(testCategoryName));
    request = await createItemRequest(tags: <Tag>[initialTag, initialCategoryTag, randomTag]);

    initialItemId = await api.items.createItem(request);

  });

  tearDown(() async {
    await tearDownServer(server);
    server = null;
  });


  group("Method tests", () {
    test("getTagInfo()", () async {
      final TagInfo info = await api.tags.getTagInfoWithoutCategory(testTagName);
      expect(info, isNotNull);
      expect(info==initialTag, isTrue);
      expect(info.redirect, isNull);
      expect(info.count, 1);
    });

    test("getAllTagInfo()", () async {
      final TagList info = new TagList.from(await api.tags.getAllTagInfo());
      expect(info, isNotNull);
      expect(info.length,3);
    });

    test("resetTagInfo()", () async {
      await api.tags.resetTagInfo();

      final TagInfo info = await api.tags.getTagInfoWithoutCategory(testTagName);
      expect(info, isNotNull);
      expect(info==initialTag, isTrue);
      expect(info.redirect, isNull);
      expect(info.count, 1);
    });

    test("search()", () async {
      final List<Tag> tags = await api.tags.search(testTagName);

      expect(tags.length, 2);
      expect(tags.first==initialCategoryTag, isTrue);
      expect(tags[1]==initialTag, isTrue);
    });


    test("replace()", () async {
      final Tag newTag = new Tag.withValues(generateUuid());

      final ReplaceTagsRequest replaceRequest = new ReplaceTagsRequest();
      replaceRequest.originalTags = [initialTag, initialCategoryTag];
      replaceRequest.newTags = [newTag];

      final CountResponse response =  await api.tags.replace(replaceRequest);
      expect(response.count, 1);

      final Item i = await api.items.getById(initialItemId.id);

      expect(i.tags.length, 2);
      expect(i.tags[0]==randomTag, isTrue);
      expect(i.tags[1]==newTag, isTrue);
    });


    test("setRedirect()", () async {
      final TagInfo redirectRequest = new TagInfo.copy(initialTag, initialCategoryTag);

      await api.tags.setRedirect(redirectRequest);

      final Item i = await api.items.getById(initialItemId.id);

      expect(i.tags.length, 2);
      expect(i.tags[0]==initialCategoryTag, isTrue);
      expect(i.tags[1]==randomTag, isTrue);
    });

    test("delete()", () async {
      final CountResponse response = await api.tags.deleteWithoutCategory(randomTag.id);

      expect(response.count, 1);

      final Item i = await api.items.getById(initialItemId.id);

      expect(i.tags.length, 2);
      expect(i.tags[0]==initialTag, isTrue);
      expect(i.tags[1]==initialCategoryTag, isTrue);
    });

    test("clearRedirect()", () async {
      final TagInfo redirectRequest = new TagInfo.copy(initialTag, initialCategoryTag);

      await api.tags.setRedirect(redirectRequest);

      Item i = await api.items.getById(initialItemId.id);

      expect(i.tags.length, 2);
      expect(i.tags[0]==initialCategoryTag, isTrue);
      expect(i.tags[1]==randomTag, isTrue);

      await api.tags.clearRedirectWithoutCategory(initialTag.id);

      await api.items.updateTagsForItemId(i.id, [initialTag]);

      i = await api.items.getById(initialItemId.id);

      expect(i.tags.length, 1);
      expect(i.tags[0]==initialTag, isTrue);

    });

    test("getRedirects()", () async {
      final TagInfo redirectRequest = new TagInfo.copy(initialTag, initialCategoryTag);

      await api.tags.setRedirect(redirectRequest);

      final List<TagInfo> tags = await api.tags.getRedirects();

      expect(tags.length, 1);
      expect(tags.first==initialTag, isTrue);
      expect(tags.first.redirect, isNotNull);
      expect(tags.first.redirect==initialCategoryTag, isTrue);
    });
  });

  group("Validation tests", () {
    test("Reserved regex chars", () async {
      final TagInfo newTag = new TagInfo.withValues(reservedRegexChars.join(),reservedRegexChars.join());
      await api.items.updateTagsForItemId(initialItemId.id, [newTag]);
      final TagInfo info = await api.tags.getTagInfo(newTag.id, newTag.category);
      expect(info==newTag,isTrue);
    });
  });

  group("Redirect tests", () {
    setUp(() async  {
      final TagInfo redirectRequest = new TagInfo.copy(initialTag, initialCategoryTag);
      await api.tags.setRedirect(redirectRequest);
    });


    test("Chained redirect", () async {
      final TagInfo redirectRequest = new TagInfo.copy(initialCategoryTag, randomTag);

      await api.tags.setRedirect(redirectRequest);

      final Item i = await api.items.getById(initialItemId.id);

      expect(i.tags.length, 1);
      expect(i.tags[0]==randomTag, isTrue);
    });


    test("Multiple redirect", () async {
      final Tag newTag = new Tag.withValues(generateUuid());

      final TagInfo redirectRequest = new TagInfo.copy(randomTag, newTag);

      await api.tags.setRedirect(redirectRequest);

      await api.items.updateTagsForItemId(initialItemId.id, [initialTag, randomTag]);

      final Item i = await api.items.getById(initialItemId.id);

      expect(i.tags.length, 2);
      expect(i.tags[0]==initialCategoryTag, isTrue);
      expect(i.tags[1]==newTag, isTrue);
    });


    test("Looping redirect", () async {
      TagInfo redirectRequest = new TagInfo.copy(initialCategoryTag, randomTag);

      await api.tags.setRedirect(redirectRequest);

      redirectRequest = new TagInfo.copy(randomTag, initialTag);

      expect(api.tags.setRedirect(redirectRequest), throwsInvalidInputException);
    });

    test("Self redirect", () async {
      final TagInfo redirectRequest = new TagInfo.copy(randomTag, randomTag);

      expect(api.tags.setRedirect(redirectRequest), throwsDataValidationException);
    });

    test("Item creation", () async {
      await api.items.delete(initialItemId.id);

      await api.items.createItem(request);

      final Item i = await api.items.getById(initialItemId.id);

      expect(i.tags.length, 2);
      expect(i.tags[0]==initialCategoryTag, isTrue);
      expect(i.tags[1]==randomTag, isTrue);

    });

    test("Item tags update", () async {

      final Tag newTag = new Tag.withValues(generateUuid());

      await api.items.updateTagsForItemId(initialItemId.id, [initialTag, newTag]);

      final Item i = await api.items.getById(initialItemId.id);

      expect(i.tags.length, 2);
      expect(i.tags[1]==newTag, isTrue);
      expect(i.tags[0]==initialCategoryTag, isTrue);
    });

    test("Item update", () async {
      Item i = await api.items.getById(initialItemId.id);

      final Tag newTag = new Tag.withValues(generateUuid());

      i.tags = [initialTag, newTag];

      await api.items.update(i.id, i);

      i = await api.items.getById(initialItemId.id);

      expect(i.tags.length, 2);
      expect(i.tags[1]==newTag, isTrue);
      expect(i.tags[0]==initialCategoryTag, isTrue);
    });

    test("Tag replace", () async {
      Item i = await api.items.getById(initialItemId.id);

      final Tag newTag = new Tag.withValues(generateUuid());

      i.tags = [initialTag, newTag];

      final ReplaceTagsRequest request = new  ReplaceTagsRequest();
      request.originalTags = [initialCategoryTag, randomTag];
      request.newTags = [initialTag];

      await api.tags.replace(request);

      i = await api.items.getById(initialItemId.id);

      expect(i.tags.length, 1);
      expect(i.tags[0]==initialCategoryTag, isTrue);
    });

  });

  group("Tag count tests", () {
    test("Create item", () async  {
      final Tag newTag = new Tag.withValues(generateUuid());
      final CreateItemRequest request = await createItemRequest(file: "test2.JPG", tags: [initialCategoryTag, newTag]);
      await api.items.createItem(request);

      TagInfo info  = await api.tags.getTagInfoWithoutCategory(newTag.id);

      expect(info==newTag, isTrue);
      expect(info.count, 1);

      info = await api.tags.getTagInfo(initialCategoryTag.id, initialCategoryTag.category);

      expect(info==initialCategoryTag, isTrue);
      expect(info.count, 2);

      info = await api.tags.getTagInfoWithoutCategory(initialTag.id);

      expect(info==initialTag, isTrue);
      expect(info.count, 1);
    });

    test("Merge items", () async  {
      final Tag newTag = new Tag.withValues(generateUuid());
      final CreateItemRequest request = await createItemRequest(file: "test2.JPG", tags: [initialCategoryTag, newTag]);
      final IdResponse response = await api.items.createItem(request);

      await api.items.mergeItems(initialItemId.id, new IdRequest.withValue(response.id));

      TagInfo info  = await api.tags.getTagInfoWithoutCategory(newTag.id);

      expect(info==newTag, isTrue);
      expect(info.count, 1);

      info = await api.tags.getTagInfo(initialCategoryTag.id, initialCategoryTag.category);

      expect(info==initialCategoryTag, isTrue);
      expect(info.count, 1);

      info = await api.tags.getTagInfoWithoutCategory(initialTag.id);

      expect(info==initialTag, isTrue);
      expect(info.count, 1);

      info = await api.tags.getTagInfoWithoutCategory(randomTag.id);

      expect(info==randomTag, isTrue);
      expect(info.count, 1);
    });

    test("Update item", () async  {
      final Tag newTag = new Tag.withValues(generateUuid());

      final Item item = await api.items.getById(initialItemId.id);

      item.tags = [initialCategoryTag, newTag];
      
      await api.items.update(item.id, item);

      TagInfo info  = await api.tags.getTagInfoWithoutCategory(newTag.id);

      expect(info==newTag, isTrue);
      expect(info.count, 1);

      info = await api.tags.getTagInfo(initialCategoryTag.id, initialCategoryTag.category);

      expect(info==initialCategoryTag, isTrue);
      expect(info.count, 1);

      info = await api.tags.getTagInfoWithoutCategory(initialTag.id);

      expect(info==initialTag, isTrue);
      expect(info.count, 0);
    });

    test("Update item tags", () async  {
      final Tag newTag = new Tag.withValues(generateUuid());


      await api.items.updateTagsForItemId(initialItemId.id, [initialCategoryTag, newTag]);

      TagInfo info  = await api.tags.getTagInfoWithoutCategory(newTag.id);

      expect(info==newTag, isTrue);
      expect(info.count, 1);

      info = await api.tags.getTagInfo(initialCategoryTag.id, initialCategoryTag.category);

      expect(info==initialCategoryTag, isTrue);
      expect(info.count, 1);

      info = await api.tags.getTagInfoWithoutCategory(initialTag.id);

      expect(info==initialTag, isTrue);
      expect(info.count, 0);
    });

    test("Delete item", () async  {
      await api.items.delete(initialItemId.id);

      TagInfo info  = await api.tags.getTagInfoWithoutCategory(randomTag.id);

      expect(info==randomTag, isTrue);
      expect(info.count, 0);

      info = await api.tags.getTagInfo(initialCategoryTag.id, initialCategoryTag.category);

      expect(info==initialCategoryTag, isTrue);
      expect(info.count, 0);

      info = await api.tags.getTagInfoWithoutCategory(initialTag.id);

      expect(info==initialTag, isTrue);
      expect(info.count, 0);
    });

    test("Replace tags", () async  {
      final Tag newTag = new Tag.withValues(generateUuid());

      final ReplaceTagsRequest request = new ReplaceTagsRequest();
      request.originalTags = [initialTag];
      request.newTags = [newTag];

      await api.tags.replace(request);

      TagInfo info  = await api.tags.getTagInfoWithoutCategory(newTag.id);

      expect(info==newTag, isTrue);
      expect(info.count, 1);

      info = await api.tags.getTagInfo(initialCategoryTag.id, initialCategoryTag.category);

      expect(info==initialCategoryTag, isTrue);
      expect(info.count, 1);

      info = await api.tags.getTagInfoWithoutCategory(initialTag.id);

      expect(info==initialTag, isTrue);
      expect(info.count, 0);
    });

    test("Redirect tag", () async  {
      final Tag newTag = new Tag.withValues(generateUuid());

      final TagInfo redirect = new TagInfo.copy(initialTag, newTag);

      await api.tags.setRedirect(redirect);

      TagInfo info  = await api.tags.getTagInfoWithoutCategory(newTag.id);

      expect(info==newTag, isTrue);
      expect(info.count, 1);

      info = await api.tags.getTagInfo(initialCategoryTag.id, initialCategoryTag.category);

      expect(info==initialCategoryTag, isTrue);
      expect(info.count, 1);

      info = await api.tags.getTagInfoWithoutCategory(initialTag.id);

      expect(info==initialTag, isTrue);
      expect(info.count, 0);

      await api.items.updateTagsForItemId(initialItemId.id, [initialTag]);

      info  = await api.tags.getTagInfoWithoutCategory(newTag.id);

      expect(info==newTag, isTrue);
      expect(info.count, 1);

      info = await api.tags.getTagInfoWithoutCategory(initialTag.id);

      expect(info==initialTag, isTrue);
      expect(info.count, 0);
    });
    test("Delete tag", () async  {
      await api.tags.deleteWithoutCategory(initialTag.id);

      expect(api.tags.getTagInfoWithoutCategory(initialTag.id), throwsNotFoundException);

      final TagInfo info = await api.tags.getTagInfo(initialCategoryTag.id, initialCategoryTag.category);

      expect(info==initialCategoryTag, isTrue);
      expect(info.count, 1);

    });
  });
}
