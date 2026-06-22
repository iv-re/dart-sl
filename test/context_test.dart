import 'package:ctx/ctx.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sl/sl.dart';
import 'package:test/test.dart';

class _MockHandler extends Mock implements LogHandler {}

void main() {
  group('ContextLoggerExtension', () {
    test('withLogger stores and retrieves logger from context', () {
      final logger = Logger(handler: _MockHandler());
      final context = const Context.empty().withLogger(logger);

      expect(context.logger, same(logger));
    });

    test('getter asserts if logger is missing in context', () {
      const context = Context.empty();

      expect(() => context.logger, throwsA(isA<AssertionError>()));
    });
  });
}
