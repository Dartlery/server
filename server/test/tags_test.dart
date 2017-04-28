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

void main() {
  //Tag tag;

  CreateItemRequest request;

  setUp(() async {
    if (server != null) throw new Exception("Server already exists");

    server = await setUpServer();
    //tag = createTag();
    request = await createItemRequest(tags: <Tag>[new Tag.withValues(testTagName)]);
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

      expect(tags.length, 1);
      expect(tags.first.id, testTagName);
    });


  });
}
