import 'package:flutter/cupertino.dart';



import 'home_page.dart';
class AppRoutes {
  // static const String welcomeSplashRoute = "/";
  static const String welcomeHomePage = "/home";

  static Map<String, WidgetBuilder> mRoutes = {
    welcomeHomePage: (_) => HomePage(),

  };
}