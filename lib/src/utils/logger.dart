import 'package:flutter/foundation.dart';
import 'package:inject_annotation/inject_annotation.dart';
import 'package:logging/logging.dart';
import 'package:stack_trace/stack_trace.dart';

const loggerName = 'Demo';

@immutable
@module
class LoggerModule {
  const LoggerModule();

  @provides
  @singleton
  Logger provideLogger() {
    const frameIndex = 9; // may change form project to project
    Logger.root
      ..level = kDebugMode ? Level.ALL : Level.OFF
      ..onRecord.listen((rec) {
        if (rec.loggerName != loggerName) {
          debugPrint('[${rec.loggerName}]: ${rec.message}');
          if (rec.stackTrace != null) {
            debugPrintStack(stackTrace: rec.stackTrace);
          }
        } else {
          final frames = Trace.current().frames;
          final f = frames.length > frameIndex ? frames[frameIndex] : null;
          final message = f == null ? rec.message : '(${f.location}) ${f.member}: ${rec.message}';

          // show log in DevTools or in IntelliJ IDE
          // developer.log(
          //   message,
          //   time: rec.time,
          //   sequenceNumber: rec.sequenceNumber,
          //   level: rec.level.value,
          //   name: rec.loggerName,
          //   zone: rec.zone,
          //   error: rec.error,
          //   stackTrace: rec.stackTrace,
          // );

          // show log on console
          debugPrint(message);
          if (rec.stackTrace != null) {
            debugPrintStack(stackTrace: rec.stackTrace);
          }
        }
      });

    return Logger(loggerName);
  }
}
