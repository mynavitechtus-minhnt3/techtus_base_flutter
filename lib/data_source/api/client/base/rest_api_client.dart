import 'package:dio/dio.dart';

import '../../../../../index.dart';

enum RestMethod { get, post, put, patch, delete }

class RestApiClient {
  RestApiClient({
    required this.dio,
    this.errorResponseDecoderType = Constant.defaultErrorResponseDecoderType,
    this.successResponseDecoderType = Constant.defaultSuccessResponseDecoderType,
  });

  final SuccessResponseDecoderType successResponseDecoderType;
  final ErrorResponseDecoderType errorResponseDecoderType;
  final Dio dio;

  Future<FinalOutput?> request<FirstOutput extends Object, FinalOutput extends Object>({
    required RestMethod method,
    required String path,
    Map<String, dynamic>? queryParameters,
    Object? body,
    Decoder<FirstOutput>? decoder,
    SuccessResponseDecoderType? successResponseDecoderType,
    ErrorResponseDecoderType? errorResponseDecoderType,
    Options? options,
    // ignore: avoid_dynamic
    FinalOutput? Function(Response<dynamic> response)? customSuccessResponseDecoder,
  }) async {
    assert(
        method != RestMethod.get ||
            (successResponseDecoderType ?? this.successResponseDecoderType) ==
                SuccessResponseDecoderType.plain ||
            decoder != null,
        'decoder must not be null if method is GET');
    try {
      final response = await _requestByMethod(
        method: method,
        path: path.startsWith(dio.options.baseUrl)
            ? path.substring(dio.options.baseUrl.length)
            : path,
        queryParameters: queryParameters,
        body: body,
        options: Options(
          headers: options?.headers,
          contentType: options?.contentType,
          responseType: options?.responseType,
          sendTimeout: options?.sendTimeout,
          receiveTimeout: options?.receiveTimeout,
        ),
      );

      if (response.data == null) {
        return null;
      }

      if (customSuccessResponseDecoder != null) {
        return customSuccessResponseDecoder(response);
      }

      return BaseSuccessResponseDecoder<FirstOutput, FinalOutput>.fromType(
        successResponseDecoderType ?? this.successResponseDecoderType,
      ).map(response: response.data, decoder: decoder);
      // ignore: missing_log_in_catch_block
    } catch (error, _) {
      throw DioExceptionMapper(
        BaseErrorResponseDecoder.fromType(
          errorResponseDecoderType ?? this.errorResponseDecoderType,
        ),
      ).map(exception: error, apiInfo: ApiInfo(method: method.name, url: path));
    }
  }

  // ignore: avoid_dynamic
  Future<Response<dynamic>> _requestByMethod({
    required RestMethod method,
    required String path,
    Map<String, dynamic>? queryParameters,
    Object? body,
    Options? options,
  }) {
    switch (method) {
      case RestMethod.get:
        return dio.get(
          path,
          data: body,
          queryParameters: queryParameters,
          options: options,
        );
      case RestMethod.post:
        return dio.post(
          path,
          data: body,
          queryParameters: queryParameters,
          options: options,
        );
      case RestMethod.patch:
        return dio.patch(
          path,
          data: body,
          queryParameters: queryParameters,
          options: options,
        );
      case RestMethod.put:
        return dio.put(
          path,
          data: body,
          queryParameters: queryParameters,
          options: options,
        );
      case RestMethod.delete:
        return dio.delete(
          path,
          data: body,
          queryParameters: queryParameters,
          options: options,
        );
    }
  }

  Future<Response<T>> fetch<T>(RequestOptions requestOptions) async {
    try {
      return await dio.fetch<T>(requestOptions);
      // ignore: missing_log_in_catch_block
    } catch (error, _) {
      throw DioExceptionMapper(
        BaseErrorResponseDecoder.fromType(ErrorResponseDecoderType.jsonObject),
      ).map(
          exception: error,
          apiInfo: ApiInfo(method: requestOptions.method, url: requestOptions.path));
    }
  }
}
