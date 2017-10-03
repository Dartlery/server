import 'package:test/test.dart';
import 'shared/api.dart';
import 'package:tools/tools.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/server.dart';
import 'package:dartlery/api/gallery/gallery_api.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery/model/model.dart' as model;

DartleryServer server;
GalleryApi get api => server.galleryApi;

void main() {
  setUp(() async {
    if (server != null) throw new Exception("Server already exists");

    server = await setUpServer();
  });

  tearDown(() async {
    await tearDownServer(server);
    server = null;
  });

  group("User validation", () {
    User user;
    setUp(() {
      user = createUser();
    });

    test("Null ID", () async {
      user.id = null;
      expect(api.users.create(user), throwsDataValidationException);
    });
    test("Blank ID", () async {
      user.id = "";
      expect(api.users.create(user), throwsDataValidationException);
    });
    test("Null password", () async {
      user.password = null;
      expect(api.users.create(user), throwsDataValidationException);
    });
    test("Blank password", () async {
      user.password = "";
      expect(api.users.create(user), throwsDataValidationException);
    });
    test("Short password", () async {
      user.password = "1234567";
      expect(api.users.create(user), throwsDataValidationException);
    });
    test("Null name", () async {
      user.name = null;
      expect(api.users.create(user), throwsDataValidationException);
    });
    test("Blank name", () async {
      user.name = "";
      expect(api.users.create(user), throwsDataValidationException);
    });
    test("Null type", () async {
      user.type = null;
      expect(api.users.create(user), throwsDataValidationException);
    });
    test("Blank type", () async {
      user.type = "";
      expect(api.users.create(user), throwsDataValidationException);
    });
    test("Invalid type", () async {
      user.type = "invalidUserType";
      expect(api.users.create(user), throwsDataValidationException);
    });
  });

  group("Method tests", () {
    Map<String, User> users;
    setUp(() async {
      users = await createTestUsers(api);
    });

    test("create()", () async {
      final User testUser = createUser();
      final IdResponse response = await api.users.create(testUser);
      validateIdResponse(response);
    });
    test("getByUuid()", () async {
      final User testUser =
          await api.users.getById(users[UserPrivilege.admin].id);
      expect(testUser, isNotNull);
    });
    test("getMe()", () async {
      model.AModel.overrideCurrentUser(users[UserPrivilege.admin].id);
      final User currentUser = await api.users.getMe();
      expect(currentUser, isNotNull);
      expect(currentUser.id == users[UserPrivilege.admin].id, isTrue);
    });

    test("update()", () async {
      final User user = users[UserPrivilege.admin];
      user.name = "New Name";
      final IdResponse response = await api.users.update(user.id, user);
      validateIdResponse(response);
    });
    test("changePassword()", () async {
      final PasswordChangeRequest request = new PasswordChangeRequest();
      request.currentPassword = users[UserPrivilege.admin].password;
      request.newPassword = "newpassword";
      await api.users.changePassword(users[UserPrivilege.admin].id, request);
    });

    test("delete()", () async {
      await api.users.delete(users[UserPrivilege.normal].id);
      expect(api.users.getById(users[UserPrivilege.normal].id),
          throwsNotFoundException);
    });
  });

  group("Security tests", () {
    Map<String, User> users;

    setUp(() async {
      users = await createTestUsers(api);
    });

    group("create()", () {
      test("Unauthenticated", () async {
        model.AModel.overrideCurrentUser(null);
        expect(api.users.create(createUser()), throwsUnauthorizedException);
      });
      test("As normal", () async {
        model.AModel.overrideCurrentUser(users[UserPrivilege.normal].id);
        expect(api.users.create(createUser()), throwsForbiddenException);
      });
      test("As moderator", () async {
        model.AModel.overrideCurrentUser(users[UserPrivilege.moderator].id);
        expect(api.users.create(createUser()), throwsForbiddenException);
      });
      test("As admin", () async {
        model.AModel.overrideCurrentUser(users[UserPrivilege.admin].id);
        final IdResponse response = await api.users.create(createUser());
        validateIdResponse(response);
      });
    });
    group("getByUuid()", () {
      test("Unauthenticated", () async {
        model.AModel.overrideCurrentUser(null);
        expect(api.users.getById(users[UserPrivilege.admin].id),
            throwsUnauthorizedException);
      });
      test("As normal", () async {
        model.AModel.overrideCurrentUser(users[UserPrivilege.normal].id);
        expect(api.users.getById(users[UserPrivilege.admin].id),
            throwsForbiddenException);
      });
      test("As moderator", () async {
        model.AModel.overrideCurrentUser(users[UserPrivilege.moderator].id);
        final User test =
            await api.users.getById(users[UserPrivilege.admin].id);
        expect(test, isNotNull);
        expect(test.id == users[UserPrivilege.admin].id, isTrue);
        expect(test.name == users[UserPrivilege.admin].name, isTrue);
      });
      test("As admin", () async {
        model.AModel.overrideCurrentUser(users[UserPrivilege.admin].id);
        final User test =
            await api.users.getById(users[UserPrivilege.admin].id);
        expect(test, isNotNull);
        expect(test.id == users[UserPrivilege.admin].id, isTrue);
        expect(test.name == users[UserPrivilege.admin].name, isTrue);
      });
    });

    group("getMe()", () {
      test("Unauthenticated", () async {
        model.AModel.overrideCurrentUser(null);
        expect(api.users.getMe(), throwsUnauthorizedException);
      });
      test("As normal", () async {
        model.AModel.overrideCurrentUser(users[UserPrivilege.normal].id);
        final User user = await api.users.getMe();
        expect(user, isNotNull);
        expect(user.id == users[UserPrivilege.normal].id, isTrue);
      });
      test("As moderator", () async {
        model.AModel.overrideCurrentUser(users[UserPrivilege.moderator].id);
        final User user = await api.users.getMe();
        expect(user, isNotNull);
        expect(user.id == users[UserPrivilege.moderator].id, isTrue);
      });
      test("As admin", () async {
        model.AModel.overrideCurrentUser(users[UserPrivilege.admin].id);
        final User user = await api.users.getMe();
        expect(user, isNotNull);
        expect(user.id == users[UserPrivilege.admin].id, isTrue);
      });
    });

    group("update()", () {
      group("Different user", () {
        User testUser;
        setUp(() async {
          testUser = createUser();
          testUser.name = "NEW NAME";
          await api.users.create(testUser);
        });
        test("Unauthenticated", () async {
          model.AModel.overrideCurrentUser(null);
          expect(api.users.update(testUser.id, testUser),
              throwsUnauthorizedException);
        });
        test("As normal", () async {
          model.AModel.overrideCurrentUser(users[UserPrivilege.normal].id);
          expect(api.users.update(testUser.id, testUser),
              throwsForbiddenException);
        });
        test("As moderator", () async {
          model.AModel.overrideCurrentUser(users[UserPrivilege.moderator].id);
          expect(api.users.update(testUser.id, testUser),
              throwsForbiddenException);
        });
        test("As admin", () async {
          model.AModel.overrideCurrentUser(users[UserPrivilege.admin].id);
          await api.users.update(testUser.id, testUser);
        });
      });
      group("Self", () {
        test("As normal", () async {
          model.AModel.overrideCurrentUser(users[UserPrivilege.normal].id);
          final User user = users[UserPrivilege.normal];
          user.name = "new test name";
          await api.users.update(user.id, user);
        });
        test("As moderator", () async {
          model.AModel.overrideCurrentUser(users[UserPrivilege.moderator].id);
          final User user = users[UserPrivilege.moderator];
          user.name = "new test name";
          await api.users.update(user.id, user);
        });
        test("As admin", () async {
          model.AModel.overrideCurrentUser(users[UserPrivilege.admin].id);
          final User user = users[UserPrivilege.admin];
          user.name = "new test name";
          await api.users.update(user.id, user);
        });
      });
    });

    group("changePassword()", () {
      PasswordChangeRequest request;
      User testUser;
      setUp(() async {
        testUser = createUser();
        request = new PasswordChangeRequest();
        request.currentPassword = testUser.password;
        request.newPassword = generateUuid();
      });
      test("Unauthenticated", () async {
        model.AModel.overrideCurrentUser(null);
        expect(api.users.changePassword(testUser.id, request),
            throwsUnauthorizedException);
      });
      test("As normal", () async {
        model.AModel.overrideCurrentUser(users[UserPrivilege.normal].id);
        expect(api.users.changePassword(testUser.id, request),
            throwsForbiddenException);
      });
      test("As moderator", () async {
        model.AModel.overrideCurrentUser(users[UserPrivilege.moderator].id);
        expect(api.users.changePassword(testUser.id, request),
            throwsForbiddenException);
      });
      test("As admin", () async {
        model.AModel.overrideCurrentUser(users[UserPrivilege.admin].id);
        await api.users.changePassword(testUser.id, request);
      });
    });

    group("delete()", () {
      User testUser;
      setUp(() async {
        testUser = createUser();
      });
      test("Unauthenticated", () async {
        model.AModel.overrideCurrentUser(null);
        expect(api.users.delete(testUser.id), throwsUnauthorizedException);
      });
      test("As normal", () async {
        model.AModel.overrideCurrentUser(users[UserPrivilege.normal].id);
        expect(api.users.delete(testUser.id), throwsForbiddenException);
      });
      test("As moderator", () async {
        model.AModel.overrideCurrentUser(users[UserPrivilege.moderator].id);
        expect(api.users.delete(testUser.id), throwsForbiddenException);
      });
      test("As admin", () async {
        model.AModel.overrideCurrentUser(users[UserPrivilege.admin].id);
        await api.users.delete(testUser.id);
      });
    });
  });
}
