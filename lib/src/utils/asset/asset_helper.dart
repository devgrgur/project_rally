class AssetHelper {

  static const String _svgPathPrefix = 'assets/svg/';
  static const String _imagePathPrefix = 'assets/images/';

  // Get a svg path from a svg name.
  static String getSvgPath(String svgName) {
    return '$_svgPathPrefix$svgName.svg';
  }

  static String getJpgPath(String jpgName) {
    return '$_imagePathPrefix$jpgName.jpg';
  }

}