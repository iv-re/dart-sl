import 'package:sl/sl.dart';
import 'package:test/test.dart';

void main() {
  group('LogRecord', () {
    test('copyWith creates a new instance with updated fields', () {
      final time = DateTime.now();
      final record = LogRecord(
        level: LogLevel.info,
        message: 'Original message',
        time: time,
        attrs: [],
      );

      final newTime = time.add(const Duration(seconds: 1));
      const attr = LogAttr.string('key', 'value');

      final copied = record.copyWith(
        level: LogLevel.debug,
        message: 'Updated message',
        time: newTime,
        attrs: [attr],
      );

      expect(copied.level, LogLevel.debug);
      expect(copied.message, 'Updated message');
      expect(copied.time, newTime);
      expect(copied.attrs, [attr]);

      // Verify that the original record was not mutated
      expect(record.level, LogLevel.info);
      expect(record.message, 'Original message');
      expect(record.time, time);
      expect(record.attrs, isEmpty);
    });

    test('copyWith returns identical values when arguments are omitted', () {
      final time = DateTime.now();
      final record = LogRecord(
        level: LogLevel.info,
        message: 'Message',
        time: time,
        attrs: [],
      );

      final copied = record.copyWith();

      expect(copied.level, record.level);
      expect(copied.message, record.message);
      expect(copied.time, record.time);
      expect(copied.attrs, record.attrs);
    });
  });
}
