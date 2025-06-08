DART_TOOLS_PATH=./tools/dart_tools/lib

pg:
	flutter pub get
	cd super_lint && flutter pub get
	cd super_lint/example && flutter pub get

ln:
	flutter gen-l10n
	make sort_arb

sort_arb:
	dart run $(DART_TOOLS_PATH)/sort_arb_files.dart lib/resource/l10n

fb:
	dart run build_runner build --delete-conflicting-outputs --verbose

cc:
	dart run build_runner clean

ccfb:
	make cc
	make fb

cl:
	flutter clean && rm -rf pubspec.lock
	cd super_lint && flutter clean && rm -rf pubspec.lock
	cd super_lint/example && flutter clean && rm -rf pubspec.lock

sync:
	make pg
	make ln
	make cc
	make fb

ref:
	make cl
	make sync

pod:
	cd ios && rm -rf Pods && rm -f Podfile.lock && pod install --repo-update

pu:
	flutter pub upgrade

ci:
	cd tools/dart_tools && flutter pub get
	make check_pubs
	make rup
	make check_arb
	make fm
	make te
	make lint

check_pubs:
	dart run $(DART_TOOLS_PATH)/check_pubspecs.dart pubspec.yaml

rup:
	dart run $(DART_TOOLS_PATH)/remove_unused_pub.dart . comment

check_arb:
	dart run $(DART_TOOLS_PATH)/check_sorted_arb_keys.dart lib/resource/l10n
	make rul
	make rdl

rul:
	dart run $(DART_TOOLS_PATH)/remove_unused_l10n.dart lib/resource/l10n

rua:
	dart run $(DART_TOOLS_PATH)/remove_unused_asset.dart .

rdl:
	dart run $(DART_TOOLS_PATH)/remove_duplicate_l10n.dart lib/resource/l10n

fm:
	find . -name "*.dart" ! -name "*.g.dart" ! -name "*.freezed.dart" ! -name "*.gr.dart" ! -name "*.config.dart" ! -name "*.mocks.dart" ! -path '*/generated/*' ! -path '*/.dart_tool/*' | tr '\n' ' ' | xargs dart format --set-exit-if-changed -l 100
	make sort_arb

te:
	make ut
	make wt

ug:
	find . -type d -name "goldens" -exec rm -rf {} +
	flutter test --update-goldens --tags=golden

ut:
	flutter test test/unit_test

wt:
	flutter test test/widget_test

lint:
	make sl
	make analyze

sl:
	dart run $(DART_TOOLS_PATH)/super_lint.dart .

analyze:
	flutter analyze --no-pub --suppress-analytics

dart_fix:
	dart fix --apply

gen_ai:
	dart run flutter_launcher_icons:main -f app_icon/app-icon.yaml

gen_spl:
	dart run flutter_native_splash:create --path=splash/splash.yaml

rm_spl:
	dart run flutter_native_splash:remove --path=splash/splash.yaml

gen_env:
	dart run $(DART_TOOLS_PATH)/gen_env.dart .

build_stg_apk:
	flutter build apk --flavor staging -t lib/main.dart --dart-define-from-file=dart_defines/staging.json --verbose

build_prod_apk:
	flutter build apk --flavor production -t lib/main.dart --dart-define-from-file=dart_defines/production.json --verbose

build_stg_aab:
	flutter build appbundle --flavor staging -t lib/main.dart --dart-define-from-file=dart_defines/staging.json --verbose

build_prod_aab:
	flutter build appbundle --flavor production -t lib/main.dart --dart-define-from-file=dart_defines/production.json --verbose

build_stg_ipa:
	flutter build ipa --release --flavor staging -t lib/main.dart --dart-define-from-file=dart_defines/staging.json --export-options-plist=ios/exportOptions.plist --verbose

build_prod_ipa:
	flutter build ipa --release --flavor production -t lib/main.dart --dart-define-from-file=dart_defines/production.json --export-options-plist=ios/exportOptions.plist --verbose
