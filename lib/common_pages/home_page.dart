import 'dart:convert';

import 'package:dynamicconnectapp/constants/constant.dart';
import 'package:dynamicconnectapp/home_list/import_data_page.dart';
import 'package:dynamicconnectapp/home_list/onhand_page.dart';
import 'package:dynamicconnectapp/home_list/price_check_page.dart';
import 'package:dynamicconnectapp/home_list/transaction_view_pages/transaction_view_page.dart';
import 'package:dynamicconnectapp/common_pages/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_setting_pages/app_settings_page.dart';
import 'package:http/http.dart' as http;

import '../helper/local_db.dart';
import '../home_list/home_history_page.dart';

import '../home_list/view_item_masters_page.dart';

class LandingHomePage extends StatefulWidget {
  const LandingHomePage({Key? key}) : super(key: key);

  @override
  State<LandingHomePage> createState() => _LandingHomePageState();
}

class _LandingHomePageState extends State<LandingHomePage> {
  SharedPreferences? prefs;

  @override
  void initState() {
    getUserData();
    getStoreCode();
    getToken();

    super.initState();
  }

  String? userId;
  String? username;
  String? password;
  String? userType;
  String? token;

  String? baseUrlString;
  String? companyCode;
  String? accessUrl;
  String? tenantId;
  String? clientId;
  String? clientSecretId;
  String? resource;
  String? grantType;
  String? pullStockTakeApi;
  String? pushStockTakeApi;
  String? getStore;
  String? getDevice;
  String? getDeactivate;
  String? updateDevice;
  String? disableCamera;
  List<dynamic> homeList = [];
  List<dynamic> transactionTypeList = [];
  List<dynamic> importedList = [];
  var APPGENERALDATASave;
  SQLHelper _sqlHelper = SQLHelper();


