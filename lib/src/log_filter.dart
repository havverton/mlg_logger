import 'logger.dart';

abstract class LogFilter {
  Level? level;

  void init() {}

  bool shouldLog(LogEvent event);

  void destroy() {}
}
