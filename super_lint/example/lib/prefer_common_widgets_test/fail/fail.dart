
void main() {
  // expect_lint: prefer_common_widgets
  Text('');
  // expect_lint: prefer_common_widgets
  AppBar();
  // expect_lint: prefer_common_widgets
  Image.network('');
  // expect_lint: prefer_common_widgets
  Image.asset('');
  // expect_lint: prefer_common_widgets
  Scaffold();
  // expect_lint: prefer_common_widgets
  Divider();
  // expect_lint: prefer_common_widgets
  VerticalDivider();
}

class CommonText {}

class CommonAppBar {}

class CommonImage {
  CommonImage();

  factory CommonImage.network(String url) => CommonImage();
}

class CommonScaffold {}

class CommonDivider {}
