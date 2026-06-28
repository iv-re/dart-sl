import 'package:ctx/ctx.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sl/sl.dart';
import 'package:test/test.dart';

class _MockHandler extends Mock implements LogHandler {}

void main() {
  group('LogMultiHandler', () {
    late _MockHandler handlerOne;
    late _MockHandler handlerTwo;
    late LogMultiHandler multiHandler;

    setUpAll(() {
      registerFallbackValue(const Context.empty());
      registerFallbackValue(LogLevel.debug);
      registerFallbackValue(
        LogRecord(
          level: LogLevel.info,
          message: '',
          time: DateTime.now(),
          attrs: [],
        ),
      );
    });

    setUp(() {
      handlerOne = _MockHandler();
      handlerTwo = _MockHandler();
      multiHandler = LogMultiHandler([handlerOne, handlerTwo]);
    });

    test('enabled returns true if any downstream handler is enabled', () {
      when(() => handlerOne.enabled(any(), any())).thenReturn(false);
      when(() => handlerTwo.enabled(any(), any())).thenReturn(false);
      expect(
        multiHandler.enabled(const Context.empty(), LogLevel.info),
        isFalse,
      );

      when(() => handlerOne.enabled(any(), any())).thenReturn(true);
      expect(
        multiHandler.enabled(const Context.empty(), LogLevel.info),
        isTrue,
      );

      when(() => handlerOne.enabled(any(), any())).thenReturn(false);
      when(() => handlerTwo.enabled(any(), any())).thenReturn(true);
      expect(
        multiHandler.enabled(const Context.empty(), LogLevel.info),
        isTrue,
      );
    });

    test('handle routes record to only enabled downstream handlers', () {
      final record = LogRecord(
        level: LogLevel.info,
        message: 'test message',
        time: DateTime.now(),
        attrs: [],
      );

      when(() => handlerOne.enabled(any(), any())).thenReturn(true);
      when(() => handlerTwo.enabled(any(), any())).thenReturn(false);
      when(() => handlerOne.handle(any(), any())).thenReturn(null);
      when(() => handlerTwo.handle(any(), any())).thenReturn(null);

      multiHandler.handle(const Context.empty(), record);

      verify(() => handlerOne.handle(any(), record)).called(1);
      verifyNever(() => handlerTwo.handle(any(), any()));
    });

    test('withAttrs delegates to all downstream handlers', () {
      final updatedHandlerOne = _MockHandler();
      final updatedHandlerTwo = _MockHandler();
      const attrs = [LogAttr.string('key', 'value')];

      when(() => handlerOne.withAttrs(attrs)).thenReturn(updatedHandlerOne);
      when(() => handlerTwo.withAttrs(attrs)).thenReturn(updatedHandlerTwo);

      final newMultiHandler = multiHandler.withAttrs(attrs) as LogMultiHandler;

      expect(
        newMultiHandler.handlers,
        containsAll([updatedHandlerOne, updatedHandlerTwo]),
      );
      verify(() => handlerOne.withAttrs(attrs)).called(1);
      verify(() => handlerTwo.withAttrs(attrs)).called(1);
    });

    test('withGroup delegates to all downstream handlers', () {
      final updatedHandlerOne = _MockHandler();
      final updatedHandlerTwo = _MockHandler();
      const groupName = 'group_name';

      when(() => handlerOne.withGroup(groupName)).thenReturn(updatedHandlerOne);
      when(() => handlerTwo.withGroup(groupName)).thenReturn(updatedHandlerTwo);

      final newMultiHandler =
          multiHandler.withGroup(groupName) as LogMultiHandler;

      expect(
        newMultiHandler.handlers,
        containsAll([updatedHandlerOne, updatedHandlerTwo]),
      );
      verify(() => handlerOne.withGroup(groupName)).called(1);
      verify(() => handlerTwo.withGroup(groupName)).called(1);
    });
  });
}
