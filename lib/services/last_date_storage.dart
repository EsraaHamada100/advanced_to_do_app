import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class LastDateStorage {
  // use the storage of Get to store the theme(dark|light) value
  // it only needs a key and a value to store
  final GetStorage _box = GetStorage();
  final _key = 'lastDate';

  // putting the data on the storage box
  _saveDateToBox(int day) => _box.write(_key, day);

  // reading the data from the storage box
  // here I also told him is the value is not set yet make false as a default
  int _loadDateFromBox() => _box.read<int>(_key)??0 ;

  // this function is used to delete previous days data once every day
  bool shouldDeletePreviousDayData(){

    // String now = DateFormat.yMd().format(DateTime.now());
      int day = _loadDateFromBox();
      int currentDay = DateTime.now().day;
      if(day != currentDay){
        _saveDateToBox(currentDay);
        return true;
    }
    return false;
  }

}
