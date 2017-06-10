import 'package:options_file/options_file.dart';
import 'package:rpc/rpc.dart';
import 'package:test/test.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:dartlery/model/model.dart';
import 'dart:async';
import 'package:dartlery/api/gallery/gallery_api.dart';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:dartlery/server.dart';
import 'package:dartlery/data_sources/mongo/mongo.dart';
import 'dart:io';
import 'package:dartlery/tools.dart';

const String testAdminPassword = "TESTPASSWORD";
const String testItemName = "TESTITEM";

final Matcher isUnauthorizedException =
    new RpcErrorMatcher<UnauthorizedException>();

final Matcher isForbiddenException = new RpcErrorMatcher<ForbiddenException>();

final Matcher throwsDataValidationException =
    throwsA(new RpcErrorMatcher<DataValidationException>());
final Matcher throwsInvalidInputException =
    throwsA(new RpcErrorMatcher<InvalidInputException>());
final Matcher throwsForbiddenException = throwsA(isForbiddenException);
final Matcher throwsNotFoundException =
    throwsA(new RpcErrorMatcher<NotFoundException>());
final Matcher throwsUnauthorizedException = throwsA(isUnauthorizedException);

final Matcher throwsNotImplementedException =
    throwsA(isNotImplementedException);

final Matcher isNotImplementedException =
    new RpcErrorMatcher<NotImplementedException>();
//const _NotImplementedException();

class _NotImplementedException extends TypeMatcher {
  const _NotImplementedException() : super("NotImplementedException");
  bool matches(item, Map matchState) => item is NotImplementedException;
}

Future<Null> _nukeDatabase(String connectionString) async {
  final MongoDbConnectionPool pool =
      new MongoDbConnectionPool(connectionString);
  await pool.databaseWrapper((MongoDatabase db) => db.nukeDatabase());
}

Future<Server> setUpServer() async {
  final String serverUuid = generateUuid();
  String connectionString =
      "mongodb://127.0.0.1:27017/dartlery_test_$serverUuid";

  try {
    final OptionsFile optionsFile = new OptionsFile('test.options');
    connectionString =
        optionsFile.getString("connection_string", connectionString);
  } on FileSystemException {}

  await _nukeDatabase(connectionString);
  disableSetup();

  final Server server =
      Server.createInstance(connectionString, instanceUuid: serverUuid);

  final String password = testAdminPassword;
  final String uuid = await server.userModel.createUserWith(
      "AdminUser", password, UserPrivilege.admin,
      bypassAuthentication: true);

  final User adminUser =
      await server.userModel.getById(uuid, bypassAuthentication: true);

  AModel.overrideCurrentUser(adminUser.id);

  return server;
}

Future<Null> tearDownServer(Server server) async {
  final MongoDbConnectionPool pool = server.injector.get(MongoDbConnectionPool);
  await pool.closeConnections();
  await _nukeDatabase(server.connectionString);
}

Future<Map<String, User>> createTestUsers(GalleryApi api,
    {List<String> types: const <String>[
      UserPrivilege.admin,
      UserPrivilege.moderator,
      UserPrivilege.normal,
    ]}) async {
  final Map<String, User> output = <String, User>{};
  for (String type in types) {
    final User newUser = new User();
    newUser.password = generateUuid();
    newUser.type = type;
    newUser.id = "${type}User";
    newUser.name = "$type User";
    final IdResponse response = await api.users.create(newUser);
    validateIdResponse(response);
    newUser.id = response.id;
    output[type] = newUser;
  }
  return output;
}

Future<CreateItemRequest> createItemRequest(
    {List<Tag> tags, String file: "test.jpg"}) async {
  final Item item = createItem(tags: tags);
  final CreateItemRequest request = new CreateItemRequest();
  final MediaMessage msg = new MediaMessage();

  msg.bytes = await getFileData("test\\$file");

  request.item = item;
  request.file = msg;

  return request;
}

/// Creates a [Item] object that should meet all validation requirements.
Item createItem({List<Tag> tags}) {
  final Item item = new Item();
  item.fileName = generateUuid();
  if (tags == null) {
    item.tags = <Tag>[];
    item.tags.add(new Tag.withValues(generateUuid()));
    item.tags.add(new Tag.withValues(generateUuid()));
    item.tags.add(new Tag.withValues(generateUuid()));
  } else {
    item.tags = tags;
  }

  return item;
}

TagCategory createTagCategory() {
  final TagCategory tagCategory = new TagCategory();
  tagCategory.id = generateUuid();
  tagCategory.color = "#000000";
  return tagCategory;
}

Tag createTag({String category: null}) {
  final Tag tag = new Tag();
  tag.id = generateUuid();
  tag.category = category;
  return tag;
}

/// Creates a [User] object with the specified [type] that should meet all validation requirements.
User createUser([String type = UserPrivilege.normal]) {
  final User user = new User();
  user.id = "testUser$type" + generateUuid();
  user.name = "TEST $type";
  user.type = type;
  user.password = generateUuid();
  return user;
}

/// Verifies that the [response] is not null and contains a valid uuid
void validateIdResponse(IdResponse response) {
  expect(response, isNotNull);
  expect(response.id, isNotEmpty);
}

/// Allows verifying that API-thrown exceptions were originally of a particular [T]ype.
///
/// The API wraps/translates all exceptions to [RpcError] objects to allow consistent communication of errors to the client.
/// This inspects the error details for a descriptor containing the name of the type of the original exception.
class RpcErrorMatcher<T> extends Matcher {
  @override
  Description describe(Description description) =>
      description.add('an instance of RpcError containing a(n) $T');

  @override
  bool matches(dynamic obj, Map<dynamic, dynamic> matchState) {
    if (obj is RpcError) {
      for (RpcErrorDetail detail in obj.errors) {
        if (detail.locationType == "exceptionType" &&
            detail.location == T.toString()) return true;
      }
    }
    return false;
  }
}
