import '../../../../index.dart';

class DataJsonObjectResponseDecoder<T extends Object>
    extends BaseSuccessResponseDecoder<T, DataResponse<T>> {
  @override
  DataResponse<T>? mapToDataModel({
    // ignore: avoid_dynamic
    required dynamic response,
    Decoder<T>? decoder,
  }) {
    return decoder != null && response is Map<String, dynamic>
        ? DataResponse.fromJson(response, (json) => decoder(json))
        : null;
  }
}
