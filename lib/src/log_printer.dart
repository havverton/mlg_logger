import 'logger.dart';

abstract class LogPrinter {
  void init() {}

  /// Is called every time a new [LogEvent] is sent and handles printing or
  /// storing the message.
  List<String> log(LogEvent event);

  void destroy() {}
}