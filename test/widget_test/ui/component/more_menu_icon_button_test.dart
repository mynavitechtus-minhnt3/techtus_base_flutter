import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nalsflutter/index.dart';

import '../../../common/index.dart';

void main() {
  group(
    'others',
    () {
      testGoldens('when it is normal state', (tester) async {
        await tester.testWidget(
          filename: 'more_menu_icon_button/when it is normal state',
          widget: MoreMenuIconButton(onCopy: () {}, onReply: () {}),
          useMultiScreenGolden: true,
          mergeToSingleFile: false,
        );
      });
    },
  );
}
