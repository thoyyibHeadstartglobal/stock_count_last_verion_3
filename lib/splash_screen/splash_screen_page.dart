import 'dart:async';
import 'dart:io';
import 'package:dynamicconnectapp/common_pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../helper/local_db.dart';
import '../app_setting_pages/project_setting_environment_page.dart';
import '../common_pages/login_page.dart';

class SplashScreenPage extends StatefulWidget {
  SplashScreenPage({Key? key}) : super(key: key);

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {

  String ? baseUrlString;
  String? companyCode;
  String? accessUrl;
  String? tenantId;
  String? clientId;
  String? clientSecretId;
  String? resource;
  String? grantType;
  String? pullStockTakeApi;
  String? pushStockTakeApi;

  final SQLHelper _sqlHelper = SQLHelper();
  String ? username;
  String ? password;
  bool ? isLogged;
  SharedPreferences ? prefs;

  checkCredentials() async {

    await  _sqlHelper.initDb();

    await _sqlHelper.getUserLogin();
    await _sqlHelper.getUserLoginHSAdmin();

    prefs = await SharedPreferences.getInstance();
    print("camera status");
    print(await prefs?.getString("camera"));

    password = await prefs?.getString(
        "password");
    isLogged = await prefs?.getBool("isLoggedIn")??false;
    isLogged! ? username= await  prefs?.getString(
        "username"):
    username = null;

    companyCode=  await prefs!
        .getString("companyCode");
    baseUrlString=  await prefs!
        .getString("baseUrl");
    accessUrl=  await prefs!
        .getString("accessUrl");
    tenantId=  await prefs!
        .getString("tenantId");
    clientId=  await prefs!
        .getString("clientId");
    clientSecretId= await prefs!
        .getString("clientSecret");
    resource= await prefs!
        .getString("resource");
    grantType= await prefs!
        .getString("grantType");
    pullStockTakeApi=   await prefs!
        .getString("pullStockTakeApi");
    pushStockTakeApi=  await prefs!
        .getString(
        "pushStockTakeApi");
    // print(deviceId);

    baseUrlString = baseUrlString ?? "";

    setState(() {});

  }



  @override
  void initState() {

    // return;
    checkCredentials();

    Timer(Duration(seconds: 2),

            () {

          setState(() {

              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder:
                      (context) =>
                  baseUrlString == null || baseUrlString == "null" ||
                      accessUrl == null || accessUrl == "null" ?
                  ProjectSettingsEnvironmentPage(
                    isSettings: false,
                  ) : username == null ?
                  LoginPage()
                      : LandingHomePage(),
                  )
              );
          });
        }
    );
    super.initState();
  }
  int   _selectedIndex =0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xffffffff),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Expanded(
            //   child: Container(
            //     height: 200,
            //     child: Row(
            //       children: <Widget>[
            //         NavigationRail(
            //           backgroundColor: Colors.purple[800],
            //           selectedIndex: _selectedIndex,
            //           selectedLabelTextStyle: TextStyle(
            //               fontWeight: FontWeight.bold,
            //               fontSize: 18,
            //               letterSpacing: 1.0,
            //               decoration: TextDecoration.underline),
            //           unselectedLabelTextStyle: TextStyle(color: Colors.white),
            //           onDestinationSelected: (int index) {
            //             setState(() {
            //               _selectedIndex = index;
            //             });
            //           },
            //           groupAlignment: 1.0,
            //           labelType: NavigationRailLabelType.all,
            //           leading: Column(
            //             children: <Widget>[
            //               CircleAvatar(
            //                 backgroundImage: AssetImage('assets/appIcon.png'),
            //               ),
            //               SizedBox(height: 20),
            //             ],
            //           ),
            //           destinations: [
            //             NavigationRailDestination(
            //               icon: Icon(Icons.dashboard, color: Colors.white,),
            //               selectedIcon: Icon(Icons.dashboard, color: Colors.white,),
            //               label: Text("Dashboard", style: TextStyle(color: Colors.white))
            //             ),
            //             NavigationRailDestination(
            //               icon: Icon(Icons.list, color: Colors.white,),
            //               selectedIcon: Icon(Icons.list, color: Colors.white,),
            //               label: Text("Details", style: TextStyle(color: Colors.white))
            //             ),
            //             NavigationRailDestination(
            //               icon: Icon(Icons.info_outline, color: Colors.white,),
            //               selectedIcon: Icon(Icons.info, color: Colors.white,),
            //               label: Text("About", style: TextStyle(color: Colors.white))
            //             ),
            //             // NavigationRailDestination(
            //             //     icon: SizedBox.shrink(),
            //             //     label: Padding(
            //             //       padding: const EdgeInsets.symmetric(vertical: 24),
            //             //       child: RotatedBox(
            //             //         quarterTurns: -1,
            //             //         child: Text(
            //             //           "Featured",
            //             //           style: TextStyle(color: Colors.white),
            //             //         ),
            //             //       ),
            //             //     )),
            //             // NavigationRailDestination(
            //             //     icon: SizedBox.shrink(),
            //             //     label: Padding(
            //             //       padding: const EdgeInsets.symmetric(vertical: 24),
            //             //       child: RotatedBox(
            //             //         quarterTurns: -1,
            //             //         child: Text(
            //             //           "Newest",
            //             //           style: TextStyle(color: Colors.white),
            //             //         ),
            //             //       ),
            //             //     )),
            //             // NavigationRailDestination(
            //             //     icon: SizedBox.shrink(),
            //             //     label: Padding(
            //             //       padding: const EdgeInsets.symmetric(vertical: 24),
            //             //       child: RotatedBox(
            //             //         quarterTurns: -1,
            //             //         child: Text(
            //             //           "Collection",
            //             //           style: TextStyle(color: Colors.white),
            //             //         ),
            //             //       ),
            //             //     )),
            //             // NavigationRailDestination(
            //             //     icon: SizedBox.shrink(),
            //             //     label: Padding(
            //             //       padding: const EdgeInsets.symmetric(vertical: 24),
            //             //       child: RotatedBox(
            //             //         quarterTurns: -1,
            //             //         child: Text(
            //             //           "About Us",
            //             //           style: TextStyle(color: Colors.white),
            //             //         ),
            //             //       ),
            //             //     ))
            //           ],
            //         ),
            //         // Expanded(child: screens[_selectedIndex])
            //       ],
            //     ),
            //   ),
            // ),
                    Container(
                      // alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height/6,
            width: MediaQuery.of(context).size.width,
                     decoration: BoxDecoration(
                    image: DecorationImage(
            fit: BoxFit.fitHeight,
                    image: AssetImage( "assets/appIcon.png"),
              ),
                      color: Colors.transparent,


                    ),
              ),
          ],
        ),
      )
    );
  }
}
