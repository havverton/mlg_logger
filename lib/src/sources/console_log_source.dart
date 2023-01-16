import '../log_sources.dart';

class ConsoleLogSource implements LogSource {
  @override
  void handleLog(List<String> lines) {
    for (var e in lines) {
      print(e);
    }
  }
}
