// ignore_for_file: unused_element, prefer_single_widget_per_file, avoid_hard_coded_strings, prefer_named_parameters

enum UserStatus { active, inactive, pending }

void main() {
  final AppPreferences appPreferences = AppPreferences(
    sharedPreference: SharedPreferences(),
    encryptedSharedPreferences: EncryptedSharedPreferences(),
    secureStorage: FlutterSecureStorage(),
  );

  // BAD: Using enum names as keys - should trigger lint
  void saveUserStatus(UserStatus status) {
    // expect_lint: avoid_using_enum_name_as_key
    appPreferences.setString(status.name, 'user_data');
    // expect_lint: avoid_using_enum_name_as_key
    appPreferences.setString(UserStatus.active.name, 'active_user');
  }

  // GOOD: Using string constants as keys - should NOT trigger lint
  void saveUserStatusGood(UserStatus status) {
    appPreferences.setString(AppPreferences.userStatusKey, status.name);
    appPreferences.setString('active_user_key', 'active_user');
  }
}

class SharedPreferences {
  void setString(String key, String value) {}

  void setInt(String key, int value) {}

  void setDouble(String key, double value) {}

  void setBool(String key, bool value) {}

  void setStringList(String key, List<String> value) {}

  void remove(String key) {}

  void containsKey(String key) {}
}

class EncryptedSharedPreferences {
  void setString(String key, String value) {}

  void setInt(String key, int value) {}

  void setDouble(String key, double value) {}

  void setBool(String key, bool value) {}

  void setStringList(String key, List<String> value) {}

  void remove(String key) {}

  void containsKey(String key) {}
}

class FlutterSecureStorage {
  void setString(String key, String value) {}

  void setInt(String key, int value) {}

  void setDouble(String key, double value) {}

  void setBool(String key, bool value) {}

  void setStringList(String key, List<String> value) {}

  void remove(String key) {}

  void containsKey(String key) {}
}

class AppPreferences {
  final SharedPreferences _sharedPreference;
  final EncryptedSharedPreferences _encryptedSharedPreferences;
  final FlutterSecureStorage _secureStorage;

  static const String userStatusKey = 'user_status';

  AppPreferences(
      {required SharedPreferences sharedPreference,
      required EncryptedSharedPreferences encryptedSharedPreferences,
      required FlutterSecureStorage secureStorage})
      : _sharedPreference = sharedPreference,
        _encryptedSharedPreferences = encryptedSharedPreferences,
        _secureStorage = secureStorage;

  void setString(String key, String value) {
    _sharedPreference.setString(key, value);
    _encryptedSharedPreferences.setString(key, value);
    _secureStorage.setString(key, value);
    _sharedPreference.setString(userStatusKey, value);
    _encryptedSharedPreferences.setString(userStatusKey, value);
    _secureStorage.setString(userStatusKey, value);
    // expect_lint: avoid_using_enum_name_as_key
    _sharedPreference.setString(UserStatus.active.name, value);
    // expect_lint: avoid_using_enum_name_as_key
    _encryptedSharedPreferences.setString(UserStatus.active.name, value);
    // expect_lint: avoid_using_enum_name_as_key
    _secureStorage.setString(UserStatus.active.name, value);
    _sharedPreference.setString('test_key', value);
    _encryptedSharedPreferences.setString('test_key', value);
    _secureStorage.setString('test_key', value);
  }

  void setInt(String key, int value) {
    _sharedPreference.setInt(key, value);
    _encryptedSharedPreferences.setInt(key, value);
    _secureStorage.setInt(key, value);
    _sharedPreference.setInt(userStatusKey, value);
    _encryptedSharedPreferences.setInt(userStatusKey, value);
    _secureStorage.setInt(userStatusKey, value);
    // expect_lint: avoid_using_enum_name_as_key
    _sharedPreference.setInt(UserStatus.active.name, value);
    // expect_lint: avoid_using_enum_name_as_key
    _encryptedSharedPreferences.setInt(UserStatus.active.name, value);
    // expect_lint: avoid_using_enum_name_as_key
    _secureStorage.setInt(UserStatus.active.name, value);
    _sharedPreference.setInt('test_key', value);
    _encryptedSharedPreferences.setInt('test_key', value);
    _secureStorage.setInt('test_key', value);
  }

  void setDouble(String key, double value) {
    _sharedPreference.setDouble(key, value);
    _encryptedSharedPreferences.setDouble(key, value);
    _secureStorage.setDouble(key, value);
    _sharedPreference.setDouble(userStatusKey, value);
    _encryptedSharedPreferences.setDouble(userStatusKey, value);
    _secureStorage.setDouble(userStatusKey, value);
    // expect_lint: avoid_using_enum_name_as_key
    _sharedPreference.setDouble(UserStatus.active.name, value);
    // expect_lint: avoid_using_enum_name_as_key
    _encryptedSharedPreferences.setDouble(UserStatus.active.name, value);
    // expect_lint: avoid_using_enum_name_as_key
    _secureStorage.setDouble(UserStatus.active.name, value);
    _sharedPreference.setDouble('test_key', value);
    _encryptedSharedPreferences.setDouble('test_key', value);
    _secureStorage.setDouble('test_key', value);
  }

  void setBool(String key, bool value) {
    _sharedPreference.setBool(key, value);
    _encryptedSharedPreferences.setBool(key, value);
    _secureStorage.setBool(key, value);
    _sharedPreference.setBool(userStatusKey, value);
    _encryptedSharedPreferences.setBool(userStatusKey, value);
    _secureStorage.setBool(userStatusKey, value);
    // expect_lint: avoid_using_enum_name_as_key
    _sharedPreference.setBool(UserStatus.active.name, value);
    // expect_lint: avoid_using_enum_name_as_key
    _encryptedSharedPreferences.setBool(UserStatus.active.name, value);
    // expect_lint: avoid_using_enum_name_as_key
    _secureStorage.setBool(UserStatus.active.name, value);
    _sharedPreference.setBool('test_key', value);
    _encryptedSharedPreferences.setBool('test_key', value);
    _secureStorage.setBool('test_key', value);
  }

  void setStringList(String key, List<String> value) {
    _sharedPreference.setStringList(key, value);
    _encryptedSharedPreferences.setStringList(key, value);
    _secureStorage.setStringList(key, value);
    _sharedPreference.setStringList(userStatusKey, value);
    _encryptedSharedPreferences.setStringList(userStatusKey, value);
    _secureStorage.setStringList(userStatusKey, value);
    // expect_lint: avoid_using_enum_name_as_key
    _sharedPreference.setStringList(UserStatus.active.name, value);
    // expect_lint: avoid_using_enum_name_as_key
    _encryptedSharedPreferences.setStringList(UserStatus.active.name, value);
    // expect_lint: avoid_using_enum_name_as_key
    _secureStorage.setStringList(UserStatus.active.name, value);
    _sharedPreference.setStringList('test_key', value);
    _encryptedSharedPreferences.setStringList('test_key', value);
    _secureStorage.setStringList('test_key', value);
  }

  void remove(String key) {
    _sharedPreference.remove(key);
    _encryptedSharedPreferences.remove(key);
    _secureStorage.remove(key);
  }

  void containsKey(String key) {
    _sharedPreference.containsKey(key);
    _encryptedSharedPreferences.containsKey(key);
    _secureStorage.containsKey(key);
  }
}
