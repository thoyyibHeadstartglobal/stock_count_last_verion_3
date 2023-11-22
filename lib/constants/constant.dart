import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class APPConstants {

  static var baseUrl =
      "https://hsins28ce7a8bf606d8744bdevaos.axcloud.dynamics.com/api/services/"
      "CustomServiceGroup/CustomService/";

  static  var getTokenUrl
  ="https://login.microsoftonline.com/46f6488b-4363-4b2a-a0b3-4e889a754c02/oauth2/token";

  static var getTatameenDetails= "${baseUrl}getTatmeenDetails";



  static var appVersion ="v3.0";


   TextStyle bodyText= TextStyle(
    color: Colors.white
  );

  TextStyle noText= TextStyle(

      color: Colors.white
  );
  TextStyle YesText= TextStyle(

      color: Colors.white
  );

  Color disabledClr = Colors.grey;

 ButtonStyle  btnBackgroundNo = TextButton.styleFrom(
  backgroundColor: Colors.red
  );
Color colorRed = Colors.red;
  ButtonStyle  btnBackgroundYes = TextButton.styleFrom(
      backgroundColor: Colors.green
  );

  Color colorGreen = Color(0xff296921);
  Color? disabledRed = Colors.red[800];

  OutlineInputBorder focusInputBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.red, width: 0.5),
    borderRadius: BorderRadius.circular(10.0),
  );

  OutlineInputBorder enableInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
          color:  Colors.black,
          width: 0.5
      ));
}