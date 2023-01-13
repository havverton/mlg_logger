import 'package:mlg_logger/src/printers/simple_printer.dart';

import 'filters/debug_filter.dart';
import 'log_filter.dart';
import 'log_printer.dart';

enum Level {
  verbose,
  debug,
  info,
  warning,
  error,
  nothing,
}

class LogEvent {
  final Level level;
  final dynamic message;
  final dynamic error;
  final StackTrace? stackTrace;

  LogEvent(this.level, this.message, this.error, this.stackTrace);
}

class OutputEvent {
  final Level level;
  final List<String> lines;

  OutputEvent(this.level, this.lines);
}

@Deprecated('Use a custom LogFilter instead')
typedef LogCallback = void Function(LogEvent event);

@Deprecated('Use a custom LogOutput instead')
typedef OutputCallback = void Function(OutputEvent event);

/// Use instances of logger to send log messages to the [LogPrinter].
class Logger {
  /// The current logging level of the app.
  ///
  /// All logs with levels below this level will be omitted.
  static Level level = Level.verbose;

  late final LogFilter _filter;
  final LogPrinter _printer;
  bool _active = true;

  /// Create a new instance of Logger.
  ///
  /// You can provide a custom [printers], [filter] and [output]. Otherwise the
  /// defaults: [PrettyPrinter], [DevelopmentFilter] and [ConsoleOutput] will be
  /// used.
  Logger({
    LogFilter? filter,
    LogPrinter? printer,
    Level? level,
  })  : _filter = filter ?? DevelopmentFilter(),
        _printer = printer ?? SimplePrinter()
  {
    _filter.init();
    _filter.level = level ?? Logger.level;
   // _printer.init();
    //_output.init();
  }

  /// Log a message at level [Level.verbose].
  void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.verbose, message, error, stackTrace);
  }
  /// Log a message at level [Level.debug].
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.debug, message, error, stackTrace);
  }

  /// Log a message at level [Level.info].
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.info, message, error, stackTrace);
  }

  /// Log a message at level [Level.warning].
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.warning, message, error, stackTrace);
  }

  /// Log a message at level [Level.error].
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.error, message, error, stackTrace);
  }


  /// Log a message with [level].
  void log(Level level, dynamic message,
      [dynamic error, StackTrace? stackTrace]) {
  if (error != null && error is StackTrace) {
      throw ArgumentError('Error parameter cannot take a StackTrace!');
    } else if (level == Level.nothing) {
      throw ArgumentError('Log events cannot have Level.nothing');
    }
    var logEvent = LogEvent(level, message, error, stackTrace);
    if (_filter.shouldLog(logEvent)) {
      var output = _printer.log(logEvent);

      if (output.isNotEmpty) {
        var outputEvent = OutputEvent(level, output);
        // Issues with log output should NOT influence
        // the main software behavior.
        try {
          outputEvent.lines.forEach((e) {print(e); });
        } catch (e, s) {
          print(e);
          print(s);
        }
      }
    }
  }

  /// Closes the logger and releases all resources.
  void close() {
   // _active = false;
    _filter.destroy();
    _printer.destroy();
    // _output.destroy();
  }
}