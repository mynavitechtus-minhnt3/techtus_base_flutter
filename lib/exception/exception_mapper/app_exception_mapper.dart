import '../../index.dart';

abstract class AppExceptionMapper<T extends AppException> {
  T map({
    required Object? exception,
    required ApiInfo apiInfo,
  });
}
