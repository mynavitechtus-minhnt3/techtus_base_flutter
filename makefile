DART_TOOLS_PATH=./tools/dart_tools/lib

pg:
	flutter pub get
	cd super_lint && flutter pub get
	cd super_lint/example && flutter pub get

ln:
	flutter gen-l10n
	make sort_arb

check_page_routes:
	dart run $(DART_TOOLS_PATH)/check_page_routes.dart $(if $(skip_error),--skip-error,)

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
	make delete_empty_folders
	make sync
	make pu
	make pod

pod:
	cd ios && rm -rf Pods && rm -f Podfile.lock && pod install --repo-update

pu:
	flutter pub upgrade

check_ci:
	cd tools/dart_tools && flutter pub get
	make check_pubs
	make check_page_routes
	make check_component_usage
	make check_assets_structure
	make ep
	make rup
	make rua
	make fds
	make fcl
	make fm
	make te
	make lint

ci:
	cd tools/dart_tools && flutter pub get
	make check_pubs skip_error=true
	make check_page_routes skip_error=true
	make check_component_usage skip_error=true
	make check_assets_structure skip_error=true
	make ep skip_error=true
	make rup skip_error=true
	make rua skip_error=true
	make fds skip_error=true
	make fcl skip_error=true
	make fm skip_error=true
	make te skip_error=true
	make lint skip_error=true

check_pubs:
	dart run $(DART_TOOLS_PATH)/check_pubspecs.dart pubspec.yaml $(if $(skip_error),--skip-error,)

rup:
	dart run $(DART_TOOLS_PATH)/remove_unused_pub.dart . comment $(if $(skip_error),--skip-error,)

check_sorted_arb_keys:
	dart run $(DART_TOOLS_PATH)/check_sorted_arb_keys.dart lib/resource/l10n $(if $(skip_error),--skip-error,)

fcl:
	make check_sorted_arb_keys skip_error=$(skip_error)
	make clc skip_error=$(skip_error)
	make rul skip_error=$(skip_error)
	make rdl skip_error=$(skip_error)

rul:
	dart run $(DART_TOOLS_PATH)/remove_unused_l10n.dart lib/resource/l10n $(if $(skip_error),--skip-error,)

rua:
	dart run $(DART_TOOLS_PATH)/remove_unused_asset.dart . $(if $(skip_error),--skip-error,)

fds:
	dart run $(DART_TOOLS_PATH)/find_duplicate_svg.dart assets/images $(if $(skip_error),--skip-error,)

rdl:
	dart run $(DART_TOOLS_PATH)/remove_duplicate_l10n.dart lib/resource/l10n $(if $(skip_error),--skip-error,)

clc:
	dart run $(DART_TOOLS_PATH)/check_l10n_convention.dart lib/resource/l10n $(if $(skip_error),--skip-error,)

ga:
	dart run $(DART_TOOLS_PATH)/gen_assets.dart .
	find lib/resource -name "*.dart" ! -name "*.g.dart" ! -name "*.freezed.dart" ! -name "*.gr.dart" ! -name "*.config.dart" ! -name "*.mocks.dart" ! -path '*/generated/*' ! -path '*/.dart_tool/*' | tr '\n' ' ' | xargs dart format -l 100

gap:
	dart run $(DART_TOOLS_PATH)/gen_all_pages.dart
	make ep check=false

ep:
	@if [ "$(check)" = "false" ]; then \
		dart run $(DART_TOOLS_PATH)/export_all_files.dart lib $(if $(skip_error),--skip-error,); \
	else \
		dart run $(DART_TOOLS_PATH)/export_all_files.dart lib --check $(if $(skip_error),--skip-error,); \
	fi

check_component_usage:
	dart run $(DART_TOOLS_PATH)/check_component_usage.dart $(if $(skip_error),--skip-error,)

check_assets_structure:
	dart run $(DART_TOOLS_PATH)/check_assets_structure.dart $(if $(skip_error),--skip-error,)

gen_api:
	@INPUT_PATH=$${input_path:-docs/api_doc}; \
	CMD="dart run $(DART_TOOLS_PATH)/gen_api_from_swagger.dart --input_path=$$INPUT_PATH"; \
	if [ ! -z "$(output_path)" ]; then \
		CMD="$$CMD --output_path=$(output_path)"; \
	fi; \
	if [ ! -z "$(replace)" ]; then \
		CMD="$$CMD --replace=$(replace)"; \
	fi; \
	if [ ! -z "$(apis)" ]; then \
		CMD="$$CMD --apis=$(apis)"; \
	fi; \
	echo "🚀 Running: $$CMD"; \
	$$CMD; \
	make ep check=false

