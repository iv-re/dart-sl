import 'package:sl/sl.dart';
import 'package:test/test.dart';

void main() {
  group('LogAttr', () {
    test('string', () {
      const attr = LogAttr.string('k', 'v');

      expect(attr.key, 'k');
      expect((attr as LogStringAttr).value, 'v');
    });

    test('int', () {
      const attr = LogAttr.int('k', 42);

      expect(attr.key, 'k');
      expect((attr as LogIntAttr).value, 42);
    });

    test('double', () {
      const attr = LogAttr.double('k', 3.14);

      expect(attr.key, 'k');
      expect((attr as LogDoubleAttr).value, 3.14);
    });

    test('bool', () {
      const attr = LogAttr.bool('k', true);

      expect(attr.key, 'k');
      expect((attr as LogBoolAttr).value, isTrue);
    });

    test('group', () {
      const attr = LogAttr.group('g', [
        LogAttr.string('a', '1'),
        LogAttr.int('b', 2),
      ]);

      expect(attr.key, 'g');
      expect((attr as LogGroupAttr).values, hasLength(2));
    });

    test('error', () {
      final attr = LogAttr.error(StateError('bad')) as LogStringAttr;

      expect(attr.key, 'error');
      expect(attr.value, contains('bad'));
    });

    test('stackTrace', () {
      final trace = StackTrace.current;
      final attr = LogAttr.stackTrace(trace) as LogStringAttr;

      expect(attr.key, 'stack_trace');
      expect(attr.value, isNotEmpty);
    });
  });
}
