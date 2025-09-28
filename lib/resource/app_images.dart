class $AssetsImagesGen {
  const $AssetsImagesGen();

  String get iconBack => 'assets/images/icon_back.svg';

  String get iconClose => 'assets/images/icon_close.svg';

  String get imageAppIcon => 'assets/images/image_app_icon.png';

  String get imageBackground => 'assets/images/image_background.png';

  String get imageDarkBackground => 'assets/images/image_dark_background.jpeg';

  /// List of all assets
  List<String> get values =>
      [iconBack, iconClose, imageAppIcon, imageBackground, imageDarkBackground];
}

class Assets {
  const Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
}
