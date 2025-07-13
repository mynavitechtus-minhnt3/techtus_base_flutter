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
  contactListPage(
    screenName: 'Contact List Page',
    screenEventPrefix: 'contact_list',
    screenClass: 'ContactListPage',
  ),
  homePage(
    screenName: 'Home Page',
    screenEventPrefix: 'home',
    screenClass: 'HomePage',
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
  myPage(
    screenName: 'My Page',
    screenEventPrefix: 'my',
    screenClass: 'MyPage',
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
