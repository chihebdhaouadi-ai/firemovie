import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static double? blockSizeHorizontal;
  static double? blockSizeVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    blockSizeHorizontal = screenWidth! / 100;
    blockSizeVertical = screenHeight! / 100;
  }
}

bool loaded_home = false;
List<String> options_movie_detail = ["GENRES", "CAST", "CREW", "PROD"];

List<dynamic> sidebar_data = [
  {"option_name": "Home", "icon_data": BootstrapIcons.house_fill},
  {"option_name": "Cinephiles List", "icon_data": BootstrapIcons.people_fill},
  {"option_name": "Settings", "icon_data": BootstrapIcons.gear_fill},
  {
    "option_name": "More About Cinema",
    "icon_data": BootstrapIcons.lightbulb_fill
  },
  {"option_name": "Contact Us! ", "icon_data": BootstrapIcons.globe2},
  {"option_name": "logout", "icon_data": BootstrapIcons.box_arrow_in_right}
];
List<dynamic> top_bar_searchfilm = [
  {"btn_string": "Action", "is_active": false},
  {"btn_string": "Adventure", "is_active": false},
  {"btn_string": "Fantasy", "is_active": false},
  {"btn_string": "Romance", "is_active": false}
];

List<dynamic> top_bar_search = [
  {"btn_string": "Films", "is_active": false},
  {"btn_string": "Acticles", "is_active": false},
  {"btn_string": "Members", "is_active": false},
  {"btn_string": "Crew", "is_active": false}
];

Map<String, String> streaming_platform = {
  "prime": "assets/prime.png",
  "apple": "assets/appletv1.png",
  "hbo": "assets/hbo.png",
  "netflix": "assets/netflix.png"
};
