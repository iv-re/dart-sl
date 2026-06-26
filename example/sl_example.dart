import 'package:ctx/ctx.dart';
import 'package:sl/sl.dart';

void main() {
  // LogTextHandler (human-readable console output)
  print('--- Text Handler Output ---');
  final logger = Logger(
    handler: LogTextHandler(
      level: .debug,
      middlewares: [
        (context, record) {
          if (context.value('trace_id') case final String traceId) {
            return record.copyWith(
              attrs: [...record.attrs, .string('trace_id', traceId)],
            );
          }
          return record;
        },
      ],
    ),
  );

  logger.debug('connecting to service...');

  final context = const Context.empty().withValue('trace_id', 'trace-12345');

  logger.info(
    'service initialized',
    ctx: context,
    attrs: const [
      .string('version', '1.0.0'),
      .int('retries', 3),
      .double('timeout_sec', 5.5),
      .bool('production', false),
    ],
  );

  // Contextual logger with shared metadata
  final scoped = logger.withAttrs(const [
    .string('req_id', 'req-42'),
  ]);

  scoped.info('processing request');

  scoped.warn(
    'query execution was slow',
    attrs: const [
      .group(
        'db',
        [
          .string('query', 'SELECT 1'),
          .int('duration_ms', 150),
        ],
      ),
    ],
  );

  // Error and stack trace logging
  try {
    throw StateError('connection timed out');
  } catch (e, stack) {
    scoped.error(
      'request handler crashed',
      attrs: [
        .error(e),
        .stackTrace(stack),
      ],
    );
  }

  // LogJsonHandler (production line-delimited JSON output)
  print('\n--- JSON Handler Output ---');
  final jsonLogger = Logger(
    handler: LogJsonHandler(),
  );

  jsonLogger.info(
    'transaction succeeded',
    attrs: const [
      .string('user', 'alice'),
      .int('amount_cents', 1500),
    ],
  );
}
