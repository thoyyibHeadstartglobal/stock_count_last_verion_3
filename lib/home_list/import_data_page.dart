import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dynamicconnectapp/helper/local_db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../constants/constant.dart';
import '../common_pages/home_page.dart';


class ImportDataPage extends StatefulWidget {
  ImportDataPage({this.transactionTypes});
  final dynamic transactionTypes;
  @override
  State<ImportDataPage> createState() => _ImportDataPageState();
}

class _ImportDataPageState extends State<ImportDataPage> {
  String? selectTransType;
  int? lastRecId = 0;
  TextEditingController transactionNumberController =
      new TextEditingController();
  List<dynamic> transactionTypes = [];

  var APPGENERALDATASave;
  SQLHelper _sqlHelper = SQLHelper();
  bool? isShowDialog = false;


  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;





// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {


    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {


      print("'Couldn\'t check connectivity status', error: ${e.toString()}");
      // developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    print(result);
    setState(() {
      _connectionStatus = result;
    });
  }



  @override
  void initState() {

    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    getStoreCode();
    getToken();
    super.initState();
  }

  SharedPreferences? prefs;
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
  String? username;
  var token;
  getToken() async {
    setState(() {});
    print("init Api");
    prefs = await SharedPreferences.getInstance();
    print("camera status");
    print(await prefs?.getString("camera"));
    disableCamera = await prefs?.getString("camera");
    username = await prefs?.getString("username");
    var v = await prefs?.getString("camera");
    disableCamera = v.toString() == "true" ? "true" : "false";

    await prefs?.getString("disableCamera");
    // disabledCamera

    disableCamera =await (prefs?.getString("disableCamera") == "true" ? "true" : "false");
    await prefs?.getString("enableUOMSelection");
    // disabledUOMSelection =
    // prefs?.getString("enableUOMSelection") == "true" ? true : false;
    await prefs?.getString("enableContinuousScan");
    // disabledContinuosScan =
    // prefs?.getString("enableContinuousScan") == "true" ? true : false;
    print("disables line 129 ");
    print(await prefs?.getString("disableCamera"));
    print(await prefs?.getString("enableUOMSelection"));
    print(await prefs?.getString("enableContinuousScan"));
    print("disables app generals line 133");
    print(await _sqlHelper.getLastColumnAPPGENERALDATA());
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

    var url = "${accessUrl.toString()}/oauth2/token" +
        "?"
            "tenant_id=$tenantId&"
            "client_id=$clientId&"
            "client_secret=$clientSecretId"
            "&resource=$resource&"
            "grant_type=$grantType";

    print(url);

    try {
      var map =  Map<String, dynamic>();
      map['tenant_id'] = '$tenantId';
      map['client_id'] = '$clientId';
      map['client_secret'] = '$clientSecretId';
      map['resource'] = '$resource';
      map['grant_type'] = '$grantType';

      http.Response res = await http.post(
        Uri.parse(url),
        body: map,
      );
      print("res.body line 191");
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

  var selectStore;
  getStoreCode() async {
    transactionTypes.add("Item Master");
    transactionTypes.addAll(widget.transactionTypes);

    print("Transcation Types ");
    transactionTypes.forEach((element) {
      print(element);
    });
    setState(() {});
    APPGENERALDATASave = await _sqlHelper.getLastColumnAPPGENERALDATA();
    // print(APPGENERALDATASave);
    if (APPGENERALDATASave == [] || APPGENERALDATASave == null) {
      selectStore = APPGENERALDATASave['STORECODE'] ?? "";

      setState(() {});
    }
  }

  showLoaderDialog(BuildContext context)
  {
    AlertDialog alert;

    alert= AlertDialog(
      elevation: 0.0,
      backgroundColor: Colors.white,
      content: Container(
        alignment: Alignment.center,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Container(child: Text("Downloading Data...")),
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

  showDialogGotData(String text) {
    // set up the button
    Widget yesButton = TextButton(
      style: APPConstants().btnBackgroundYes,
      child: Text("Ok",
        style: APPConstants().YesText,),
      onPressed: () {
        // saveSettings();
        setState(() {});
        Navigator.pop(context);
      },
    );
    //
    //
    //
    // Widget noButton = TextButton(
    //   child: Text("No"),
    //   onPressed: () {
    //     print("Scanning code");
    //     setState(() {
    //
    //     });
    //     Navigator.pop(context);
    //   },
    // );

    // set up the AlertDialog
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

  pullDataUser(context) {
    // print(onpress);
    // return;
    showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("DynamicsConnect"),
            content: Text("Are You Sure to Pull Data From Dynamics ?"),
            actions: <Widget>[
              TextButton(
               style: APPConstants().btnBackgroundNo,
                child: Text(
                  "No",
                  style:  APPConstants().noText,
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

                  if (selectTransType == "Stock Count")
                  {
                    transType = 1;
                    setState(() {});
                  }


                  if (selectTransType == "Item Master")
                    {
                      transType = 2;
                      setState(() {});
                    }

                  if (selectTransType == "Open POs") {
                    transType = 3;

                    setState(() {});
                  }

                  // if (selectTransType == "Return Order") {
                  //   transType = 4;
                  //   setState(() {});
                  // }

                  if (selectTransType == "Transfer Out") {
                    transType = 5;
                    setState(() {});
                  }

                  if (selectTransType == "Transfer In") {
                    transType = 6;
                    setState(() {});
                  }

                  if (transType == 2) {
                    await _sqlHelper.deleteItemMaster();
                  } else {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    importedList.clear();

                  }

                  // return;
                  if (transType == 1) {
                    importedList.clear();
                    showDialogStockCount("Pull items from D365");
                    setState(() {});
                  }
                  else
                  {

                    await _sqlHelper
                        .deleteStockCount(transactionNumberController.text.trim());
                    showLoaderDialog(context);
                    pullData(
                      itemsCount: 0 ,
                      transType:transType
                    );
                    // pullApiData();
                    setState(() {});
                  }

                  // Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  showDialogStockCount(String text) {
    // set up the button
    Widget yesButton = TextButton(
      child: Text("FROM JOURNAL : ${transactionNumberController.text}"),
      onPressed: () async {
        importedList.clear();
        await _sqlHelper
            .deleteStockCount(transactionNumberController.text.trim());
        Navigator.pop(context);
        showLoaderDialog(context);
        pullData(itemsCount: "JOURNAL",transType: transType);
        // pullApiData(itemsCount: "JOURNAL");
        setState(() {});
        // Navigator.pop(context);
      },
    );
    //
    //
    //
    Widget noButton = TextButton(
      child: Text("ALL ITEMS"),
      onPressed: () async {
        importedList.clear();
        await _sqlHelper
            .deleteStockCount(transactionNumberController.text.trim());
        Navigator.pop(context);
        showLoaderDialog(context);
        pullData(itemsCount: "FULL",transType: transType);
        // pullApiData(itemsCount: "FULL");
        setState(() {});

        // Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("DynamicsConnect"),
      content: Text(
        "$text",
      ),
      actions: [noButton, yesButton],
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

  var items;
  List<dynamic> importedList = [];

  pullData({transType,itemsCount}) async {


    if(_connectionStatus == ConnectivityResult.none){
      showDialogGotData("No internet Connection");
      return;
    }
    print("$pullStockTakeApi");
    // return;
    var tk = 'Bearer ${token.toString()}';
    Map<String, String> headers = {
      "Content-type": "application/json",
      'Authorization': tk
    };

    var body;
    if (itemsCount == "FULL") {
      setState(() {
        items = 0;
      });
    }
    if (itemsCount == "JOURNAL") {
      setState(() {
        items = 1;
      });
    }


    body = {
      "transType": transType, // 1- Counting                 2- Item master
      //     3- Open Purchase order lines 4- Invoiced Purchase lines
      "transactionId": transType == 2 ? "":
      transactionNumberController.text, // Counting journal number , empty string for Item master , Purchase order number
      "items":transType == 1 ? items:
      0, // all items STOCK COUNT  : items =0 , from journal items=1
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
      var res;
    var responseJson;

      try{
        res= await http.post(headers: headers, Uri.parse(ur), body: js);
        responseJson = json.decode(res.body);
        setState((){

        });
      }
      catch(e){

        Navigator.pop(context);
       await showDialogGotData("Network Issue :${e.toString()}");
        return;
      }


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
    if (transType == 2) {

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

    }

    else{
      listDt.forEach((element) {
        print(element);
        _sqlHelper.addIMPORTDETAILSToPullData(
            AXDOCNO: element['AXDOCNO'],
            STORECODE: APPGENERALDATASave['STORECODE'],
            BARCODE: element['ITEMBARCODE'],
            TRANSTYPE: element['TRANSTYPE'],
            ITEMID: element['ItemId'],
            ITEMNAME: element['ItemName'],
            UOM: element['UNIT'],
            QTY: element['QTY'],
            DEVICEID: APPGENERALDATASave['DEVICEID'],
            CONFIGID: element['CONFIGID'],
            SIZEID: element['SIZEID'],
            COLORID: element['COLORID'],
            STYLESID: element['STYLEID'],
            INVENTSTATUS: element['INVENTSTATUS'],
            BATCHENABLED: element['BatchEnabled'],
            BATCHEDITEM: element['BatchedItem']

        );
      });
    }


      setState(() {});

      print("recID is : ${lastRecId.toString()}");
      print(
          "import Data length : ${responseJson[0]['Importdata'].isEmpty.toString()}");

      if (lastRecId == 0) {
        print("This is Last Record ");

        if (transType == 2) {
          print("This is item master");
          // List<dynamic> uniquesList =  importedList.toSet().toList();

          await _sqlHelper.addMASTERTOFEATURES();
          Navigator.pop(context);
        }
        else
        {

          setState(() {});
          print(listDt.length);


          print("recID is : ${lastRecId.toString()}");
          print(
              "import Data length : ${responseJson[0]['Importdata'].isEmpty.toString()}");


            print("This is Last Record FROM  ");

              // List<dynamic> uniquesList =  importedList.toSet().toList();
              final now = DateTime.now();
              String dateFormatted = DateFormat('yyyy-MM-dd').format(now);
              await _sqlHelper.addIMPORTHEADERToPullData(
                  AXDOCNO: listDt[0]['AXDOCNO'],
                  STORECODE: APPGENERALDATASave['STORECODE'],
                  TRANSTYPE: listDt[0]['TRANSTYPE'],
                  STATUS: 0,
                  USERNAME: username,
                  DESCRIPTION: "",
                  CREATEDDATE: now.toString(),
                  DATAAREAID: companyCode,
                  DEVICEID: APPGENERALDATASave['DEVICEID']);
              Navigator.pop(context);

        }




        WidgetsBinding.instance.addPostFrameCallback((_) async {

          await showDialogGotDataWithOperation(
              op: () {
                Navigator.pop(context);
              },
              text:
                  "${importedList.length.toString()} Barcodes has been downloaded");
        });



        await _sqlHelper.addIMPORTEDDETAILSTOFEATURES();
        return;
      }

      pullData(
         transType: transType
      );
  }

  var transType;
  var transId;

  pullApiData({itemsCount}) async {
    print("$pullStockTakeApi");
    // return;
    var tk = 'Bearer ${token.toString()}';
    Map<String, String> headers = {
      "Content-type": "application/json",
      'Authorization': tk
    };
    // var body = {"dataAreaId": "$companyCode"};
    print(selectTransType);
    // selectTransType == "Item Master" ? ""
    //     :transactionNumberController.text.toString(),
    var body;

    var transId;
    if (selectTransType == "Open POs") {
      transType = 3;
      transId = transactionNumberController.text;
    }

    if (selectTransType == "Item Master") {
      transType = 2;
      transId = "";

      body = {
        "transType": transType, // 1- Counting                 2- Item master
        //     3- Open Purchase order lines 4- Invoiced Purchase lines
        "transactionId":
            transId, // Counting journal number , empty string for Item master , Purchase order number
        "items": 0, //all items STOCK COUNT  : items =0 , from journal items=1
        "topCount": 1000,
        "lastRecid": lastRecId,
        "dataAreaId": "$companyCode",
        "storeCode": APPGENERALDATASave['STORECODE']
      };
      // var ur = APIConstants.baseUrl + "pushTransactionTatmeen";
      var ur = "$pullStockTakeApi";
      print(ur);
      var js = json.encode(body);
      var res = await http.post(headers: headers, Uri.parse(ur), body: js);
      var responseJson = json.decode(res.body);
      print(responseJson);

      importedList.addAll(responseJson[0]['Importdata']);
      List<dynamic> listDt = [];

      lastRecId = responseJson[0]['LastRecId'];
      if (responseJson[0]['Importdata'] == null ||
          responseJson[0]['Importdata'].length == 0) {
        Navigator.pop(context);
        showDialogGotData("Item Master is Empty");
        return;
      }
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

        if (selectTransType == "Item Master") {
          print("This is item master");
          // List<dynamic> uniquesList =  importedList.toSet().toList();

          await _sqlHelper.addMASTERTOFEATURES();
          Navigator.pop(context);
        }

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

      pullApiData();
    }

    if (selectTransType == "Stock Count") {
      if (itemsCount == "FULL") {
        setState(() {
          items = 0;
        });
      }
      if (itemsCount == "JOURNAL") {
        setState(() {
          items = 1;
        });
      }
      transType = 1;
      transId = transactionNumberController.text;
      body = {
        "transType": transType, // 1- Counting                 2- Item master
        //     3- Open Purchase order lines 4- Invoiced Purchase lines
        "transactionId":
            transId, // Counting journal number , empty string for Item master , Purchase order number
        "items":
            items, //all items STOCK COUNT  : items =0 , from journal items=1
        "topCount": 1000,
        "lastRecid": lastRecId,
        "dataAreaId": "$companyCode",
        "storeCode": APPGENERALDATASave['STORECODE']
      };

      print(body);
      // var ur = APIConstants.baseUrl + "pushTransactionTatmeen";
      var ur = "$pullStockTakeApi";
      print(ur);
      var js = json.encode(body);
      var res = await http.post(headers: headers, Uri.parse(ur), body: js);
      var responseJson = json.decode(res.body);
      print(responseJson);

      importedList.addAll(responseJson[0]['Importdata']);
      List<dynamic> listDt = [];

      lastRecId = responseJson[0]['LastRecId'];
      if (responseJson[0]['Importdata'] == null ||
          responseJson[0]['Importdata'].length == 0) {
        Navigator.pop(context);
        showDialogGotData("Stock Count is Empty");
        return;
      }
      listDt.addAll(responseJson[0]['Importdata'] ?? []);
      setState(() {});
      print(listDt.length);
      listDt.forEach((element) {
        print(element);
        _sqlHelper.addIMPORTDETAILSToPullData(
            AXDOCNO: element['AXDOCNO'],
            STORECODE: APPGENERALDATASave['STORECODE'],
            BARCODE: element['ITEMBARCODE'],
            TRANSTYPE: element['TRANSTYPE'],
            ITEMID: element['ItemId'],
            ITEMNAME: element['ItemName'],
            UOM: element['UNIT'],
            QTY: element['QTY'],
            DEVICEID: APPGENERALDATASave['DEVICEID'],
            CONFIGID: element['CONFIGID'],
            SIZEID: element['SIZEID'],
            COLORID: element['COLORID'],
            STYLESID: element['STYLEID'],
            INVENTSTATUS: element['INVENTSTATUS']);
      });

      print("recID is : ${lastRecId.toString()}");
      print(
          "import Data length : ${responseJson[0]['Importdata'].isEmpty.toString()}");

      if (lastRecId == 0) {
        print("This is Last Record FROM  ");

        if (selectTransType == "Stock Count") {
          print("This is item master");
          // List<dynamic> uniquesList =  importedList.toSet().toList();
          final now = DateTime.now();
          String dateFormatted = DateFormat('yyyy-MM-dd').format(now);
          await _sqlHelper.addIMPORTHEADERToPullData(
              AXDOCNO: listDt[0]['AXDOCNO'],
              STORECODE: APPGENERALDATASave['STORECODE'],
              TRANSTYPE: listDt[0]['TRANSTYPE'],
              STATUS: 0,
              USERNAME: username,
              DESCRIPTION: "",
              CREATEDDATE: now.toString(),
              DATAAREAID: companyCode,
              DEVICEID: APPGENERALDATASave['DEVICEID']);

          Navigator.pop(context);
        }
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

      pullApiData(itemsCount: items);
    } else {
      body = {
        "transType": transType, // 1- Counting                 2- Item master
        //     3- Open Purchase order lines 4- Invoiced Purchase lines
        "transactionId":
            transId, // Counting journal number , empty string for Item master , Purchase order number
        "items": 0, //all items STOCK COUNT  : items =0 , from journal items=1
        "topCount": 1000,
        "lastRecid": lastRecId,
        "dataAreaId": "$companyCode",
        "storeCode": APPGENERALDATASave['STORECODE']
      };
    }

    // var transType = selectTransType == "Item Master" ? 2;

    // print(importedList.length);
    // return d;
    //
  }

  showDialogGotDataWithOperation({String? text, dynamic op}) {
    // set up the button
    Widget scanButton = TextButton(
      style: APPConstants().btnBackgroundYes,
      child: Text("Ok",
        style: APPConstants().YesText,),
      onPressed: () {
        print("Scanning code");
        setState(() {});
        Navigator.pop(context);
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

  final _formKey = GlobalKey<FormState>();


  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  bool ? isBatchEnabled=false;
  bool ? BatchedItem=false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }
  Barcode? result;

  Future<void> _onQRViewCreated(QRViewController controller) async {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData)  {

      setState(()  {
        result = scanData;
        print("scan result : 953");





        transactionNumberController.text = result!.code.toString();


        print("scan result : 980");
        // companyCodeController.text= "utc";
        // accessUrlController.text = lst[0].trim().toString();
        // tenantIdController.text = lst[1].trim().toString();
        // clientIdController.text = lst[2].trim().toString();
        // clientSecretController.text = lst[3].trim().toString();
        // resourceController.text = lst[4].trim().toString();
        // grantTypeController.text = lst[5].trim().toString();
        // pullStockTakeApiController.text = "${lst[6].trim().toString()}${lst[7].trim().toString()}";
        // baseUrl =lst[6].trim().toString();
        // pushStockAPiController.text = "${lst[6].trim().toString()}${lst[8].trim().toString()}";

      });


      // getBarcodeWithscan();
      controller.pauseCamera();

      // controller.resumeCamera();
    });

    // await controller.resumeCamera();
    // await controller?.toggleFlash();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
              'no Permission',
              textAlign: TextAlign.center,
            )),
      );
    }
  }


  Widget _buildQrView(BuildContext context, bool isPortail) {
    controller?.resumeCamera();
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea;
    if (isPortail) {
      scanArea = (MediaQuery.of(context).size.width < 400 ||
          MediaQuery.of(context).size.height < 400)
          ? 400.0
          : 800.0;
    } else {
      scanArea = (MediaQuery.of(context).size.width < 400 ||
          MediaQuery.of(context).size.height < 400)
          ? 800.0
          : 1000.0;
    }

    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          overlayColor: Colors.white,
          borderColor: Colors.blue,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 7,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        // elevation: 0,
        backgroundColor: Colors.red,
        // backgroundColor:  Color(0xfff4e7e6),
        // automaticallyImplyLeading: ,
        centerTitle: true,
        elevation: 0.3,
        title: Text("Pull Data From Dynamics",

        style: TextStyle(
            color: Colors.white
        ),),
      ),
      body: ListView(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 35,
                ),

                Visibility(
                    visible: disableCamera == null ||
                        disableCamera == "false",
                    child: SizedBox(
                      height: 10,
                    )),
                Visibility(
                  visible: disableCamera == null || disableCamera == "false",
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // IgnorePointer(
                        // ignoring: !_focusNodeDocumentNo.hasFocus &&
                        //         documentnoController.text == ""
                        //     ? true
                        //     : false,
                        // ignoring: true,
                        // child:
                        GestureDetector(
                          onTap: () async {
                            await controller?.resumeCamera();
                            await controller?.toggleFlash();
                          },
                          child: Container(
                              height: 150,
                              child: _buildQrView(
                                  context,
                                  MediaQuery.of(context).orientation ==
                                      Orientation.portrait
                                      ? true
                                      : false)),
                        ),
                        // ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(15.0)),
                          margin: EdgeInsets.symmetric(horizontal: 3),
                          height: 30,
                          child: Center(
                            child: Text(
                              "Place the blue line over the QR code",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                    visible: disableCamera == null || disableCamera == "false",
                    child: SizedBox(
                      height: 10,
                    )),

                Container(
                  height: 35,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration:  BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.black38,
                        width: 0.2
                    ),
                    color: Colors.white,
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2(
                        dropdownMaxHeight: 400,
                        barrierDismissible: true,
                        // disabledHint: false,
                        buttonHeight: 500,
                        isExpanded: true,
                        hint: Row(
                          children: const [
                            Expanded(
                              child: Text(
                                'Transaction Type',
                                style: TextStyle(
                                  // fontSize: 14,
                                  // fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        items: transactionTypes
                            .map((item) => DropdownMenuItem<String>(
                                  value: item.toString(),
                                  child: Text(
                                    item.toString(),
                                    style: const TextStyle(
                                      // fontSize: 14,
                                      // fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        value: selectTransType,
                        onChanged: (value) {
                          setState(() {
                            selectTransType = value as String;
                          });
                        },
                        icon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 13.0),
                          child: const Icon(
                            Icons.arrow_forward_ios_outlined,
                          ),
                        ),
                        iconSize: 14,

                        buttonDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.black38,
                            width: 0.5
                          ),
                          color: Colors.white,
                        ),

                        buttonElevation: 0,

                        dropdownDecoration: BoxDecoration(
                          border: Border.all(
                            // style: BorderStyle.none,
                            width: 0.5,
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          // color: Colors.white,
                        ),
                        dropdownElevation: 0,
                        scrollbarRadius: const Radius.circular(40),
                        scrollbarThickness: 6,

                        scrollbarAlwaysShow: true,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Visibility(
                  visible: selectTransType != "Item Master",
                  child: IgnorePointer(
                    ignoring: selectTransType == "Item Master",
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        validator: (value) =>
                            value!.isEmpty ? 'Required *' : null,
                        controller: transactionNumberController,
                        decoration: InputDecoration(
                            focusedBorder:APPConstants().focusInputBorder ,
                            enabledBorder: APPConstants().enableInputBorder,
                            isDense: true,
                            contentPadding: EdgeInsets.only(
                                left: 15, right: 15, top: 8, bottom: 8),
                            hintText: "Transaction No",
                            hintStyle: TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              // borderSide: Border()
                            )),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  // margin: EdgeInsets.symmetric(horizontal: 10),
                  height: 35,
                  width: MediaQuery.of(context).size.width * 0.94,
                  child: Row(
                    children: [
                      Expanded(
                        flex:5,
                        child: TextButton(

                            style:
                                TextButton.styleFrom(backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                  padding: EdgeInsets.zero
                                ),
                            onPressed: () async {
                              if(_connectionStatus == ConnectivityResult.none){
                                showDialogGotData("No internet Connection");
                                return;
                              }
                              if (selectTransType == "" || selectTransType == null) {
                                showDialogGotData("Select Transaction Type");
                                return;
                              }
                              if (selectTransType == "Item Master" &&
                                  transactionNumberController.text.trim() == "") {
                                pullDataUser(context);
                                return;
                              } else {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                pullDataUser(context);
                              }

                              if (selectTransType != "" &&
                                  transactionNumberController.text.trim() == "") {}
                            },
                            child: Text(
                              "PULL DATA",
                              style: TextStyle(color: Colors.white),
                            )),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          color: Colors.red,
                            onPressed: (){
                              if(_connectionStatus == ConnectivityResult.none){
                                showDialogGotData("No internet Connection");
                                return;
                              }
                              if (selectTransType == "" || selectTransType == null) {
                                showDialogGotData("Select Transaction Type");
                                return;
                              }
                              if (selectTransType == "Item Master" &&
                                  transactionNumberController.text.trim() == "") {
                                pullDataUser(context);
                                return;
                              } else {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                pullDataUser(context);
                              }

                              if (selectTransType != "" &&
                                  transactionNumberController.text.trim() == "") {}
                        }, icon: Icon(Icons.get_app_outlined,
                        color: Colors.white70,)),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 35,
                            child: TextButton(
                                style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0)),
                                    backgroundColor: Colors.orangeAccent),
                                onPressed: () async {
                                  // FocusScope.of(context).unfocus();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LandingHomePage()));
                                },
                                child: Text(
                                  "HOME",
                                  style: TextStyle(color: Colors.white),
                                )),
                          )),
                    ],
                  ),
                ),
                // Container(
                //   margin: EdgeInsets.symmetric(horizontal: 10),
                //   height: 35,
                //   width: MediaQuery.of(context).size.width,
                //   child: TextButton(
                //       style: TextButton.styleFrom(backgroundColor: Colors.red),
                //       onPressed: () {},
                //       child: Text(
                //         "HOME",
                //         style: TextStyle(color: Colors.white),
                //       )),
                // )
              ],
            ),
          )
        ],
      ),
    );
  }
}
