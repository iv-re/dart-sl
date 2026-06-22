import 'package:sl/sl.dart';

void main() {
  // LogTextHandler (human-readable console output)
  print('--- Text Handler Output ---');
  final logger = Logger(
    handler: LogTextHandler(level: .debug),
  );

  logger.debug('connecting to service...');

  logger.info('service initialized', const [
    .string('version', '1.0.0'),
    .int('retries', 3),
    .double('timeout_sec', 5.5),
    .bool('production', false),
  ]);

  // Contextual logger with shared metadata
  final scoped = logger.withAttrs(const [
    .string('req_id', 'req-42'),
  ]);

  scoped.info('processing request');

  scoped.warn('query execution was slow', const [
    .group('db', [
      .string('query', 'SELECT 1'),
      .int('duration_ms', 150),
    ]),
  ]);

  // Error and stack trace logging
  try {
    throw StateError('connection timed out');
  } catch (e, stack) {
    scoped.error('request handler crashed', [
      .error(e),
      .stackTrace(stack),
    ]);
  }

  // LogJsonHandler (production line-delimited JSON output)
  print('\n--- JSON Handler Output ---');
  final jsonLogger = Logger(
    handler: LogJsonHandler(),
  );

  jsonLogger.info('transaction succeeded', const [
    .string('user', 'alice'),
    .int('amount_cents', 1500),
  ]);
}
