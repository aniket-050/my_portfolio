class Breakpoints {
  const Breakpoints._();

  static const double mobile = 760;
  static const double tablet = 1080;

  static bool isMobile(double width) => width < mobile;

  static bool isTablet(double width) => width >= mobile && width < tablet;

  static bool isDesktop(double width) => width >= tablet;

  static double horizontalPadding(double width) {
    if (isDesktop(width)) {
      return 40;
    }
    if (isTablet(width)) {
      return 28;
    }
    return 18;
  }
}