fm:
	@if [ "$(skip_error)" = "true" ]; then \
		find . -name "*.dart" ! -name "*.g.dart" ! -name "*.freezed.dart" ! -name "*.gr.dart" ! -name "*.config.dart" ! -name "*.mocks.dart" ! -path '*/generated/*' ! -path '*/.dart_tool/*' | tr '\n' ' ' | xargs dart format -l 100; \
	else \
		find . -name "*.dart" ! -name "*.g.dart" ! -name "*.freezed.dart" ! -name "*.gr.dart" ! -name "*.config.dart" ! -name "*.mocks.dart" ! -path '*/generated/*' ! -path '*/.dart_tool/*' | tr '\n' ' ' | xargs dart format --set-exit-if-changed -l 100; \
	fi
	make sort_arb

te:
	make ut skip_error=$(skip_error)
	make wt skip_error=$(skip_error)

ug:
	find . -type d -name "goldens" -exec rm -rf {} +
	flutter test --update-goldens --tags=golden

ut:
	@if [ "$(skip_error)" = "true" ]; then \
		flutter test test/unit_test || true; \
	else \
		flutter test test/unit_test; \
	fi

wt:
	@if [ "$(skip_error)" = "true" ]; then \
		flutter test test/widget_test || true; \
	else \
		flutter test test/widget_test; \
	fi

lint:
	make sl skip_error=$(skip_error)
	make analyze skip_error=$(skip_error)

sl:
	tools/bash/super_lint.sh $(if $(skip_error),--skip-error,)

analyze:
	@if [ "$(skip_error)" = "true" ]; then \
		flutter analyze --no-pub --suppress-analytics || true; \
	else \
		flutter analyze --no-pub --suppress-analytics; \
	fi

dart_fix:
	dart fix --apply

delete_empty_folders:
	@if [ "$(dry_run)" = "true" ]; then \
		dart run $(DART_TOOLS_PATH)/cleanup_empty_page_folders.dart $(if $(path),$(path),lib/ui/page) --dry-run; \
	else \
		dart run $(DART_TOOLS_PATH)/cleanup_empty_page_folders.dart $(if $(path),$(path),lib/ui/page); \
	fi

gen_ai:
	dart run flutter_launcher_icons:main -f app_icon/app-icon.yaml

gen_spl:
	dart run flutter_native_splash:create --path=splash/splash.yaml

rm_spl:
	dart run flutter_native_splash:remove --path=splash/splash.yaml

gen_env:
	dart run $(DART_TOOLS_PATH)/gen_env.dart .

reset:
	dart run tools/dart_tools/lib/reset_project.dart
	make gap
	cd tools/dart_tools && flutter pub get
	make check_pubs skip_error=true
	make check_page_routes skip_error=true
	make check_component_usage skip_error=true
	make check_assets_structure skip_error=true
	make ep skip_error=true
	make rup skip_error=true
	make rua skip_error=true
	make fds skip_error=true
	make fcl skip_error=true
	make fm skip_error=true
	make sync

init:
	dart run tools/dart_tools/lib/init_project.dart

build_dev_apk:
	flutter build apk --flavor develop -t lib/main.dart --dart-define-from-file=dart_defines/develop.json --verbose

build_qa_apk:
	flutter build apk --flavor qa -t lib/main.dart --dart-define-from-file=dart_defines/qa.json --verbose

build_stg_apk:
	flutter build apk --flavor staging -t lib/main.dart --dart-define-from-file=dart_defines/staging.json --verbose

build_prod_apk:
	flutter build apk --flavor production -t lib/main.dart --dart-define-from-file=dart_defines/production.json --verbose

build_dev_aab:
	flutter build appbundle --flavor develop -t lib/main.dart --dart-define-from-file=dart_defines/develop.json --verbose

build_qa_aab:
	flutter build appbundle --flavor qa -t lib/main.dart --dart-define-from-file=dart_defines/qa.json --verbose

build_stg_aab:
	flutter build appbundle --flavor staging -t lib/main.dart --dart-define-from-file=dart_defines/staging.json --verbose

build_prod_aab:
	flutter build appbundle --flavor production -t lib/main.dart --dart-define-from-file=dart_defines/production.json --verbose

build_dev_ipa:
	flutter build ipa --release --flavor develop -t lib/main.dart --dart-define-from-file=dart_defines/develop.json --export-options-plist=ios/exportOptions.plist --verbose

build_qa_ipa:
	flutter build ipa --release --flavor qa -t lib/main.dart --dart-define-from-file=dart_defines/qa.json --export-options-plist=ios/exportOptions.plist --verbose

