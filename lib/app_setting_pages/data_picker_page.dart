import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/constant.dart';

class DateInputTextField extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DateInputTextFieldState();
  }
}

class _DateInputTextFieldState extends State<DateInputTextField> {
  @override
  Widget build(BuildContext context) {

    return TextFormField(
      decoration: InputDecoration(
          focusedBorder:APPConstants().focusInputBorder ,
          enabledBorder: APPConstants().enableInputBorder,
          // suffixIcon: IconButton(
          //   onPressed: (){
          //
          //   }, icon: Icon(Icons.search_outlined),
          // ),
          isDense: true,
          contentPadding: EdgeInsets.only(
              left: 15, right: 15, top: 5, bottom: 5),
          hintText: "COLOUR",
          hintStyle: TextStyle(
              color: Colors.black26

          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7.0),
            // borderSide: Border()
          )),
      keyboardType: TextInputType.number,
      inputFormatters: [DateTextFormatter()],
      onChanged: (String value) {},
    );
  }
}

class DateTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {

    //this fixes backspace bug
    if (oldValue.text.length >= newValue.text.length) {
      return newValue;
    }

    var dateText = _addSeperators(newValue.text, '/');
    return newValue.copyWith(text: dateText, selection: updateCursorPosition(dateText));
  }

  String _addSeperators(String value, String seperator) {
    value = value.replaceAll('/', '');
    var newString = '';
    for (int i = 0; i < value.length; i++) {
      // if(int.parse(value) <=31){
        newString += value[i];
      // }
        print("User Data is : ${newString}");

      if (i == 1) {
        print("date pick 65");
        print(int.parse(value));
        if(int.parse(newString) >31){

          return "";

        }
          newString += seperator;
        // }
        // else{
        //   return "" ;
        // }

      }
      if (i == 3) {
        // if(value.length <=2){
          newString += seperator;
        // }
        // newString += seperator;
      }
    }
    return newString;
  }

  TextSelection updateCursorPosition(String text) {
    return TextSelection.fromPosition(TextPosition(offset: text.length));
  }
}