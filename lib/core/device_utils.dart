import 'package:flutter/material.dart';

class DeviceUtils {
  static int getCacheWidth(BuildContext context) {
    // Return display width * pixel ratio to match UI size perfectly in RAM
    return (MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio).round();
  }
}
