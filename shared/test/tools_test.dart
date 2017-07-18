import 'package:test/test.dart';
import 'package:dartlery_shared/tools.dart';

void main() {
  group("Global tools", () {
    test("generateUuid()", () {
      expect(generateUuid(), isNotEmpty);
    });
    group("isUuid()", () {
      test("Generated uuid", () {
        final String uuid = generateUuid();
        expect(isUuid(uuid), isTrue);
      });
      test("v1 uuid", () {
        expect(isUuid("c100b8fe-1fba-11e7-93ae-92361f002671"), isTrue);
      });
      test("v4 uuid", () {
        expect(isUuid("5c5b7256-b7ce-409e-ba64-a6e774470805"), isTrue);
      });
      test("Invalid uuid", () {
        expect(isUuid("Not a uuid"), isFalse);
      });
    });
    group("StringTools", () {
      group(".isNullOrWhitespace()", () {
        test("null", () {
          expect(isNullOrWhitespace(null), isTrue);
        });
        test("empty", () {
          expect(isNullOrWhitespace(""), isTrue);
        });
        test("whitespace", () {
          expect(isNullOrWhitespace("   "), isTrue);
        });
        test("whitespace with letter", () {
          expect(isNullOrWhitespace("  t "), isFalse);
        });
      });
      group(".isNotNullOrWhitespace()", () {
        test("null", () {
          expect(isNotNullOrWhitespace(null), isFalse);
        });
        test("empty", () {
          expect(isNotNullOrWhitespace(""), isFalse);
        });
        test("whitespace", () {
          expect(isNotNullOrWhitespace("   "), isFalse);
        });
        test("whitespace with letter", () {
          expect(isNotNullOrWhitespace("  t "), isTrue);
        });
      });
    });
    group("isValidEmail()", () {
      test("null", () {
        expect(() => isValidEmail(null), throwsArgumentError);
      });
      test("empty", () {
        expect(isValidEmail(""), isFalse);
      });
      test("invalid", () {
        expect(isValidEmail("singleWord"), isFalse);
      });
      test("valid", () {
        expect(isValidEmail("test@test.com"), isTrue);
      });
    });
  });
}
