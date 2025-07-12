import '../../../../index.dart';

enum SuccessResponseDecoderType {
  dataJsonObject,
  dataJsonArray,
  jsonObject,
  jsonArray,
  paging,
  plain,
}

abstract class BaseSuccessResponseDecoder<I extends Object, O extends Object> {
  const BaseSuccessResponseDecoder();

  factory BaseSuccessResponseDecoder.fromType(SuccessResponseDecoderType type) {
    return switch (type) {
      SuccessResponseDecoderType.dataJsonObject =>
        DataJsonObjectResponseDecoder<I>() as BaseSuccessResponseDecoder<I, O>,
      SuccessResponseDecoderType.dataJsonArray =>
        DataJsonArrayResponseDecoder<I>() as BaseSuccessResponseDecoder<I, O>,
      SuccessResponseDecoderType.jsonObject =>
        JsonObjectResponseDecoder<I>() as BaseSuccessResponseDecoder<I, O>,
      SuccessResponseDecoderType.jsonArray =>
        JsonArrayResponseDecoder<I>() as BaseSuccessResponseDecoder<I, O>,
      SuccessResponseDecoderType.paging =>
        PagingDataResponseDecoder<I>() as BaseSuccessResponseDecoder<I, O>,
      SuccessResponseDecoderType.plain =>
        PlainResponseDecoder<I>() as BaseSuccessResponseDecoder<I, O>,
    };
  }

  O? map({
    // ignore: avoid_dynamic
    required dynamic response,
    Decoder<I>? decoder,
  }) {
    assert(response != null);
    try {
      return mapToDataModel(response: response, decoder: decoder);
      // ignore: missing_log_in_catch_block
    } on RemoteException catch (_) {
      rethrow;
      // ignore: missing_log_in_catch_block
    } catch (e) {
      throw RemoteException(kind: RemoteExceptionKind.decodeError, rootException: e);
    }
  }

  O? mapToDataModel({
    // ignore: avoid_dynamic
    required dynamic response,
    Decoder<I>? decoder,
  });
}
