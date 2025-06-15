import '../../../../index.dart';

class ResultsJsonArrayResponseDecoder<T extends Object>
    extends BaseSuccessResponseDecoder<T, ResultsListResponse<T>> {
  @override
  ResultsListResponse<T>? mapToDataModel({
    // ignore: avoid_dynamic
    required dynamic response,
    Decoder<T>? decoder,
  }) {
    return decoder != null && response is Map<String, dynamic>
        ? ResultsListResponse.fromJson(response, (json) => decoder(json))
        : null;
  }
}
