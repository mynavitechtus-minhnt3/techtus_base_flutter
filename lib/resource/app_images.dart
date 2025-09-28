class $AssetsImagesGen {
  const $AssetsImagesGen();

  String get appIcon => 'assets/images/app_icon.png';

  String get iconBack => 'assets/images/icon_back.svg';

  String get iconClose => 'assets/images/icon_close.svg';

  String get imageBackground => 'assets/images/image_background.png';

  String get imageDarkBackground => 'assets/images/image_dark_background.jpeg';

  /// List of all assets
  List<String> get values => [appIcon, iconBack, iconClose, imageBackground, imageDarkBackground];
}

class Assets {
  const Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
}
