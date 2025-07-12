import 'package:freezed_annotation/freezed_annotation.dart';

part 'paging_data_response.freezed.dart';
part 'paging_data_response.g.dart';

@Freezed(genericArgumentFactories: true)
sealed class PagingDataResponse<T> with _$PagingDataResponse<T> {
  const factory PagingDataResponse({
    @JsonKey(name: 'results') List<T>? results,
    @JsonKey(name: 'page') int? page,
    @JsonKey(name: 'offset') int? offset,
    @JsonKey(name: 'total') int? total,
    @JsonKey(name: 'next') int? next,
    @JsonKey(name: 'prev') int? prev,
  }) = _PagingDataResponse<T>;

  factory PagingDataResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$PagingDataResponseFromJson(json, fromJsonT);
}