  showDialogMessage(context) {
    // print(onpress);
    // return;
    showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("DynamicsConnect"),
            content: Text("Are You Sure To Refresh?"),
            actions: <Widget>[
              TextButton(
                style: APPConstants().btnBackgroundNo,
                child: Text(
                  "No",
                  style: APPConstants().noText,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                style: APPConstants().btnBackgroundYes,
                child: Text(
                    "Yes",
                    style: APPConstants().YesText
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  importedList.clear();
                  await _sqlHelper.deleteItemMaster();
                  // return;
                  await showLoaderDialog(context);
                  pullData();

                  // Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  showDialogGotData(String text) {
    // set up the button
    Widget yesButton = TextButton(
      style: APPConstants().btnBackgroundYes,
      child: Text(
        "Ok",
        style: APPConstants().YesText,
      ),
      onPressed: () {
        // saveSettings();
        setState(() {});
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      // title: Text("User Added Successfully"),
      content: Text(
        "$text",
      ),
      actions: [
        // noButton,
        yesButton
      ],
    );

    // show the dialog
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showDialogGotDataWithOperation({String? text, dynamic op}) {
    // set up the button
    Widget scanButton = TextButton(
      style: APPConstants().btnBackgroundYes,
      child: Text(
        "Ok",
        style: APPConstants().YesText,
      ),
      onPressed: () {
        print("Scanning code");
        setState(() {});
        // Navigator.pop(context);
        Navigator.pop(context);
        op;
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(

      title: Text("DynamicsConnect"),
      content: Text("$text"),
      actions: [
        scanButton,
      ],
    );

    // show the dialog
    showDialog(

      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  int lastRecId = 0;


  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      elevation: 0.0,
      backgroundColor: Colors.white,
      content: Container(
        alignment: Alignment.center,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Container(child: Text("Refreshing...")),
            Spacer(),
            CircularProgressIndicator(),
            Spacer(),
          ],
        ),
      ),
    );
    showDialog(
      // barrierColor: Colors.transparent,
      useSafeArea: true,
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(onWillPop: () async => false, child: alert);
      },
    );
  }

  pullData() async {

    print("$pullStockTakeApi");
    // return;
    var tk = 'Bearer ${token.toString()}';
    Map<String, String> headers = {
      "Content-type": "application/json",
      'Authorization': tk
    };

    var body;

    body = {
      "transType": 2, // 1- Counting                 2- Item master
      //     3- Open Purchase order lines 4- Invoiced Purchase lines
      "transactionId":
          "", // Counting journal number , empty string for Item master , Purchase order number
      "items": 0, // all items STOCK COUNT  : items =0 , from journal items=1
      "topCount": 1000,
      "lastRecid": lastRecId,
      "dataAreaId": "$companyCode",
      "storeCode": APPGENERALDATASave['STORECODE']
    };

    print(body);

    // return;
    var ur = "$pullStockTakeApi";
    print(ur);
    var js = json.encode(body);
    var res = await http.post(headers: headers, Uri.parse(ur), body: js);
    var responseJson = json.decode(res.body);
    print(responseJson);


    if (responseJson[0]['Importdata'] == null ||
        responseJson[0]['Importdata'].length == 0) {
      Navigator.pop(context);
      showDialogGotData("${responseJson[0]['Message'].toString()}");
      return;
    }

    importedList.addAll(responseJson[0]['Importdata']);
    List<dynamic> listDt = [];

    lastRecId = responseJson[0]['LastRecId'];

    listDt.addAll(responseJson[0]['Importdata']);

    listDt.forEach((element) {
      _sqlHelper.addItemMasterToPullData(
        ITEMBARCODE: element['ITEMBARCODE'],
        ItemId: element['ItemId'],
        ItemName: element['ItemName'],
        DATAAREAID: element['DATAAREAID'],
        WAREHOUSE: element['WAREHOUSE'],
        CONFIGID: element['CONFIGID'],
        COLORID: element['COLORID'],
        SIZEID: element['SIZEID'],
        STYLEID: element['STYLEID'],
        INVENTSTATUS: element['INVENTSTATUS'],
        QTY: element['QTY'],
        UNIT: element['UNIT'],
        ItemAmount: element['ItemAmount'],
        BatchEnabled: element['BatchEnabled'],
        BatchedItem: element['BatchedItem']
      );
    });


    setState(() {});

    print("recID is : ${lastRecId.toString()}");
    print(
        "import Data length : ${responseJson[0]['Importdata'].isEmpty.toString()}");

    if (lastRecId == 0) {
      print("This is Last Record ");

      print("This is item master");
      // List<dynamic> uniquesList =  importedList.toSet().toList();

      await _sqlHelper.addMASTERTOFEATURES();
      Navigator.pop(context);


      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showDialogGotDataWithOperation(
            op: () {
              Navigator.pop(context);
            },
            text:
                "${importedList.length.toString()} Barcodes has been downloaded");
      });
      return;
    }

    pullData();
  }


  getUserData() async {
    prefs = await SharedPreferences.getInstance();
    username = await prefs?.getString("username");
    password = await prefs?.getString("password");
    userType = await prefs?.getString("userType");
    userId = await prefs?.getString("userId");
    setState(() {});
    print("username is : ${username}");
    getDevices();
  }

  var selectStore;
  getStoreCode() async {
    APPGENERALDATASave = await _sqlHelper.getLastColumnAPPGENERALDATA();
    print("69 ... line");
    print(APPGENERALDATASave.isEmpty);
    print("71 ... line");
    if ( APPGENERALDATASave == [] || APPGENERALDATASave == null) {
      selectStore = APPGENERALDATASave['STORECODE'] ?? "";

      print(selectStore);
      print("store codes 74");
      setState(() {});
    }
  }

  getToken() async {
    setState(() {});
    print("init Api");
    prefs = await SharedPreferences.getInstance();
    print("camera status");
    print(await prefs?.getString("camera"));
    // disableCamera = await prefs?.getString("camera");

    var v = await prefs?.getString("camera");
    // disableCamera = v.toString() == "true" ? "true" : "false";

    await prefs?.getString("disableCamera");
    // disabledCamera = prefs?.getString("disableCamera") == "true" ? true : false;
    await prefs?.getString("enableUOMSelection");
    // disabledUOMSelection =
    // prefs?.getString("enableUOMSelection") == "true" ? true : false;
    await prefs?.getString("enableContinuousScan");
    // disabledContinuosScan =
    // prefs?.getString("enableContinuousScan") == "true" ? true : false;
    print("disables");
    print(await prefs?.getString("disableCamera"));
    print(await prefs?.getString("enableUOMSelection"));
    print(await prefs?.getString("enableContinuousScan"));
    print("disables app generals");
    // print(await _sqlHelper.getLastColumnAPPGENERALDATA());
    print("disables app generals");
    setState(() {});
    print(await prefs!.getString("baseUrl"));
    print(await prefs!.getString("pushStockTakeApi"));
    companyCode = await prefs!.getString("companyCode");
    baseUrlString = await prefs!.getString("baseUrl");
    accessUrl = await prefs!.getString("accessUrl");
    tenantId = await prefs!.getString("tenantId");
    clientId = await prefs!.getString("clientId");
    clientSecretId = await prefs!.getString("clientSecret");
    resource = await prefs!.getString("resource");
    grantType = await prefs!.getString("grantType");
    pullStockTakeApi = await prefs!.getString("pullStockTakeApi");
    pushStockTakeApi = await prefs!.getString("pushStockTakeApi");

    getDevice = await prefs!.getString("getDevice");
    getStore = await prefs!.getString("getStore");
    getDeactivate = await prefs!.getString("deactivate");
    updateDevice = await prefs!.getString("updateDevice");
    print("...169");
    print(updateDevice);

    print("update...");
    // if(baseUrlString=="null"|| baseUrlString == "" || baseUrlString ==null ||
    //     accessUrl == "null" || accessUrl ==""  || accessUrl ==null){
    //   Navigator.push(context,
    //       MaterialPageRoute(builder:(context)=>ProjectSettingsEnvironmentPage()));
    //   return;
    // }

    // APIConstants.getTokenUrl
    // var url = APIConstants.getTokenUrl +
    //     "?"
    //         "tenant_id=46f6488b-4363-4b2a-a0b3-4e889a754c02&"
    //         "client_id=6bfc7b07-0841-4076-b922-9998367d7ced&"
    //         "client_secret=Qxr7Q~TjBjm0fTKjZzniZyO_llYWrVOrdIYAA"
    //         "&resource=https://hsins28ce7a8bf606d8744bdevaos.axcloud.dynamics.com&"
    //         "grant_type=client_credentials";

    var url = "${accessUrl.toString()}/oauth2/token" +
        "?"
            "tenant_id=$tenantId&"
            "client_id=$clientId&"
            "client_secret=$clientSecretId"
            "&resource=$resource&"
            "grant_type=$grantType";

    print(url);

    try {
      var map = new Map<String, dynamic>();
      map['tenant_id'] = '$tenantId';
      map['client_id'] = '$clientId';
      map['client_secret'] = '$clientSecretId';
      map['resource'] = '$resource';
      map['grant_type'] = '$grantType';

      http.Response res = await http.post(
        Uri.parse(url),
        body: map,
      );
      print("res.body");
      print(res.body);
      print("res.body");

      var dt = json.decode(res.body);
      setState(() {
        token = dt['access_token'].toString();
      });

      // getStoreCode();
      // getDevices();
      // getTatmeenDetails();
      print(token);
    } catch (e) {}
  }

  getDevices() async {
    print("got it device");
    // print(selectDevice);
    // print(selectStore);
    print("got it device");
    // setState(() {
    List<dynamic> dt = await _sqlHelper.getGeneralSaveHomeData();
    for (var element in dt)
    {
      if (kDebugMode)
      {
        print(element);
      }
    }

    // return;
    homeList = [];
    // print(dt[0]['value']);
    // return;
    dt.asMap().containsKey(0) ?

    homeList.add({
      "icon": Icons.download,
      "type": dt[0]['type'],
      "value": dt[0]['value']
    }) :null;

    dt.asMap().containsKey(1) ?

    homeList.add({
      "icon": Icons.view_comfortable_rounded,
      "type": dt[1]['type'],
      "value": dt[1]['value']
    }) :null;

    dt.asMap().containsKey(2) ?

    homeList.add({
      "icon": Icons.list_alt,
      "type": dt[2]['type'],
      "value": dt[2]['value']
    }) :null;

    dt.asMap().containsKey(3) ?
    homeList.add({
      "icon": Icons.playlist_add_check_outlined,
      "type": dt[3]['type'],
      "value": dt[3]['value']
    }) :null;

    dt.asMap().containsKey(4) ?

    homeList.add({
      "icon": Icons.edit_note_outlined,
      "type": dt[4]['type'],
      "value": dt[4]['value']
    })
    :null;



    dt.asMap().containsKey(5) ?
    homeList.add({
      "icon": Icons.keyboard_return,
      "type": dt[5]['type'],
      "value": dt[5]['value']
    }) :null;


    dt.asMap().containsKey(6) ?

    homeList.add({
      "icon": Icons.shopping_cart_checkout,
      "type": dt[6]['type'],
      "value": dt[6]['value']
    }) :null;

    dt.asMap().containsKey(7) ?
    homeList.add({
      "icon": Icons.list_alt,
      "type": dt[7]['type'],
      "value": dt[7]['value']
    }) :null;

    dt.asMap().containsKey(8) ?
    homeList.add({
      "icon": Icons.list_alt,
      "type": dt[8]['type'],
      "value": dt[8]['value']
    }):null;

    dt.asMap().containsKey(9) ?
    homeList.add({
      "icon": Icons.list_alt,
      "type": dt[9]['type'],
      "value": dt[9]['value']
    }):null;

    dt.asMap().containsKey(10) ?
    homeList.add({
      "icon": Icons.list_alt,
      "type": dt[10]['type'],
      "value": dt[10]['value']
    }):null;

    dt.asMap().containsKey(11) ?
    homeList.add({
      "icon": Icons.list_alt,
      "type": dt[11]['type'],
      "value": dt[11]['value']
    }):null;

    dt.asMap().containsKey(12) ?
    homeList.add({
      "icon":  dt[12]['type'] == "History" ?
      Icons.history_outlined
          :
      Icons.list_alt,
      "type": dt[12]['type'],
      "value": dt[12]['value']
    }):null;


    dt.asMap().containsKey(13) ?
    homeList.add({
      "icon": Icons.history_outlined,
      "type": dt[13]['type'],
      "value": dt[13]['value']
    }):null;

    setState(() {
      // selectDevice = APPGENERALDATASave['DEVICEID'];
    });

    setState(() {
      // selectDevice = APPGENERALDATASave['DEVICEID'];
    });

    homeList.forEach((element) {
      print(element);
    });
  }

  int? listIndex;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          // backgroundColor:  Color(0xffd5aca9),

          appBar: PreferredSize(
            preferredSize: Size.fromHeight(45),
            child: AppBar(
              centerTitle: true,
              elevation: 0,
              leadingWidth: 0.0,
              iconTheme: IconThemeData(color: Colors.black),
              backgroundColor: Colors.red,
              automaticallyImplyLeading: false,
              actions: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            showDialog(
                              builder: (ctxt) {
                                return AlertDialog(
                                    title: Center(child: Text("Logout")),
                                    content: Container(
                                      height: 100,
                                      child: Column(children: [
                                        Text("Do you Really want to logout?"),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                style: APPConstants()
                                                    .btnBackgroundYes,
                                                child: Text(
                                                  "Yes",
                                                  style: APPConstants().YesText,
                                                ),
                                                onPressed: () async {
                                                  await prefs
                                                      ?.remove("username");
                                                  await prefs
                                                      ?.remove("password");
                                                  await prefs?.setString(
                                                      "isLogged",
                                                      await prefs
                                                              ?.getString(
                                                                  "isLogged")
                                                              .toString() ??
                                                          "");
                                                  setState(() {});
                                                  // await prefs?.setBool("isLogged", log!);
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              LoginPage()));
                                                },
                                              ),
                                              // Spacer(),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              TextButton(
                                                style: APPConstants()
                                                    .btnBackgroundNo,
                                                child: Text(
                                                  "No",
                                                  style: APPConstants().noText,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ])
                                      ]),
                                    ));
                              },
                              context: context,
                            );
                          },
                          icon: Icon(
                            Icons.arrow_circle_left_outlined,
                            color: Colors.white,
                            size: 30,
                          )),
                      Container(

                        child: Text(
                          "${username.toString()}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      ),
                      Spacer(),
                      Visibility(
                        visible: userType == "admin",
                        child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AppSettingsPage()))
                                  .whenComplete(() async {
                                getUserData();
                                getStoreCode();

                                getToken();

                                APPGENERALDATASave = await _sqlHelper
                                    .getLastColumnAPPGENERALDATA();
                                print(APPGENERALDATASave);

                                if (APPGENERALDATASave == [] ||
                                    APPGENERALDATASave == null) {
                                  selectStore =
                                      APPGENERALDATASave['STORECODE'] ?? "";
                                  print("store codes 72");
                                  print(selectStore);
                                  print("store codes 74");
                                  setState(() {});
                                }
                              });
                            },
                            icon: Icon(
                              Icons.settings,
                              color: Colors.white,
                            )
                        ),
                      ),
                    ],
                  ),
                )
                //   Stack(
                //
                //   fit: StackFit.expand,
                //   children: <Widget>[
                //     // Container(
                //     //   color: Colors.blue,
                //     // ),
                //     Center(
                //       child: Row(
                //
                //         children: [
                //           SizedBox(width: 10,),
                //           InkWell(
                //             onTap: () {
                //               print("logout");
                //               showDialog(
                //                 builder: (ctxt) {
                //                   return AlertDialog(
                //                       title: Center(child: Text("Logout")),
                //                       content: Container(
                //                         height: 100,
                //                         child: Column(
                //                             children: [
                //                               Text("Do you Really want to logout?"),
                //                               SizedBox(height: 30,),
                //                               Row(
                //                                   mainAxisAlignment: MainAxisAlignment.end,
                //                                   children: [
                //                                     RaisedButton(
                //                                       child: Text("Yes"),
                //                                       onPressed: ()async {
                //                                         await prefs?.remove("username");
                //                                         await prefs?.remove("password");
                //                                         Navigator.pop(context);
                //                                       },
                //                                     ),
                //                                     Spacer(),
                //                                     RaisedButton(
                //                                       child: Text("No"),
                //                                       onPressed: () {
                //                                         Navigator.pop(context);
                //                                       },
                //                                     ),
                //                                   ])
                //                             ]),
                //                       ));
                //
                //
                //                 }, context: context,
                //               );
                //             },
                //             child: Text("${username.toString()}",
                //               style: TextStyle(
                //                   color:  Colors.black
                //               ),),
                //           ),
                //           Spacer(),
                //           IconButton(
                //               onPressed: () {
                //                 Navigator.push(
                //                     context,
                //                     MaterialPageRoute(
                //                         builder: (context) => AppSettingsPage()))
                //                     .whenComplete(() async {
                //                   getUserData();
                //                   getStoreCode();
                //
                //                   getToken();
                //
                //                   APPGENERALDATASave = await _sqlHelper.getLastColumnAPPGENERALDATA();
                //                   print(APPGENERALDATASave);
                //
                //                   if(APPGENERALDATASave ==[] ||  APPGENERALDATASave == null){
                //                     selectStore = APPGENERALDATASave['STORECODE']??"";
                //                     print("store codes 72");
                //                     print(selectStore);
                //                     print("store codes 74");
                //                     setState((){
                //
                //                     });
                //                   }
                //                 });
                //               },
                //               icon: Icon(Icons.settings,color: Colors.black,))
                //         ],
                //       ),
                //     ),
                //
                //   ],
                // ),
              ],
            ),
          )
          // appBar:

          // PreferredSize(
          //
          //   preferredSize: Size.fromHeight(35),
          //   child:  AppBar(
          //     elevation: 0,
          //     backgroundColor:Colors.teal[50],
          //     automaticallyImplyLeading: false,
          //     centerTitle: true,
          //     // leading:
          //
          //     // Row(
          //     //   crossAxisAlignment: CrossAxisAlignment.center,
          //     //   mainAxisAlignment: MainAxisAlignment.center,
          //     //   children: [
          //     //     SizedBox(width: 15,),
          //     //     Wrap(
          //     //       children: [
          //     //         Center(
          //     //             child: Text("${username.toString()}",
          //     //             style: TextStyle(
          //     //               color:  Colors.black
          //     //             ),)),
          //     //       ],
          //     //     ),
          //     //   ],
          //     // ),
          //     title:  Container(
          //       color: Colors.redAccent,
          //       child: Row(
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           SizedBox(width: 10,),
          //           Wrap(
          //             children: [
          //               Center(
          //                   child: Text("${username.toString()}",
          //                     style: TextStyle(
          //                         color:  Colors.black
          //                     ),)),
          //             ],
          //           ),
          //           Spacer(),
          //           IconButton(
          //               onPressed: () {
          //                 Navigator.push(
          //                     context,
          //                     MaterialPageRoute(
          //                         builder: (context) => AppSettingsPage()))
          //                     .whenComplete(() async {
          //                   getUserData();
          //                   getStoreCode();
          //
          //                   getToken();
          //
          //                   APPGENERALDATASave = await _sqlHelper.getLastColumnAPPGENERALDATA();
          //                   print(APPGENERALDATASave);
          //
          //                   if(APPGENERALDATASave ==[] ||  APPGENERALDATASave == null){
          //                     selectStore = APPGENERALDATASave['STORECODE']??"";
          //                     print("store codes 72");
          //                     print(selectStore);
          //                     print("store codes 74");
          //                     setState((){
          //
          //                     });
          //                   }
          //                 });
          //               },
          //               icon: Icon(Icons.settings,color: Colors.black,))
          //         ],
          //       ),
          //     ),
          //
          //     // actions: [
          //     //
          //     //
          //     // ],
          //   ),
          // )

          ,
          body: Column(
            children: [
              Expanded(
                child:
                    //   StaggeredGridView.count(
                    //     crossAxisCount: 2,
                    //     mainAxisSpacing: 5,
                    //     crossAxisSpacing: 5,
                    //     children: List.generate(14, (index){
                    //       return Container(
                    //         child: Center(
                    //           child: Text("${index+1}"),
                    //         ),
                    //         color: Colors.blue,
                    //       );
                    //     }),
                    //     staggeredTiles: buildTiles(),
                    //   ),
                    // ),

                    Visibility(
                  visible:
                      APPGENERALDATASave != null && !APPGENERALDATASave.isEmpty,
                  child: GridView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 22),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: homeList.length == 4 ? 2 : 3,
                        // maxCrossAxisExtent: 200,
                        mainAxisExtent:
                        homeList .length ==4 ?
                            150
                            :
                        80,
                        childAspectRatio: 3 / 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      // const
                      // SliverGridDelegateWithMaxCrossAxisExtent(
                      //     maxCrossAxisExtent: 200,
                      //
                      //     childAspectRatio: 3 / 2,
                      //     crossAxisSpacing: 20,
                      //     mainAxisSpacing: 20,
                      //
                      // ),

                      itemCount: homeList.length,
                      // cacheExtent: 200,
                      itemBuilder: (BuildContext ctx, index) {
                        // setState((){
                        listIndex = index;
                        // });
                        return
                            TextButton(

                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shadowColor: Colors.brown,
                                ),
                                onPressed: () async {
                                  print(homeList[index]['type']);
                                  print(homeList[index]['value']);
                                  print("last 464");
                                  if (homeList[index]['type'] == "REFRESH" &&
                                      homeList[index]['value'] == "1") {
                                  showDialogMessage(context);

                                  }

                                  if (homeList[index]['type'] == "HISTORY" &&
                                      homeList[index]['value'] == "1") {
                                    print(homeList[index]['type']);
                                    print(homeList[index]['value'].runtimeType);
                                    // return;

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                HomeHistoryPage()));
                                  }

                                  if (homeList[index]['type'] == "VIEW ITEMS" &&
                                      homeList[index]['value'] == "1") {
                                    print(homeList[index]['type']);
                                    print(homeList[index]['value'].runtimeType);
                                    // return;

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ViewItemsOldPage(
                                                  isHomeView: true,
                                                )
                                            // MyApp(
                                            // )
                                            ));

                                    //
                                    // Navigator.push(
                                    //     context, MaterialPageRoute(builder: (context) =>
                                    //     ViewItemsPage(
                                    //     )));
                                  }

                                  if (homeList[index]['type'] ==
                                          "STOCK COUNT" &&
                                      homeList[index]['value'] == "1") {
                                    print(homeList[index]['type']);
                                    print(homeList[index]['value'].runtimeType);
                                    // return;

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TransactionViewPage(
                                                  pageType: homeList[index]
                                                      ['type'],
                                                )));

                                    //
                                    // Navigator.push(
                                    //     context, MaterialPageRoute(builder: (context) =>
                                    //     ViewItemsPage(
                                    //     )));

                                  }

                                  if (homeList[index]['type'] ==
                                          "PURCHASE ORDER" &&
                                      homeList[index]['value'] == "1") {
                                    print(homeList[index]['type']);
                                    print(homeList[index]['value'].runtimeType);
                                    // return;

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TransactionViewPage(
                                                  pageType: homeList[index]
                                                      ['type'],
                                                )));

                                    //
                                    // Navigator.push(
                                    //     context, MaterialPageRoute(builder: (context) =>
                                    //     ViewItemsPage(
                                    //     )));

                                  }

                                  if (homeList[index]['type'] ==
                                          "GOODS RECEIVE" &&
                                      homeList[index]['value'] == "1") {
                                    print(homeList[index]['type']);
                                    print(homeList[index]['value'].runtimeType);
                                    // return;

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TransactionViewPage(
                                                  pageType: homeList[index]
                                                      ['type'],
                                                )));

                                    //
                                    // Navigator.push(
                                    //     context, MaterialPageRoute(builder: (context) =>
                                    //     ViewItemsPage(
                                    //     )));

                                  }

                                  if (homeList[index]['type'] ==
                                          "RETURN ORDER" &&
                                      homeList[index]['value'] == "1") {
                                    print(homeList[index]['type']);
                                    print(homeList[index]['value'].runtimeType);
                                    // return;

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TransactionViewPage(
                                                  pageType: homeList[index]
                                                      ['type'],
                                                )));

                                    //
                                    // Navigator.push(
                                    //     context, MaterialPageRoute(builder: (context) =>
                                    //     ViewItemsPage(
                                    //     )));

                                  }


                                  if (homeList[index]['type'] ==
                                      "MOVEMENT JOURNAL" &&
                                      homeList[index]['value'] == "1")
                                  {
                                    print(homeList[index]['type']);
                                    print(homeList[index]['value'].runtimeType);
                                    // return;

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TransactionViewPage(
                                                  pageType: homeList[index]
                                                  ['type'],
                                                )));
                                  }

                                  if (homeList[index]['type'] ==
                                          "TRANSFER ORDER" &&
                                      homeList[index]['value'] == "1") {
                                    print(homeList[index]['type']);
                                    print(homeList[index]['value'].runtimeType);
                                    // return;

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TransactionViewPage(
                                                  pageType: homeList[index]
                                                      ['type'],
                                                )));

                                    //
                                    // Navigator.push(
                                    //     context, MaterialPageRoute(builder: (context) =>
                                    //     ViewItemsPage(
                                    //     )));

                                  }

                                  if (homeList[index]['type'] ==
                                          "TRANSFER IN" &&
                                      homeList[index]['value'] == "1") {
                                    print(homeList[index]['type']);
                                    print(homeList[index]['value'].runtimeType);
                                    // return;

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TransactionViewPage(
                                                  pageType: homeList[index]
                                                      ['type'],
                                                )));

                                    //
                                    // Navigator.push(
                                    //     context, MaterialPageRoute(builder: (context) =>
                                    //     ViewItemsPage(
                                    //     )));

                                  }

                                  if (homeList[index]['type'] ==
                                          "TRANSFER OUT" &&
                                      homeList[index]['value'] == "1") {
                                    print(homeList[index]['type']);
                                    print(homeList[index]['value'].runtimeType);
                                    // return;

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TransactionViewPage(
                                                  pageType: homeList[index]
                                                      ['type'],
                                                )));

                                    //
                                    // Navigator.push(
                                    //     context, MaterialPageRoute(builder: (context) =>
                                    //     ViewItemsPage(
                                    //     )));

                                  }

                                  if (homeList[index]['type'] ==
                                          "RETURN PICK" &&
                                      homeList[index]['value'] == "1") {
                                    print(homeList[index]['type']);
                                    print(homeList[index]['value'].runtimeType);
                                    // return;

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TransactionViewPage(
                                                  pageType: homeList[index]
                                                      ['type'],
                                                )));

                                    //
                                    // Navigator.push(
                                    //     context, MaterialPageRoute(builder: (context) =>
                                    //     ViewItemsPage(
                                    //     )));

                                  }

                                  if (homeList[index]['type'] ==
                                          "GOODS RECEIVE" &&
                                      homeList[index]['value'] == "1") {
                                    print(homeList[index]['type']);
                                    print(homeList[index]['value'].runtimeType);
                                    // return;

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TransactionViewPage(
                                                  pageType: homeList[index]
                                                      ['type'],
                                                )));

                                    //
                                    // Navigator.push(
                                    //     context, MaterialPageRoute(builder: (context) =>
                                    //     ViewItemsPage(
                                    //     )));

                                  }
                                  print(homeList[index]['value'] == 1);
                                  print(
                                      homeList[index]['type'] == "IMPORT DATA");
                                  if (homeList[index]['type'] ==
                                      "IMPORT DATA") {
                                    // if(homeList[index]['type'] != "STOCK COUNT" ){
                                    //   print(homeList[index]['type']);
                                    //   print(homeList[index]['value']);
                                    //
                                    //
                                    // }

                                    List<dynamic> dt = [];
                                    var body = {
                                      "STOCK COUNT": "Stock Count",
                                      "GOODS RECEIVE": "Open POs",
                                      "TRANSFER IN": "Transfer In",
                                      "TRANSFER OUT": "Transfer Out",
                                    };
                                    for (var i = 0; i < homeList.length; i++) {
                                      if (homeList[i]['type']
                                          .contains("STOCK COUNT")) {
                                        dt.add("Stock Count");
                                      }
                                      if (homeList[i]['type']
                                          .contains("GOODS RECEIVE")) {
                                        dt.add("Open POs");
                                      }

                                      if (homeList[i]['type']
                                          .contains("TRANSFER IN")) {
                                        dt.add("Transfer In");
                                      }
                                      if (homeList[i]['type']
                                          .contains("TRANSFER OUT")) {
                                        dt.add("Transfer Out");
                                      }
                                    }

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ImportDataPage(
                                                  transactionTypes: dt,
                                                )));
                                  }

                                  if (homeList[index]['type'] ==
                                          "PRICE CHECK" &&
                                      homeList[index]['value'] == "1") {
                                    print(homeList[index]['type']);
                                    print(homeList[index]['value'].runtimeType);
                                    // return;

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PriceCheckPage()));

                                    //
                                    // Navigator.push(
                                    //     context, MaterialPageRoute(builder: (context) =>
                                    //     ViewItemsPage(
                                    //     )));

                                  }

                                  if (homeList[index]['type'] == "ON HAND" &&
                                      homeList[index]['value'] == "1") {
                                    print(homeList[index]['type']);
                                    print(homeList[index]['value'].runtimeType);
                                    // return;

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                OnHandPage()));
                                  }

                                  // print(homeList[index]['type']);
                                  print(homeList[index]['value'].runtimeType);
                                },
                                child: Container(
                                  width: homeList[index] ==
                                          homeList[homeList.length - 1]
                                      ? MediaQuery.of(context).size.width * 0.8
                                      : MediaQuery.of(context).size.width,

                                  decoration: BoxDecoration(
                                      // gradient: LinearGradient(colors: [Colors.yellow,
                                      //   Colors.blue, Colors.red]),

                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black,
                                            blurRadius: 2.5,
                                            // offset: Offset(2, 100),
                                            blurStyle: BlurStyle.normal)
                                      ],
                                      borderRadius: BorderRadius.circular(15.0),
                                      color: Colors.grey[100],
                                      border: Border.all(
                                          width: 0.1, color: Colors.black)),
                                  // margin: EdgeInsets.symmetric(horizontal: 10),

                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Icon(
                                                homeList[index]['type'] ==
                                                        "REFRESH"
                                                    ? Icons.refresh_rounded
                                                    : homeList[index]['icon'],
                                                color: Colors.red,
                                                size:

                                                homeList .length ==4 ?
                                                60 :
                                                30,
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                homeList[index]['type'] ==
                                                        "GOODS RECEIVE"
                                                    ? "GRN"
                                                    : homeList[index]['type']
                                                        .toString(),
                                                overflow: TextOverflow.visible,
                                                textAlign: TextAlign.center,
                                                style:
                                                TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontSize:
                                                    homeList .length ==4 ?
                                                    15 :
                                                    10),

                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                      }),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListItem {
  String? type;
  bool? value;
  IconData? icon;
  ListItem({
    this.type,
    this.value,
    this.icon,
  });

  ListItem.fromJson(Map<String, dynamic> json) {
    icon = json['icon'];
    type = json['type'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['icon'] = this.icon;
    data['type'] = this.type;
    data['value'] = this.value;
    return data;
  }
}