build_stg_ipa:
	flutter build ipa --release --flavor staging -t lib/main.dart --dart-define-from-file=dart_defines/staging.json --export-options-plist=ios/exportOptions.plist --verbose

build_prod_ipa:
	flutter build ipa --release --flavor production -t lib/main.dart --dart-define-from-file=dart_defines/production.json --export-options-plist=ios/exportOptions.plist --verbose

cd_dev:
	make cd_dev_android
	make cd_dev_ios

cd_qa:
	make cd_qa_android
	make cd_qa_ios

cd_stg:
	make cd_stg_android
	make cd_stg_ios

cd_dev_android:
	cd android && fastlane increase_version_build_and_up_firebase_develop

cd_qa_android:
	cd android && fastlane increase_version_build_and_up_firebase_qa

cd_stg_android:
	cd android && fastlane increase_version_build_and_up_firebase_staging

cd_dev_ios:
	cd ios && fastlane increase_version_build_and_up_testflight_develop

cd_qa_ios:
	cd ios && fastlane increase_version_build_and_up_testflight_qa

cd_stg_ios:
	cd ios && fastlane increase_version_build_and_up_testflight_staging

fastlane_update_plugins:
	cd ios && bundle install && fastlane update_plugins
	cd android && bundle install && fastlane update_plugins

cov:
	flutter test --coverage
	lcov --remove coverage/lcov.info \
	'*/*.g.dart' \
	'*/*.freezed.dart' \
	'*/*.gr.dart' \
	'*/*.mapper.dart' \
	'*/*.config.dart' \
	'*/*.gen.dart' \
	'*/*.mocks.dart' \
	'**/generated/*' \
	-o coverage/lcov.info --ignore-errors unused
	genhtml coverage/lcov.info -o coverage/html
	open coverage/html/index.html

cov_ut:
	flutter test test/unit_test --coverage
	lcov --remove coverage/lcov.info \
	'lib/data_source/api/client/*_client.dart' \
	'lib/data_source/api/*_service.dart' \
	'lib/data_source/api/middleware/custom_log_interceptor.dart' \
	'lib/data_source/api/middleware/base_interceptor.dart' \
	'lib/data_source/firebase' \
	'lib/data_source/preference/app_preferences.dart' \
	'lib/model/api/*_data.dart' \
	'lib/model/firebase' \
	'lib/model/other' \
	'lib/model/mapper/base/base_data_mapper.dart' \
	'lib/exception/app_exception.dart' \
	'lib/exception/exception_mapper/app_exception_mapper.dart' \
	'lib/exception/exception_handler/exception_handler.dart' \
	'lib/common/config.dart' \
	'lib/common/constant.dart' \
	'lib/common/env.dart' \
	'lib/common/helper' \
	'lib/common/type' \
	'lib/common/util/log.dart' \
	'lib/common/util/file_util.dart' \
	'lib/common/util/ref_ext.dart' \
	'lib/common/util/view_util.dart' \
	'lib/main.dart' \
	'lib/ui/my_app.dart' \
	'lib/di.dart' \
	'lib/di.config.dart' \
	'lib/index.dart' \
	'lib/app_initializer.dart' \
	'lib/ui/base' \
	'lib/ui/component' \
	'lib/ui/popup' \
	'lib/ui/page/*_page.dart' \
	'lib/navigation' \
	'lib/resource' \
	'*/*.g.dart' \
	'*/*.freezed.dart' \
	'*/*.gr.dart' \
	'*/*.mapper.dart' \
	'*/*.config.dart' \
	'*/*.gen.dart' \
	'*/*.mocks.dart' \
	'**/generated/*' \
	-o coverage/lcov.ut.info --ignore-errors unused
	genhtml coverage/lcov.ut.info -o coverage/html
	open coverage/html/index.html

cov_wt:
	flutter test test/widget_test --coverage
	lcov --remove coverage/lcov.info \
	'lib/ui/base' \
	'lib/ui/shared' \
	'lib/ui/my_app.dart' \
	'*/*.g.dart' \
	'*/*.freezed.dart' \
	'*/*.gr.dart' \
	'*/*.mapper.dart' \
	'*/*.config.dart' \
	'*/*.gen.dart' \
	'*/*.mocks.dart' \
	'**/generated/*' \
	-o coverage/lcov.cleaned.info --ignore-errors unused
	lcov --extract coverage/lcov.cleaned.info "lib/ui/*" -o coverage/lcov.wt.info
	genhtml coverage/lcov.wt.info -o coverage/html
	open coverage/html/index.html
