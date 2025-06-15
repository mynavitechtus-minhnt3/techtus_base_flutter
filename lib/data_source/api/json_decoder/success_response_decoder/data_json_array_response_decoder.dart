import '../../../../index.dart';

class DataJsonArrayResponseDecoder<T extends Object>
    extends BaseSuccessResponseDecoder<T, DataListResponse<T>> {
  @override
  DataListResponse<T>? mapToDataModel({
    // ignore: avoid_dynamic
    required dynamic response,
    Decoder<T>? decoder,
  }) {
    return decoder != null && response is Map<String, dynamic>
        ? DataListResponse.fromJson(response, (json) => decoder(json))
        : null;
  }
}
