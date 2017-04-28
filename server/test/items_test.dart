import 'dart:io';
import 'package:rpc/rpc.dart';
import 'package:test/test.dart';
import 'shared/api.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/server.dart';
import 'package:dartlery/api/gallery/gallery_api.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery_shared/global.dart';

Server server;
GalleryApi get api => server.galleryApi;

Map<String,User> users;
void main() {
  CreateItemRequest request;
  Item item;

  setUp(() async {
    if (server != null) throw new Exception("Server already exists");

    server = await setUpServer();

    users = await createTestUsers(api);
    item = createItem();

    final MediaMessage msg = new MediaMessage();

    final File f = new File("test\\test.jpg");
    RandomAccessFile raf;
    try {
      raf = await f.open();
      msg.bytes = <int>[];
      final int length = await raf.length();
      msg.bytes = await raf.read(length);
    } finally {
      if(raf!=null)
        await raf.close();
    }


    request = new CreateItemRequest();
    request.item = item;
    request.files = <MediaMessage>[msg];
    request.item.file = "${fileUploadPrefix}0";
  });

  tearDown(() async {
    await tearDownServer(server);
    server = null;
  });

  group("Item validation", () {

  });

  group("Method tests", ()
  {

    test("create()", () async {
      expect(api.items.create(item), throwsNotImplementedException);
    }, skip: "Not quite working?");

    test("createItem()", () async {
      final IdResponse response  = await api.items.createItem(request);
      validateIdResponse(response);
    });

    test("getById()", () async {
      final IdResponse response  = await api.items.createItem(request);
      item = await api.items.getById(response.id);
      expect(item, isNotNull);
    });

    test("update()", () async {
      final IdResponse response  = await api.items.createItem(request);

      Item item = await api.items.getById(response.id);
      expect(item.tags.length, 3);

      final Tag newTag  = new Tag.withValues("TestTagName", null);
      item.tags = <Tag>[newTag];

      final UpdateItemRequest updateItemRequest = new UpdateItemRequest();
      updateItemRequest.item = item;

      await api.items.updateItem(response.id, updateItemRequest);

      item = await api.items.getById(response.id);

      expect(item.tags.length, 1);
      expect(item.tags[0].id, newTag.id);
    });

    test("delete()", () async {
      final IdResponse response  = await api.items.createItem(request);
      await api.items.delete(response.id);
      expect(
          api.items.getById(response.id), throwsNotFoundException);
    });
  });
}
