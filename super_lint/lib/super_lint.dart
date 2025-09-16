import 'src/index.dart';

PluginBase createPlugin() => _SuperLintPlugin();

class _SuperLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    return [
      AvoidUnnecessaryAsyncFunction(configs),
      PreferNamedParameters(configs),
      PreferIsEmptyString(configs),
      PreferIsNotEmptyString(configs),
      IncorrectTodoComment(configs),
      PreferAsyncAwait(configs),
      PreferLowerCaseTestDescription(configs),
      TestFolderMustMirrorLibFolder(configs),
      AvoidHardCodedColors(configs),
      PreferCommonWidgets(configs),
      AvoidHardCodedStrings(configs),
      IncorrectParentClass(configs),
      MissingExpandedOrFlexible(configs),
      PreferImportingIndexFile(configs),
      AvoidUsingTextStyleConstructorDirectly(configs),
      IncorrectScreenNameParameterValue(configs),
      IncorrectEventParameterName(configs),
      IncorrectEventParameterType(configs),
      IncorrectEventName(configs),
      IncorrectScreenNameEnumValue(configs),
      AvoidDynamic(configs),
      AvoidNestedConditions(configs),
      AvoidUsingIfElseWithEnums(configs),
      AvoidUsingUnsafeCast(configs),
      MissingLogInCatchBlock(configs),
      MissingRunCatching(configs),
      UtilFunctionsMustBeStatic(configs),
      MissingExtensionMethodForEvents(configs),
      MissingCommonScrollbar(configs),
      IncorrectFreezedDefaultValueType(configs),
      PreferSingleWidgetPerFile(configs),
      RequireMatchingFileAndClassName(configs),
      MissingGoldenTest(configs),
      AvoidUsingDateTimeNow(configs),
      EmptyTestGroup(configs),
      IncorrectGoldenImageName(configs),
      InvalidTestGroupName(configs),
      MissingTestGroup(configs),
    ];
  }
}
