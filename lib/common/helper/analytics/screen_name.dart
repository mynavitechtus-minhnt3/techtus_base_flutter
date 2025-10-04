enum ScreenName {
  allUsersPage(
    screenName: 'All Users Page',
    screenEventPrefix: 'all_users',
    screenClass: 'AllUsersPage',
  ),
  chatPage(
    screenName: 'Chat Page',
    screenEventPrefix: 'chat',
    screenClass: 'ChatPage',
  ),
  homePage(
    screenName: 'Home Page',
    screenEventPrefix: 'home',
    screenClass: 'HomePage',
  ),
  loadMoreExamplePage(
    screenName: 'Load More Example Page',
    screenEventPrefix: 'load_more_example',
    screenClass: 'LoadMoreExamplePage',
  ),
  loginPage(
    screenName: 'Login Page',
    screenEventPrefix: 'login',
    screenClass: 'LoginPage',
  ),
  mainPage(
    screenName: 'Main Page',
    screenEventPrefix: 'main',
    screenClass: 'MainPage',
  ),
  myProfilePage(
    screenName: 'My Profile Page',
    screenEventPrefix: 'my_profile',
    screenClass: 'MyProfilePage',
  ),
  registerPage(
    screenName: 'Register Page',
    screenEventPrefix: 'register',
    screenClass: 'RegisterPage',
  ),
  renameConversationPage(
    screenName: 'Rename Conversation Page',
    screenEventPrefix: 'rename_conversation',
    screenClass: 'RenameConversationPage',
  ),
  settingPage(
    screenName: 'Setting Page',
    screenEventPrefix: 'setting',
    screenClass: 'SettingPage',
  ),
  splashPage(
    screenName: 'Splash Page',
    screenEventPrefix: 'splash',
    screenClass: 'SplashPage',
  );

  const ScreenName({
    required this.screenName,
    required this.screenClass,
    required this.screenEventPrefix,
  });
  final String screenName;
  final String screenClass;
  final String screenEventPrefix;

  @override
  String toString() => '$name / $screenName / prefix: $screenEventPrefix';
}
