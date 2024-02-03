class AssetHelper {

  static const String _svgPathPrefix = 'assets/svg/';

  // Get a svg path from a svg name.
  static String getSvgPath(String svgName) {
    return '$_svgPathPrefix$svgName.svg';
  }

}