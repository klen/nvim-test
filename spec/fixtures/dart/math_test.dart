import 'package:test/test.dart';

void main() {
  group('Math', () {
    test('addition', () {
      expect(1 + 1, equals(2));
    });

    test('subtraction', () {
      expect(3 - 1, equals(2));
    });
  });
}
