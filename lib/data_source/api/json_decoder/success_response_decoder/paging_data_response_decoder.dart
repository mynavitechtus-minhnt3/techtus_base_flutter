import '../../../../../index.dart';

class PagingDataResponseDecoder<T extends Object>
    extends BaseSuccessResponseDecoder<T, PagingDataResponse<T>> {
  @override
  PagingDataResponse<T>? mapToDataModel({
    // ignore: avoid_dynamic
    required dynamic response,
    Decoder<T>? decoder,
  }) {
    return decoder != null && response is Map<String, dynamic>
        ? PagingDataResponse.fromJson(response, (json) => decoder(json))
        : null;
  }
}
