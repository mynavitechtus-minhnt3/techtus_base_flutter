class ApiInfo {
  ApiInfo({
    required this.method,
    required this.url,
  });
  final String method;
  final String url;

  @override
  String toString() => '${method.toUpperCase()} $url';
}
