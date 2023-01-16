import '../mlg_logger.dart';
import 'log_sources.dart';

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

class Logger {
  static Level level = Level.verbose;

  late final LogFilter _filter;
  final LogPrinter _printer;

  Logger({
    LogFilter? filter,
    LogPrinter? printer,
    List<LogSource>? sources,
    Level? level,
  })  : _filter = filter ?? DevelopmentFilter(),
        _printer = printer ?? SimplePrinter() {
    _filter.init();
    _filter.level = level ?? Logger.level;
    _printer.init();
  }

  /// Log a message at level [Level.verbose].
  void v(dynamic message,
      [dynamic error, StackTrace? stackTrace, List<LogSource>? logSources]) {
    log(Level.verbose, message, error, stackTrace);
  }

  /// Log a message at level [Level.debug].
  void d(dynamic message,
      [dynamic error, StackTrace? stackTrace, List<LogSource>? logSources]) {
    log(Level.debug, message, error, stackTrace);
  }

  /// Log a message at level [Level.info].
  void i(dynamic message,
      [dynamic error, StackTrace? stackTrace, List<LogSource>? logSources]) {
    log(Level.info, message, error, stackTrace);
  }

  /// Log a message at level [Level.warning].
  void w(dynamic message,
      [dynamic error, StackTrace? stackTrace, List<LogSource>? logSources]) {
    log(Level.warning, message, error, stackTrace);
  }

  /// Log a message at level [Level.error].
  void e(dynamic message,
      [dynamic error, StackTrace? stackTrace, List<LogSource>? logSources]) {
    log(Level.error, message, error, stackTrace);
  }

  /// Log a message with [level].
  void log(Level level, dynamic message,
      [dynamic error, StackTrace? stackTrace, List<LogSource>? logSources]) {
    if (error != null && error is StackTrace) {
      throw ArgumentError('Error parameter cannot take a StackTrace!');
    } else if (level == Level.nothing) {
      throw ArgumentError('Log events cannot have Level.nothing');
    }
    //TODO пополнить список всеми сурсами
    var sources = logSources ?? [ConsoleLogSource()];
    var logEvent = LogEvent(level, message, error, stackTrace);

    if (_filter.shouldLog(logEvent)) {
      var output = _printer.log(logEvent);
      if (output.isNotEmpty) {
        var outputEvent = OutputEvent(level, output);
        try {
          for (var source in sources) {
            source.handleLog(outputEvent.lines);
          }
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
