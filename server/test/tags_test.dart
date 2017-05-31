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
  IdResponse initalItemId;
  setUp(() async {
    if (server != null) throw new Exception("Server already exists");

    server = await setUpServer();
    initialTag = new Tag.withValues(testTagName);
    initialCategoryTag = new Tag.withValues(testTagName, category: testCategoryName);
    randomTag = new Tag.withValues(generateUuid());
    await api.tagCategories.create(new TagCategory.withValues(testCategoryName));
    request = await createItemRequest(tags: <Tag>[initialTag, initialCategoryTag, randomTag]);

    initalItemId =
    await api.items.createItem(request);

  });

  tearDown(() async {
    await tearDownServer(server);
    server = null;
  });


  group("Method tests", () {
    test("search()", () async {
      final List<Tag> tags = await api.tags.search(testTagName);

      expect(tags.length, 2);
      expect(tags.first==initialCategoryTag, isTrue);
      expect(tags[1]==initialTag, isTrue);
    });

    test("update()", () async {
      final Tag newTag = new Tag.withValues(generateUuid());

      await api.tags.update(initialCategoryTag.id, initialCategoryTag.category, newTag);

      final Item i = await api.items.getById(initalItemId.id);

      expect(i.tags.length, 3);
      expect(i.tags[0]==initialTag, isTrue);
      expect(i.tags[1]==randomTag, isTrue);
      expect(i.tags[2]==newTag, isTrue);
    });

    test("updateWithoutCategory()", () async {
      final Tag newTag = new Tag.withValues(generateUuid());

      await api.tags.updateWithoutCategory(initialTag.id, newTag);

      final Item i = await api.items.getById(initalItemId.id);

      expect(i.tags.length, 3);
      expect(i.tags[0]==initialCategoryTag, isTrue);
      expect(i.tags[1]==randomTag, isTrue);
      expect(i.tags[2]==newTag, isTrue);
    });

    test("replace()", () async {
      final Tag newTag = new Tag.withValues(generateUuid());

      final ReplaceTagsRequest replaceRequest = new ReplaceTagsRequest();
      replaceRequest.originalTags = [initialTag, initialCategoryTag];
      replaceRequest.newTags = [newTag];

      await api.tags.replace(replaceRequest);

      final Item i = await api.items.getById(initalItemId.id);

      expect(i.tags.length, 2);
      expect(i.tags[0]==randomTag, isTrue);
      expect(i.tags[1]==newTag, isTrue);
    });


    test("setRedirect()", () async {

      final RedirectingTag redirectRequest = new RedirectingTag();
      redirectRequest.start = initialTag;
      redirectRequest.end = initialCategoryTag;

      await api.tags.setRedirect(redirectRequest);

      final Item i = await api.items.getById(initalItemId.id);

      expect(i.tags.length, 2);
      expect(i.tags[0]==initialCategoryTag, isTrue);
      expect(i.tags[1]==randomTag, isTrue);
    });

    test("clearRedirect()", () async {
      final RedirectingTag redirectRequest = new RedirectingTag();
      redirectRequest.start = initialTag;
      redirectRequest.end = initialCategoryTag;

      await api.tags.setRedirect(redirectRequest);

      Item i = await api.items.getById(initalItemId.id);

      expect(i.tags.length, 2);
      expect(i.tags[0]==initialCategoryTag, isTrue);
      expect(i.tags[1]==randomTag, isTrue);

      await api.tags.clearRedirectWithoutCategory(initialTag.id);

      await api.items.updateTagsForItemId(i.id, [initialTag]);

      i = await api.items.getById(initalItemId.id);

      expect(i.tags.length, 1);
      expect(i.tags[0]==initialTag, isTrue);

    });
  });

  group("Redirect tests", () {
    setUp(() async  {
      final RedirectingTag redirectRequest = new RedirectingTag();
      redirectRequest.start = initialTag;
      redirectRequest.end = initialCategoryTag;

      await api.tags.setRedirect(redirectRequest);
    });


    test("Chained redirect", () async {
      final RedirectingTag redirectRequest = new RedirectingTag();
      redirectRequest.start = initialCategoryTag;
      redirectRequest.end = randomTag;

      await api.tags.setRedirect(redirectRequest);

      final Item i = await api.items.getById(initalItemId.id);

      expect(i.tags.length, 1);
      expect(i.tags[0]==randomTag, isTrue);
    });



    test("Looping redirect", () async {
      RedirectingTag redirectRequest = new RedirectingTag();
      redirectRequest.start = initialCategoryTag;
      redirectRequest.end = randomTag;

      await api.tags.setRedirect(redirectRequest);

      redirectRequest = new RedirectingTag();
      redirectRequest.start = randomTag;
      redirectRequest.end = initialTag;

      expect(api.tags.setRedirect(redirectRequest), throwsInvalidInputException);
    });

    test("Self redirect", () async {
      final RedirectingTag redirectRequest = new RedirectingTag();
      redirectRequest.start = randomTag;
      redirectRequest.end = randomTag;

      expect(api.tags.setRedirect(redirectRequest), throwsDataValidationException);
    });

    test("Item creation", () async {
      await api.items.delete(initalItemId.id);

      await api.items.createItem(request);

      final Item i = await api.items.getById(initalItemId.id);

      expect(i.tags.length, 2);
      expect(i.tags[0]==initialCategoryTag, isTrue);
      expect(i.tags[1]==randomTag, isTrue);

    });

    test("Item tags update", () async {

      final Tag newTag = new Tag.withValues(generateUuid());

      await api.items.updateTagsForItemId(initalItemId.id, [initialTag, newTag]);

      final Item i = await api.items.getById(initalItemId.id);

      expect(i.tags.length, 2);
      expect(i.tags[0]==newTag, isTrue);
      expect(i.tags[1]==initialCategoryTag, isTrue);

    });
  });
}
