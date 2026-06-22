import 'package:sl/sl.dart';
import 'package:test/test.dart';

void main() {
  group('LogLevel', () {
    test('operators and compareTo', () {
      expect(LogLevel.debug < LogLevel.info, isTrue);
      expect(LogLevel.error > LogLevel.warn, isTrue);
      expect(LogLevel.info <= LogLevel.info, isTrue);
      expect(LogLevel.warn >= LogLevel.info, isTrue);
      expect(LogLevel.info.compareTo(LogLevel.info), 0);
      expect(LogLevel.info.compareTo(LogLevel.warn), lessThan(0));
      expect(LogLevel.warn.compareTo(LogLevel.info), greaterThan(0));
    });

    test('toString returns name', () {
      expect(LogLevel.info.toString(), 'info');
    });
  });
}
