import 'package:flutter/cupertino.dart';

class CustomizationSettings {
  final Color mainScheme;
  final bool showYooKassaLogo;

  const CustomizationSettings([this.mainScheme = const Color.fromARGB(255, 0, 112, 240), this.showYooKassaLogo = true]);

  Map<String, dynamic> toJson() =>
      {
        'mainScheme' : {
          'red': mainScheme.red,
          'blue': mainScheme.blue,
          'green': mainScheme.green,
          'alpha': mainScheme.alpha
        },
        'showYooKassaLogo': showYooKassaLogo
      };
}