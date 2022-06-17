import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list/ui/size_config.dart';
import 'package:to_do_list/ui/theme.dart';

class InputField extends StatelessWidget {
  const InputField(
      {Key? key,
      required this.title,
      required this.hint,
      this.controller,
      this.widget})
      : super(key: key);
  final String title;
  final String hint;
  final TextEditingController? controller;
  final Widget? widget;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15,bottom: 7),
            child: Text(
              title,
              style: titleStyle,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 8),
            margin: const EdgeInsets.only(left: 14),
            width: double.maxFinite,
            height: 52,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),),
            child: Row(
              children: [
                Expanded(
                    child: TextFormField(
                  controller: controller,
                  autofocus: false,
                  cursorColor: Get.isDarkMode? Colors.grey[100]:Colors.grey[600],
                  readOnly: widget!= null ?true : false,
                  style: subTitleStyle,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 10, bottom: 20),
                      hintText: hint,
                      hintStyle: subTitleStyle,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: context.theme.backgroundColor,
                        width: 0,
                      ),
                    ),
                    focusedBorder:UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: context.theme.backgroundColor,
                        width: 0,
                      ),
                    ),
                  ),
                )),
                // if the widget is null we will just send an empty container
                widget ?? Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
