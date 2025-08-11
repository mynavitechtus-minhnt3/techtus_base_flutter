import 'package:json_annotation/json_annotation.dart';

import '../../index.dart';

class FirebaseConversationUserDataConverter
    implements JsonConverter<FirebaseConversationUserData, Map<String, dynamic>> {
  const FirebaseConversationUserDataConverter();

  @override
  FirebaseConversationUserData fromJson(Map<String, dynamic> json) {
    return FirebaseConversationUserData.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(FirebaseConversationUserData data) {
    return data.toJson();
  }
}
