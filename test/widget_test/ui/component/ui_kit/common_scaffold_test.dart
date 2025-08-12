import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nalsflutter/resource/dimen/app_dimen.dart';
import 'package:nalsflutter/ui/component/ui_kit/common_app_bar.dart';
import 'package:nalsflutter/ui/component/ui_kit/common_scaffold.dart';
import '../../../../common/index.dart';

void main() {
  group(
    'CommonScaffold',
    () {
      testGoldens('basic', (tester) async {
        await tester.testWidget(
          filename: 'common_scaffold/basic',
          widget: Builder(builder: (context) {
            AppDimen.current = AppDimen.of(context);
            return CommonScaffold(
              appBar: CommonAppBar(
                text: 'Title',
                leadingIcon: LeadingIcon.none,
              ),
              body: const Center(child: Text('Body')),
            );
          }),
        );
      });

      testGoldens('with drawer and fab', (tester) async {
        await tester.testWidget(
          filename: 'common_scaffold/with_drawer_and_fab',
          widget: Builder(builder: (context) {
            AppDimen.current = AppDimen.of(context);
            return CommonScaffold(
              appBar: CommonAppBar(
                text: 'Title',
                leadingIcon: LeadingIcon.none,
              ),
              body: const Center(child: Text('Body')),
              drawer: const Drawer(child: Text('Drawer')),
              floatingActionButton: FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            );
          }),
        );
      });
    },
  );
}
