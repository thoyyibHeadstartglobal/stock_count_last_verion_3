import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dynamicconnectapp/helper/local_db.dart';
import 'package:dynamicconnectapp/home_list/search_imported_details.dart';
import 'package:dynamicconnectapp/home_list/view_items_item_masters_page.dart';
import 'package:dynamicconnectapp/home_list/view_item_masters_page.dart';
import 'package:dynamicconnectapp/common_pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constant.dart';

class OnHandPage extends StatefulWidget {
  OnHandPage({this.itemDetails, this.isItemMasters});

  // PriceCheckPage({this.type,this.isImportedSearch,this.transDetails});
  final bool? isItemMasters;
  final dynamic itemDetails;
  // final dynamic type;
  @override
  State<OnHandPage> createState() => _OnHandPageState();
}

class _OnHandPageState extends State<OnHandPage> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
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

  SQLHelper _sqlHelper = SQLHelper();
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
  String? disabledUOMSelection;
  String? disabledContinuosScan;
  var token;
  Barcode? result;
  int? lastRecId = 0;
  List<dynamic> onHandList = [];
  int indexSelected = -1;
  TextEditingController barcodeController = TextEditingController();
  TextEditingController itemIdController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController uomController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController configController = TextEditingController();
  TextEditingController styleController = TextEditingController();
  TextEditingController activePriceController = TextEditingController();
  final _focusNodeBarcode = FocusNode();

  final _focusNodeQty = FocusNode();
  Widget _buildQrView(BuildContext context, bool isPortail) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    double scanArea;
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

  var baseUrl;
  dynamic barcodeScanData;

  getPrice({barcode}) async {
    if (_connectionStatus == ConnectivityResult.none) {
      showDialogGotData("No Internet Connection ");
      return;
    }
    print("price check");
    var tk = 'Bearer ${token.toString()}';
    Map<String, String> headers = {
      "Content-type": "application/json",
      'Authorization': tk
    };

    var body = {
      "transType": 7, // 1- Counting                 2- Item master   ,
      //  3 - Open Purchase order lines
      // 4- Invoiced Purchase lines
      "transactionId": barcode != null
          ? barcode
          : barcodeController
              .text, // Counting journal number , empty string for Item master , Purchase order number
      "items": 0, //all items STOCK COUNT  : items =0 , from journal items=1
      "topCount": 1000,
      "lastRecid": 0,
      "dataAreaId": "$companyCode",
      "storeCode": "%"
    };

    // var ur = APIConstants.baseUrl + "pushTransactionTatmeen";
    var ur = "$pullStockTakeApi";
    await showLoaderDialog(context);
    print(ur);
    var js = json.encode(body);
    var res;
    try {
      res = await http.post(headers: headers, Uri.parse(ur), body: js);
      setState(() {});


      // showDialogGotData("Wait for connection");
      // return;

    } catch (e) {
      Navigator.pop(context);
      showDialogGotData("Connection Error : ${e.toString()}");

      // return;
    }

    var responseJson = json.decode(res.body);
    setState(() {});

    print(responseJson);

    if (res.statusCode == 200 || res.statusCode == 201) {
      var responseJson = json.decode(res.body);
      setState((){
      });

      if(responseJson[0]['Success'] == false){

        Navigator.pop(context);
        barcodeController.clear();
        showDialogGotData("${responseJson[0]['Message']}");
        return;
      }

      // Importdata: [{$id: 2, AXDOCNO: , OrderAccount: , OrderAccountName: , FROMSTORECODE: ,
      //   TOSTORECODE: , ItemId: 33300003, ItemName: 21ST CENT FOLICACID TAB 100S,
      //   ITEMBARCODE: 33300003A0045257, DATAAREAID: 1000, WAREHOUSE: , CONFIGID: , COLORID: ,
      //   SIZEID: , STYLEID: , INVENTSTATUS: , QTY: 0.0, UNIT: PACK, TRANSTYPE: 8, ItemAmount: 29.0, GTIN: ,
      //   GTINUnit: , GTINOrderQTY: 0.0, GTINReceiveQTY: 0.0, HeaderOnly: 0, Description: }]
      //   "ItemId": "33300003",
      // "ItemName": "21ST CENT FOLICACID TAB 100S",
      // "ITEMBARCODE": "3330000306237",
      // "DATAAREAID": "1000",
      // "WAREHOUSE": "AJM0053",
      // "CONFIGID": "",
      // "COLORID": "",
      // "SIZEID": "",
      // "STYLEID": "",
      // "INVENTSTATUS": "",
      // "QTY": 0.0,
      // "UNIT": "PAC

      setState(() {
        onHandList = [];
        onHandList = responseJson[0]['Importdata'];
        // stores = responseJson[0]['Stores'];
      });
      print("got it device");
      // print(selectDevice);
      // print(selectStore);
      // print("got it device");
      Navigator.pop(context);
      dynamic dt;
      int index = onHandList.indexWhere(
          (element) => element['WAREHOUSE'].trim() == activatedStore);
      dt = onHandList[index];
      if (index != -1) {
        onHandList.removeAt(index);
        onHandList.insert(0, dt);
      }
      setState(() {});

      onHandList.forEach((element) {
        print(element);
      });
    }
    else{
      Navigator.pop(context);
    }
  }

  Future<void> _onQRViewCreated(QRViewController controller) async {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        print("scan result : 953");
        barcodeController.text = result!.code.toString();
        getPrice();
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

  @override
  void dispose() {
    _focusNodeBarcode.dispose();
    _focusNodeQty.dispose();
    controller?.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  var transType = "";

  dynamic transactionData;
  dynamic APPGENERALDATASave;
  String? activatedStore;
  String? activatedDevice;
  String? remainedQty;

  getDataUsers() async {
    APPGENERALDATASave = await _sqlHelper.getLastColumnAPPGENERALDATA();
    setState(() {});

    print("69 ... line");
    print(APPGENERALDATASave.isEmpty);
    print("71 ... line");
    if (APPGENERALDATASave != [] || APPGENERALDATASave != null) {
      print("store codes 72");
      print(activatedStore);
      print("store codes 74");

      setState(() {
        activatedStore = APPGENERALDATASave['STORECODE'] ?? "";
        activatedDevice = APPGENERALDATASave['DEVICEID'] ?? "";
      });
    }
  }

  getToken() async {
    // getTransTypes();

    setState(() {});

    print("init Api");
    prefs = await SharedPreferences.getInstance();
    print("camera status");
    print(await prefs?.getString("camera"));
    disableCamera = await prefs?.getString("camera");

    var v = await prefs?.getString("disableCamera");
    disableCamera = v.toString() == "true" ? "true" : "false";

    // await prefs?.getString("disableCamera");
    // disabledCamera = prefs?.getString("disableCamera") == "true" ? true : false;
    await prefs?.getString("enableUOMSelection");
    disabledUOMSelection =
        prefs?.getString("enableUOMSelection") == "true" ? "true" : "false";
    await prefs?.getString("enableContinuousScan");
    disabledContinuosScan =
        prefs?.getString("enableContinuousScan") == "true" ? "true" : "false";
    print("disables");
    print(await prefs?.getString("disableCamera"));
    print(await prefs?.getString("enableUOMSelection"));
    print(await prefs?.getString("enableContinuousScan"));
    print("disables app generals");
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

    var url = "${accessUrl.toString()}/oauth2/token" +
        "?"
            "tenant_id=$tenantId&"
            "client_id=$clientId&"
            "client_secret=$clientSecretId"
            "&resource=$resource&"
            "grant_type=$grantType";

    print(url);

    try {
      var map = Map<String, dynamic>();
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

      if (widget.isItemMasters != null) {
        getPrice(barcode: widget.itemDetails['ITEMBARCODE']);
      }
      print(token);
    } catch (e) {}
    // Focus.of(context).requestFocus(_focusNodeBarcode);

    FocusScope.of(context).requestFocus(_focusNodeBarcode);
  }

  getItemAmount() {
    print("item Details from itemMasters");
    print(widget.itemDetails);
    barcodeController.text = widget.itemDetails['ITEMBARCODE'];
    itemIdController.text = widget.itemDetails['ItemId'];
    descriptionController.text = widget.itemDetails['ItemName'] ?? "";

    sizeController.text = widget.itemDetails['SIZEID'];
    uomController.text = widget.itemDetails['UNIT'];

    colorController.text = widget.itemDetails['COLORID'];
    styleController.text = widget.itemDetails['STYLEID'];

    configController.text = widget.itemDetails['CONFIGID'];
    activePriceController.text = widget.itemDetails['ItemAmount'].toString();

    setState(() {});
  }

  bool? isFocus = false;

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
    // getTransactionDetails();
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    getDataUsers();

    if (widget.itemDetails != null) {
      getItemAmount();
    }

    getToken();


    _focusNodeBarcode.addListener(() {
      print("Has focus: ${_focusNodeBarcode.hasFocus}");
      if (!_focusNodeBarcode.hasFocus) {
        setState(() {
          isFocus = false;
        });
      } else {
        setState(() {
          isFocus = true;
        });
      }
      // if (_focusNodeBarcode.hasFocus && isFocus!) {
      //   itemIdController.clear();
      //   barcodeController.clear();
      //   descriptionController.clear();
      //   uomController.clear();
      //   sizeController.clear();
      //   colorController.clear();
      //   styleController.clear();
      //   configController.clear();
      //   qtyController.clear();
      //   activePriceController.clear();
      //   setState(() {
      //     onHandList = [];
      //   });
      // }
    });


    _focusNodeQty.addListener(() {
      print("Has focus: ${_focusNodeQty.hasFocus}");
      if (!_focusNodeQty.hasFocus) {
        FocusScope.of(context).requestFocus(_focusNodeBarcode);
      }
    });
    super.initState();
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
            Container(child: Text("Fetching Data...")),
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
      barrierDismissible: true,
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
      child: Text("Ok", style: APPConstants().YesText),
      onPressed: () {
        // saveSettings();
        setState(() {});
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("DynamicsConnect"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: null,
        body:
            // MediaQuery.of(context).orientation == Orientation.landscape
            //     ?

            Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 20,
                child: Center(
                  child: Text(
                    "Store : ${activatedStore ?? ""}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        decorationColor: Colors.red,
                        decorationThickness: 2.5,
                        // decoration: TextDecoration.underline,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown),
                  ),
                ),
              )
            ],
          ),

          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  height: 35,
                  child: TextFormField(
                    textInputAction: TextInputAction.go,
                    onFieldSubmitted: (value) {
                      print("Go button is clicked");
                      getPrice(barcode: value.trim());
                    },
                    onTap: ()async {

                      await  controller?.resumeCamera();
                      itemIdController.clear();
                      barcodeController.clear();
                      descriptionController.clear();
                      uomController.clear();
                      sizeController.clear();
                      colorController.clear();
                      styleController.clear();
                      configController.clear();
                      qtyController.clear();
                      activePriceController.clear();
                      setState(() {
                        onHandList = [];
                      });
                    },
                    // onChanged: (value){
                    //      getPrice(
                    //        barcode: value.trim()
                    //      );
                    // },
                    focusNode: _focusNodeBarcode,
                    validator: (value) => value!.isEmpty ? 'Required *' : null,
                    controller: barcodeController,
                    decoration: InputDecoration(
                      focusedBorder: APPConstants().focusInputBorder,
                      enabledBorder: APPConstants().enableInputBorder,
                      suffixIcon: IconButton(
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ViewItemsOldPage(
                                        isOnHand: true,
                                        isHomeView: false,
                                      )));
                        },
                        icon: Icon(
                          Icons.manage_search,
                          size: 20,
                        ),
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.only(
                          left: 15, right: 15, top: 2, bottom: 2),
                      hintText: "Barcode",
                      hintStyle: TextStyle(color: Colors.black26),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Visibility(
              visible: disableCamera == null || disableCamera == "false",
              child: SizedBox(
                height: 5,
              )),
          Visibility(
            visible: disableCamera == null || disableCamera == "false",
            child: Expanded(
              flex: 3,
              child: Container(
                height: MediaQuery.of(context).size.height,
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
                        await controller?.pauseCamera();
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
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15.0)),
                      // margin: EdgeInsets.symmetric(horizontal: 3),
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
          ),
          SizedBox(
            height: 10,
          ),
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 10),
          //   child: Tooltip(
          //
          //     message: "This is an message",
          //     child: TextButton(
          //       style: TextButton.styleFrom(backgroundColor: Colors.redAccent,
          //      ),
          //       // color: Colors.red,
          //       // tooltip: "hi",
          //       onPressed: (){
          //
          //       },
          //       child: Text("Click Me"),
          //
          //     ),
          //   ),
          // ),
          Expanded(
              flex: 10,
              child: Container(
                // height: 300,
                // height: MediaQuery.of(context).size.height ,
                // height: MediaQuery.of(context).size.height /2,
                child: ListView.builder(
                  // reverse: true,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.zero,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, int index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          indexSelected = index;
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                        color:
                            indexSelected == index ? Colors.orangeAccent : null,
                        child: Column(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    color: Color(0xfff5deb4),
                                    borderRadius: BorderRadius.circular(15.0),
                                    border: Border.all(
                                        color: Colors.black12, width: 1.2)
                                    // color: Colors.red,
                                    ),
                                margin: EdgeInsets.only(
                                    right: 15.0,
                                    bottom: 3.0,
                                    top: 3.0,
                                    left: 15.0),
                                padding: EdgeInsets.only(
                                    left: 10.0, bottom: 10, top: 10, right: 5),
                                //   height: 300,

                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${onHandList[index]['WAREHOUSE'] ?? ""}",
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 18,
                                              fontFamily: "RobotoSerif",
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        // {id: 2, ITEMBARCODE: 3330000307227, ItemId: 33300003,
                                        //   ItemName: 21ST CENT FOLICACID TAB 100S,
                                        //   DATAAREAID: 1000, WAREHOUSE: ,
                                        //   CONFIGID: , COLORID: , SIZEID: , STYLEID: ,
                                        //   INVENTSTATUS: , QTY: 0.0, UNIT: PACK, ItemAmount: 0.0}
                                        Expanded(child: Text("Item ID :")),
                                        Expanded(
                                            child: Text(onHandList[index]
                                                    ['ItemId'] ??
                                                "")),
                                        // Expanded(child: Text(itemMastersLists[index].toString())),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(child: Text("BARCODE  :")),
                                        Expanded(
                                            child: Text(onHandList[index]
                                                    ['ITEMBARCODE'] ??
                                                ""))
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(child: Text("Item Name :")),
                                        Expanded(
                                            child: Text(onHandList[index]
                                                    ['ItemName'] ??
                                                ""))
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(child: Text("QTY :")),
                                        Expanded(
                                            child: Text(
                                                "${onHandList[index]['QTY']?.toString() ?? ""}"
                                                "\t\t\t\t  \t\t\t\t${onHandList[index]['UNIT']?.toString() ?? ""}"))
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),
                    );
                  },

                  // itemBuilder: (c, i) => Card(child: Center(child: Text(items[i]))),
                  // itemExtent: 300.0,
                  itemCount: onHandList.length,
                ),
              )),
        ],
      ),
    )

        //     : Column(
        //   // mainAxisSize: MainAxisSize.min,
        //   // padding: EdgeInsets.symmetric(horizontal: 10),
        //   children: [
        //     SizedBox(
        //       height: 10,
        //     ),
        //     Row(
        //       children: [
        //         Text(
        //           "${widget.type == "PO" ? "Purchase Order" : widget.type == "TO" ? "Transfer Order" : widget.type == "RO" ? "Return Order" : widget.type == "RP" ? "Return Pick" : widget.type == "GRN" ? "Goods Receive" : widget.type == "ST" ? "Stock Count" : widget.type == "TO-OUT" ? "Transfer Order Out" : widget.type == "TO-IN" ? "Transfer Order In" : ""} ",
        //           style: TextStyle(color: Colors.green),
        //         )
        //       ],
        //     ),
        //     SizedBox(
        //       height: 10,
        //     ),
        //     Container(
        //       margin: EdgeInsets.symmetric(horizontal: 10),
        //       height: 35,
        //       child: TextFormField(
        //         validator: (value) => value!.isEmpty ? 'Required *' : null,
        //         controller: barcodeController,
        //         decoration: InputDecoration(
        //             suffixIcon: IconButton(
        //               onPressed: () {},
        //               icon: Icon(
        //                 Icons.manage_search,
        //                 size: 20,
        //               ),
        //             ),
        //             isDense: true,
        //             contentPadding: EdgeInsets.only(
        //                 left: 15, right: 15, top: 2, bottom: 2),
        //             hintText: "Bar Code",
        //             border: OutlineInputBorder(
        //               borderRadius: BorderRadius.circular(7.0),
        //               // borderSide: Border()
        //             )),
        //       ),
        //     ),
        //     Visibility(
        //         visible: disableCamera == null || disableCamera == "false",
        //         child: SizedBox(
        //           height: 10,
        //         )),
        //     Visibility(
        //       visible: disableCamera == null || disableCamera == "false",
        //       child: Container(
        //         margin: EdgeInsets.symmetric(horizontal: 10),
        //         child: Stack(
        //           alignment: Alignment.bottomCenter,
        //           children: [
        //             // IgnorePointer(
        //             // ignoring: !_focusNodeDocumentNo.hasFocus &&
        //             //         documentnoController.text == ""
        //             //     ? true
        //             //     : false,
        //             // ignoring: true,
        //             // child:
        //             GestureDetector(
        //               onTap: () async {
        //                 await controller?.resumeCamera();
        //                 await controller?.toggleFlash();
        //               },
        //               child: Container(
        //                   height: 150,
        //                   child: _buildQrView(
        //                       context,
        //                       MediaQuery.of(context).orientation ==
        //                           Orientation.portrait
        //                           ? true
        //                           : false)),
        //             ),
        //             // Divider(
        //             //   color: Colors.red,
        //             //   thickness: 5,
        //             //   height: 10.0,
        //             // ),
        //             // ),
        //             Container(
        //               margin: EdgeInsets.symmetric(horizontal: 10),
        //               height: 30,
        //               color: Colors.black.withOpacity(0.4),
        //               child: Center(
        //                 child: Text(
        //                   "Place the blue line over the line ",
        //                   textAlign: TextAlign.center,
        //                   style: TextStyle(color: Colors.white),
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //     SizedBox(
        //       height: 10,
        //     ),
        //     Container(
        //       margin: EdgeInsets.symmetric(horizontal: 10),
        //       // height: 35,
        //       child: TextFormField(
        //         validator: (value) => value!.isEmpty ? 'Required *' : null,
        //         // controller: transactionNumberController,
        //         decoration: InputDecoration(
        //             isDense: true,
        //             contentPadding: EdgeInsets.only(
        //                 left: 15, right: 15, top: 5, bottom: 5),
        //             hintText: "Item ID",
        //             border: OutlineInputBorder(
        //               borderRadius: BorderRadius.circular(7.0),
        //               // borderSide: Border()
        //             )),
        //       ),
        //     ),
        //     SizedBox(
        //       height: 10,
        //     ),
        //     Container(
        //       margin: EdgeInsets.symmetric(horizontal: 10),
        //       child: TextFormField(
        //         validator: (value) => value!.isEmpty ? 'Required *' : null,
        //         minLines: 1,
        //         maxLines: 6,
        //         // controller: transactionNumberController,
        //         decoration: InputDecoration(
        //           // suffixIcon: IconButton(
        //           //   onPressed: (){
        //           //
        //           //   }, icon: Icon(Icons.search_outlined),
        //           // ),
        //             isDense: true,
        //             contentPadding: EdgeInsets.only(
        //                 left: 15, right: 15, top: 5, bottom: 5),
        //             hintText: "Description",
        //             border: OutlineInputBorder(
        //               borderRadius: BorderRadius.circular(7.0),
        //               // borderSide: Border()
        //             )),
        //       ),
        //     ),
        //     SizedBox(
        //       height: 10,
        //     ),
        //     Container(
        //       margin: EdgeInsets.symmetric(horizontal: 10),
        //       // height: 35,
        //       child: TextFormField(
        //         validator: (value) => value!.isEmpty ? 'Required *' : null,
        //         // controller: transactionNumberController,
        //         decoration: InputDecoration(
        //           // suffixIcon: IconButton(
        //           //   onPressed: (){
        //           //
        //           //   }, icon: Icon(Icons.search_outlined),
        //           // ),
        //             isDense: true,
        //             contentPadding: EdgeInsets.only(
        //                 left: 15, right: 15, top: 5, bottom: 5),
        //             hintText: "UOM",
        //             border: OutlineInputBorder(
        //               borderRadius: BorderRadius.circular(7.0),
        //               // borderSide: Border()
        //             )),
        //       ),
        //     ),
        //     // Spacer(),
        //     Container(
        //       margin: EdgeInsets.symmetric(horizontal: 10),
        //       child: Row(
        //         children: [
        //           Expanded(
        //             child: TextFormField(
        //               keyboardType: TextInputType.number,
        //               validator: (value) =>
        //               value!.isEmpty ? 'Required *' : null,
        //               // controller: transactionNumberController,
        //               decoration: InputDecoration(
        //                 // suffixIcon: IconButton(
        //                 //   onPressed: (){
        //                 //
        //                 //   }, icon: Icon(Icons.search_outlined),
        //                 // ),
        //
        //                   isDense: true,
        //                   contentPadding: EdgeInsets.only(
        //                       left: 15, right: 15, top: 10, bottom: 10),
        //                   hintText: "QTY",
        //                   border: OutlineInputBorder(
        //                     borderRadius: BorderRadius.circular(7.0),
        //                     // borderSide: Border()
        //                   )),
        //             ),
        //           ),
        //           SizedBox(
        //             width: 10,
        //           ),
        //           Expanded(
        //               child: SizedBox(
        //                 height: 40,
        //                 child: TextButton(
        //                     style: TextButton.styleFrom(
        //                         shape: RoundedRectangleBorder(
        //                             borderRadius: BorderRadius.circular(10.0)),
        //                         backgroundColor: Colors.green[300]),
        //                     onPressed: () {},
        //                     child: Text(
        //                       "ADD",
        //                       style: TextStyle(color: Colors.white),
        //                     )),
        //               )),
        //         ],
        //       ),
        //     ),
        //     SizedBox(
        //       height: 25,
        //     ),
        //   ],
        // )
        );
  }
}
