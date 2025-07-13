import 'package:freezed_annotation/freezed_annotation.dart';

part 'initial_resource.freezed.dart';

@freezed
sealed class InitialResource with _$InitialResource {
  const InitialResource._();

  const factory InitialResource() = _InitialResource;
}
