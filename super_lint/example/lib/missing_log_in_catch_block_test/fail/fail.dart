
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
