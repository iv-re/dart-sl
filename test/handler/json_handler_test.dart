import 'dart:convert';
import 'dart:io';

import 'package:ctx/ctx.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sl/sl.dart';
import 'package:test/test.dart';

class _MockSink extends Mock implements IOSink {}

void main() {
  group('LogJsonHandler', () {
    test('enabled filters by level', () {
      final handler = LogJsonHandler(level: .warn);

      expect(handler.enabled(const .empty(), .warn), isTrue);
      expect(handler.enabled(const .empty(), .error), isTrue);
      expect(handler.enabled(const .empty(), .info), isFalse);
    });

    Map<String, dynamic> capture(void Function(LogJsonHandler handler) action) {
      final sink = _MockSink();
      final handler = LogJsonHandler(sink: sink);
      action(handler);

      final call = verify(() => sink.writeln(captureAny()));
      return jsonDecode(call.captured.first as String) as Map<String, dynamic>;
    }

    test('handle contains time, level and msg', () {
      final map = capture(
        (handler) => handler.handle(
          const .empty(),
          LogRecord(
            level: .error,
            message: 'fail',
            time: .utc(2000, 11, 15),
            attrs: [],
          ),
        ),
      );

      expect(map['time'], '2000-11-15T00:00:00.000Z');
      expect(map['level'], 'ERROR');
      expect(map['msg'], 'fail');
    });

    test('handle includes attrs', () {
      final map = capture(
        (handler) => handler.handle(
          const .empty(),
          LogRecord(
            level: .info,
            message: 'ok',
            time: .utc(2000, 11, 15),
            attrs: const [
              .string('user', 'alice'),
              .int('count', 5),
              .double('price', 9.99),
              .bool('active', true),
            ],
          ),
        ),
      );

      expect(map['user'], 'alice');
      expect(map['count'], 5);
      expect(map['price'], 9.99);
      expect(map['active'], isTrue);
    });

    test('handle formats group as nested map', () {
      final map = capture(
        (handler) => handler.handle(
          const .empty(),
          LogRecord(
            level: .debug,
            message: 'query',
            time: .utc(2000, 11, 15),
            attrs: const [
              .group(
                'db',
                [
                  .string('sql', 'SELECT 1'),
                  .int('dur', 42),
                ],
              ),
            ],
          ),
        ),
      );

      expect(map['db'], {'sql': 'SELECT 1', 'dur': 42});
    });

    test('withAttrs includes combined attrs in output', () {
      final sink = _MockSink();

      final handler = LogJsonHandler(
        sink: sink,
        attrs: const [.string('a', '1')],
      ).withAttrs(const [.string('b', '2')]);

      handler.handle(
        const .empty(),
        LogRecord(
          level: .info,
          message: 'm',
          time: .utc(2000, 11, 15),
          attrs: const [.string('c', '3')],
        ),
      );

      final json = verify(() => sink.writeln(captureAny())).captured.first;
      final map = jsonDecode(json as String) as Map<String, dynamic>;
      expect(map['a'], '1');
      expect(map['b'], '2');
      expect(map['c'], '3');
    });

    test('middleware modifies record based on context', () {
      final sink = _MockSink();

      final handler = LogJsonHandler(
        sink: sink,
        middlewares: [
          (ctx, record) {
            if (ctx.value('req_id') case final String reqId) {
              return record.copyWith(
                attrs: [...record.attrs, .string('req_id', reqId)],
              );
            }
            return record;
          },
          (ctx, record) {
            return record.copyWith(message: '${record.message}_processed');
          },
        ],
      );

      final context = const Context.empty().withValue('req_id', 'xyz-789');

      handler.handle(
        context,
        LogRecord(
          level: .info,
          message: 'processed request',
          time: .utc(2000, 11, 15),
          attrs: const [],
        ),
      );

      final json = verify(() => sink.writeln(captureAny())).captured.first;
      final map = jsonDecode(json as String) as Map<String, dynamic>;
      expect(map['req_id'], 'xyz-789');
      expect(map['msg'], 'processed request_processed');
    });
  });
}
