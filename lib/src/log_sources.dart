abstract class LogSource{
  void handleLog(List<String> lines);
}

class ConsoleLogSource implements LogSource{
  @override
  void handleLog(List<String> lines) {
    for (var e in lines) { print(e); }
  }

}