// ignore_for_file: missing_log_in_catch_block
import '../../../../index.dart';

enum ErrorResponseDecoderType {
  jsonObject,
  jsonArray,
  line,
}

abstract class BaseErrorResponseDecoder<T extends Object> {
  const BaseErrorResponseDecoder();

  factory BaseErrorResponseDecoder.fromType(ErrorResponseDecoderType type) {
    switch (type) {
      case ErrorResponseDecoderType.jsonObject:
        return JsonObjectErrorResponseDecoder() as BaseErrorResponseDecoder<T>;
      case ErrorResponseDecoderType.jsonArray:
        return JsonArrayErrorResponseDecoder() as BaseErrorResponseDecoder<T>;
      case ErrorResponseDecoderType.line:
        return LineErrorResponseDecoder() as BaseErrorResponseDecoder<T>;
    }
  }

  ServerError map({
    // ignore: avoid_dynamic
    required dynamic errorResponse,
    required ApiInfo apiInfo,
  }) {
    try {
      if (errorResponse is! T) {
        throw RemoteException(
          kind: RemoteExceptionKind.decodeError,
          rootException: 'Response ${errorResponse} is not $T',
        );
      }

      final serverError = mapToServerError(errorResponse);

      return serverError;
      // ignore: unused_catch_clause
    } on RemoteException catch (e) {
      rethrow;
    } catch (e) {
      throw RemoteException(
        kind: RemoteExceptionKind.decodeError,
        rootException: e,
        apiInfo: apiInfo,
      );
    }
  }

  ServerError mapToServerError(T? errorResponse);
}
