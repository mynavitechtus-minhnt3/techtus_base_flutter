// ignore_for_file: prefer_single_widget_per_file
// ignore_for_file: avoid_hard_coded_strings
// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD NOT BE WARNED ~.~.~.~.~.~.~.~

void test() {
  final logger = Log();

  try {} catch (e) {
    logger.severe('Error: $e');
  }

  try {} catch (e) {
    Log().info('Error: $e');
  }

  try {} catch (e) {
    Log().warning('Error: $e');
  }

  try {} catch (e) {
    Log.debug('Error: $e');
  }

  try {} catch (e) {
    Log.error('Error: $e');
  }
}

class Log {
  void info(String message) {
    print(message);
  }

  void severe(String message) {
    print(message);
  }

  void warning(String message) {
    print(message);
  }

  void e(String message) {
    print(message);
  }

  static d(String message) {
    print(message);
  }

  static void debug(String message) {
    print(message);
  }

  static void error(String message) {
    print(message);
  }
}

// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD BE WARNED ~.~.~.~.~.~.~.~

void test2() {
  final logger = Logger();

  // expect_lint: missing_log_in_catch_block
  try {} catch (e) {
    logger.severe('Error: $e');
  }

  // expect_lint: missing_log_in_catch_block
  try {} catch (e) {
    Logger().severe('Error: $e');
  }

  // expect_lint: missing_log_in_catch_block
  try {} catch (e) {
    Log().e('Error: $e');
  }

  // expect_lint: missing_log_in_catch_block
  try {} catch (e) {
    Log.d('Error: $e');
  }

  try {
    // expect_lint: missing_log_in_catch_block
  } catch (e) {
    print(e);
  }
}

class Logger {
  void severe(String message) {
    print(message);
  }
}
