// colo_extension.dart
import 'package:flutter/material.dart';

class Tcolor {
  static Color get primaryColor1 => const Color(0xff92A3FD);
  static Color get primaryColor2 => const Color(0xff9DCEFF);
  static Color get secondColor1 => const Color(0xffC58BF2);
  static Color get secondColor2 => const Color(0xffEEA4CE);
  static Color get pageColor1 => const Color(0xffc3d4e0);
  static Color get pageColor2 => const Color(0xffd1c5df);
  
  static List<Color> get primaryG => [ primaryColor1, primaryColor2 ];
  static List<Color> get secondaryG => [ secondColor1,secondColor2  ];
  static List<Color> get pageG => [ pageColor2,pageColor1  ];

  static Color get black => const Color(0xff1D1617);
  static Color get grey => const Color(0xff786F72);
  static Color get White => Colors.white;

}