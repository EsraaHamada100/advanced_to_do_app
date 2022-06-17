import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeServices {
  // use the storage of Get to store the theme(dark|light) value
  // it only needs a key and a value to store
  final GetStorage _box = GetStorage();
  final _key = 'isDrakMode';

  // putting the data on the storage box
  _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

  // reading the data from the storage box
  // here I also told him is the value is not set yet make false as a default
  bool _loadThemeFromBox() => _box.read<bool>(_key)??false ;

  ThemeMode get theme => _loadThemeFromBox()? ThemeMode.dark : ThemeMode.light ;

  void switchTheme(){
    // here I change the mode than I save the changes mode to the storage
    Get.changeThemeMode(_loadThemeFromBox()?ThemeMode.light : ThemeMode.dark);
    _saveThemeToBox(!_loadThemeFromBox());
  }
}
