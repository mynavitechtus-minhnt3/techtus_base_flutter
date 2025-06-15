
void main() {
  final future = Future(() {
    print('future');
  });

  // expect_lint: prefer_async_await
  future.then((value) => print('then'));

  // expect_lint: prefer_async_await
  future.then((value) => null).then((value) => null).then((value) => null);

  // expect_lint: prefer_async_await
  future.then((value) {
    print('then');
    // expect_lint: prefer_async_await
  }).then((value) {
    print('then');
    // expect_lint: prefer_async_await
  }).then((value) {
    print('then');
  });
}
