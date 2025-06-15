import '../../../../index.dart';

class RecordsJsonArrayResponseDecoder<T extends Object>
    extends BaseSuccessResponseDecoder<T, RecordsListResponse<T>> {
  @override
  RecordsListResponse<T>? mapToDataModel({
    // ignore: avoid_dynamic
    required dynamic response,
    Decoder<T>? decoder,
  }) {
    return decoder != null && response is Map<String, dynamic>
        ? RecordsListResponse.fromJson(response, (json) => decoder(json))
        : null;
  }
}
