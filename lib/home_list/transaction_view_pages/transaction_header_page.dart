import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dynamicconnectapp/common_pages/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dynamicconnectapp/helper/local_db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'dart:io';

import '../../constants/constant.dart';

class TranscationHeaderPage extends StatefulWidget {
  TranscationHeaderPage({this.type});
  final dynamic type;

  @override
  State<TranscationHeaderPage> createState() => _TranscationHeaderPageState();
}

class _TranscationHeaderPageState extends State<TranscationHeaderPage> {
  List<dynamic> stores = [];

  String? selectStore;
  String? activatedStore;
  String? activatedDevice;
  String? username;
  SharedPreferences? prefs;
  var APPGENERALDATASave;
  bool? isActivated = false;
  bool? isActivateNew = false;
  bool? isActivateSave = false;
  bool? isCloseTransactions = false;
  bool? isPostTransactions = false;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  List<dynamic> movementJournals = [];
  String? selectOrder;
  String? selectLocation;
  List<dynamic> orderNos = [];
  String? selectJournal;

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
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    for (var i = 1; i < 51; i++) {
      locations.add(i);
    }
    getUserData();
    getToken();
    super.initState();
  }

  String? companyCode;

  final SQLHelper _sqlHelper = SQLHelper();

  String? baseUrlString;

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
  String? getMovementJournals;
  String? getDeactivate;
  String? updateDevice;
  String? token;
  TextEditingController? documentNoController = TextEditingController();
  TextEditingController? descriptionController = TextEditingController();

  // setValues() async {
  //   await _sqlHelper.getLastColumnAPPGENERALDATA();
  //
  //   if (await _sqlHelper.getLastColumnAPPGENERALDATA() == "" ||
  //       await _sqlHelper.getLastColumnAPPGENERALDATA() == []) {
  //     print("No Data");
  //     PONextDocNoController.text = 1.toString();
  //     GRNNextDocNoController.text = 1.toString();
  //     TOINNextDocNoController.text = 1.toString();
  //     TOOutNextDocNoController.text = 1.toString();
  //     TONextDocNoController.text = 1.toString();
  //
  //     STNextDocNoController.text = 1.toString();
  //     RPNextDocNoController.text = 1.toString();
  //     RONextDocNoController.text = 1.toString();
  //     setState(() {});
  //   } else {
  //     print("Found Data");
  //     // [
  //     //   {
  //     //     id: 1, DEVICEID: , STORECODE:
  //     //   AJM0070, PONEXTDOCNO: 1, GRNNEXTDOCNO: 1,
  //     //   RONEXTDOCNO: 1, RPNEXTDOCNO: 1,
  //     //   STNEXTDOCNO: 1, TONEXTDOCNO: 1,
  //     //     TOOUTNEXTDOCNO: 1, TOINNEXTDOCNO: 1}
  //     // ]
  //
  //     APPGENERALDATASave = await _sqlHelper.getLastColumnAPPGENERALDATA();
  //
  //     setState(() {});
  //     print("...248 dt");
  //     print(APPGENERALDATASave);
  //
  //     isActivated = APPGENERALDATASave['isDeactivate'] == 1 ? true : false;
  //     //   "DEVICEID": DEVICEID,
  //     // "STORECODE": STORECODE,
  //     // print("Selected Device is : ${selectDevice}");
  //
  //     PONextDocNoController.text = APPGENERALDATASave['PONEXTDOCNO'].toString();
  //     GRNNextDocNoController.text =
  //         APPGENERALDATASave['GRNNEXTDOCNO'].toString();
  //     TOINNextDocNoController.text =
  //         (APPGENERALDATASave['TOINNEXTDOCNO']).toString();
  //     TOOutNextDocNoController.text =
  //         APPGENERALDATASave['TOOUTNEXTDOCNO'].toString();
  //     TONextDocNoController.text =
  //         (APPGENERALDATASave['TOINNEXTDOCNO']).toString();
  //
  //     STNextDocNoController.text = APPGENERALDATASave['STNEXTDOCNO'].toString();
  //     RPNextDocNoController.text = APPGENERALDATASave['RPNEXTDOCNO'].toString();
  //     RONextDocNoController.text = APPGENERALDATASave['RONEXTDOCNO'].toString();
  //     selectDevice = APPGENERALDATASave['DEVICEID'].toString();
  //     selectStore = APPGENERALDATASave['STORECODE'].toString();
  //     setState(() {});
  //     print("Data : ${APPGENERALDATASave['STORECODE'].toString()}");
  //   }
  // }

  getOrderNos() async {
    orderNos = [];
    orderNos = await _sqlHelper.getHeaderOrders(widget.type == 'ST'
        ? "1"
        : widget.type == 'PO'
            ? "3"
            : widget.type == 'GRN'
                ? "4"
                : widget.type == 'RO'
                    ? "9"
                    : widget.type == 'RP'
                        ? "10"
                        : widget.type == 'TO-OUT'
                            ? "5"
                            : widget.type == 'TO-IN'
                                ? "6"
                                : "");

    orderNos.forEach((element) {
      print("elements 160");
      print(element);
    });
  }

  List<dynamic> transactionData = [];
  List<dynamic> transactionDetails = [];
  List<dynamic> transactionDetailsList = [];
  getToken() async {
    await getOrderNos();
    transactionData = await _sqlHelper.getTRANSHEADER(widget.type == 'ST'
        ? "1"
        : widget.type == 'PO'
            ? "3"
            : widget.type == 'GRN'
                ? "4"
                : widget.type == 'RO'
                    ? "9"
                    : widget.type == 'RP'
                        ? "10"
                        : widget.type == 'TO'
                            ? "11"
                            : widget.type == "TO-OUT"
                                ? "5"
                                : widget.type == "TO-IN"
                                    ? "6"
                                    : widget.type == "MJ"
                                        ? "22"
                                        : widget.type == "MJ"
                                            ? "22"
                                            : "");

    print("data is 94 : ${widget.type}");
    print(transactionData);

    setState(() {});
    if (transactionData == "" || transactionData.length == 0) {
      print("list is empty : $transactionData");
      isActivateNew = false;
      isActivateSave = true;
    } else {
      print("list is not empty : $transactionData");
      isActivateNew = true;
      isActivateSave = true;
    }

    transactionDetails =
        await _sqlHelper.getTRANSDETAILSINHeader(widget.type == 'ST'
            ? "1"
            : widget.type == 'PO'
                ? "3"
                : widget.type == 'GRN'
                    ? "4"
                    : widget.type == 'RO'
                        ? "9"
                        : widget.type == 'RP'
                            ? "10"
                            : widget.type == 'TO'
                                ? "11"
                                : widget.type == "TO-OUT"
                                    ? "5"
                                    : widget.type == "TO-IN"
                                        ? "6"
                                        : widget.type == "MJ"
                                            ? "22"
                                            : "");

    print(transactionDetails.length);
    print("Line 224 ");
    if (transactionDetails.length > 0 && transactionData[0]['STATUS'] < 2) {
      isCloseTransactions = true;
      setState(() {});
    } else {
      isCloseTransactions = false;
      setState(() {});
    }
    // isPostTransactions =false;
    // isCloseTransactions =false;

    if (transactionData.length > 0) {
      transactionData[0]['STATUS'] == 0
          ? isActivateSave = true
          : transactionData[0]['STATUS'] == 2
              ? isPostTransactions = true
              : transactionData[0]['STATUS'] == 3
                  ? isActivateNew = false
                  : "";
      setState(() {});
      if (transactionData[0]['STATUS'] < 3) {
        // widget.type == 'PO' ?
        // selectLocation =     transactionData[0]['VRLOCATION'].toString() ??"" : selectLocation =  "";
        // widget.type == 'PO' ?
        if (widget.type == 'ST') {
          print("ST ...143");
          selectLocation = transactionData[0]['VRLOCATION']?.toString() ?? "";
        }
        documentNoController?.text = transactionData[0]['DOCNO'] ?? "";
        descriptionController?.text = transactionData[0]['DESCRIPTION'] ?? "";
        selectOrder = transactionData[0]['AXDOCNO'] == ""
            ? null
            : transactionData[0]['AXDOCNO'] ?? "";
        setState(() {});
        if (transactionData[0]['TYPEDESCR'] == "TO") {
          selectStore = transactionData[0]['TOSTORECODE'] ?? "";
          setState(() {});
        }

        if (transactionData[0]['TYPEDESCR'] == "MJ") {
          selectJournal = transactionData[0]['JournalName'] ?? "";
          setState(() {});
        }

        print("137 ..data : ${transactionData[0]['AXDOCNO']}");
        print(selectStore);
      }
    }

    print("init Api :  ${transactionData.toString()}");
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
    // await prefs?.getString("enableContinuousScan");
    // disabledContinuosScan =
    prefs?.getString("enableContinuousScan") == "true" ? true : false;
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
    getMovementJournals = await prefs!.getString("getJournal") ?? "";
    getDeactivate = await prefs!.getString("deactivate");
    updateDevice = await prefs!.getString("updateDevice");

    await prefs!.setBool("lineDeleted", false);
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

      await getStoreCode();

      await getMovementJournal();
      // getDevices();
      // getTatmeenDetails();
      print(token);
    } catch (e) {}
  }

  String? docNo;

  getUserData() async {
    setState(() {
      isActivated = true;
    });
    prefs = await SharedPreferences.getInstance();
    username = await prefs?.getString("username");
    companyCode = await prefs!.getString("companyCode");

    // password = await prefs?.getString("password");
    // print(context.router?.currentPath);

    APPGENERALDATASave = await _sqlHelper.getLastColumnAPPGENERALDATA();
    setState(() {});

    print(APPGENERALDATASave.isEmpty);
    print("71 ... line");
    if (APPGENERALDATASave != [] || APPGENERALDATASave != null) {
      print("store codes 232");
      print(activatedStore);

      setState(() {
        activatedStore = APPGENERALDATASave['STORECODE'] ?? "";
        activatedDevice = APPGENERALDATASave['DEVICEID'] ?? "";
      });
    }

    print(username);
  }

  List<dynamic> locations = [];

  getStoreCode() async {
    var tk = 'Bearer ${token.toString()}';
    Map<String, String> headers = {
      "Content-type": "application/json",
      'Authorization': tk
    };
    var body = {
      "dataAreaId": "$companyCode" // 1 - to get only counting journal lines
    };
    // var ur = APIConstants.baseUrl + "pushTransactionTatmeen";
    var ur = "$getStore";
    print(ur);
    var js = json.encode(body);
    var res = await http.post(headers: headers, Uri.parse(ur), body: js);
    var responseJson = json.decode(res.body);
    // print(responseJson);

    if (res.statusCode == 200 || res.statusCode == 201) {
      print("got it device");
      // print(selectDevice);
      print(selectStore);
      print("got it device");
      setState(() {
        stores = responseJson[0]['Stores'];
        final int item =
            stores.indexWhere((e) => e['storecode'] == activatedStore);
        stores.removeAt(item);
      });

      stores.forEach((element) {
        print(element);
      });
    }
  }

  pushTransactionToPost() async {
    print(_connectionStatus.runtimeType);

    var tk = 'Bearer ${token.toString()}';
    Map<String, String> headers = {
      "Content-type": "application/json",
      'Authorization': tk
    };

    transactionDetailsList = [];
    setState(() {});
    // if(transactionDetails.length <=0){
    //   showDialogGotData("");
    // }

    transactionDetails.forEach((element) {
      print("445 .. line");
      print(element);
      var dt = {
        "DOCNO": element['DOCNO'],
        "STORECODE": element['STORECODE'],
        "BARCODE": element['BARCODE'],
        "TRANSTYPE": element['TRANSTYPE'],
        "ITEMID": element['ITEMID'],
        "UOM": element['UOM'],
        "CONFIGID": element['CONFIGID'],
        "SIZEID": element['SIZEID'],
        "COLORID": element['COLORID'],
        "STYLESID": element['STYLESID'],
        "QTY": element['QTY'],
        "BATCHNO": element['BATCHNO'],
        "EXPDATE": element['EXPDATE'],
        "PRODDATE": element['PRODDATE'],
        "BatchEnabled": element['BatchEnabled'] == 1 ? true : false,
        "BatchedItem": element['BatchedItem'] == 1 ? true : false,
        "LOCATION": "",
        "DEVICEID": element['DEVICEID'],
        "CREATEDDATE": element['CREATEDDATE']
      };
      transactionDetailsList.add(dt);

      // print(element);
    });
    print(transactionDetailsList.length);
    print("element transaction list 331");
    transactionDetailsList.forEach((ele) {
      print(json.encode(ele));
    });

    print(activatedStore);
    print(activatedDevice);

    print(
        "The line header is : ${transactionData[0]['TRANSTYPE'].runtimeType}");

    // return;

    var body = {
      "contract": {


        //     transType == "STOCK COUNT"
        //         ? 1
        //         : widget.type == "GRN"
        //         ? 4
        //         : widget.type == "RP"
        //         ? 10
        //         : widget.type == "TO-OUT"
        //         ? 5
        //         : widget.type == "TO-IN"
        //         ? 6
        // : transType == "RETURN ORDER"
        // ? 9
        //     : transType == "TRANSFER ORDER"
        // ? 11


        "JournalName": transactionData[0]['TRANSTYPE'].toString() == "22"
            ? transactionData[0]['JournalName']
            : "",
        "DeviceNumSeq": transactionData[0]['TRANSTYPE'].toString() == "1"
            ? APPGENERALDATASave['STNEXTDOCNO']
            : transactionData[0]['TRANSTYPE'].toString() == "3"
                ? APPGENERALDATASave['PONEXTDOCNO']
                : transactionData[0]['TRANSTYPE'].toString() == "4"
                    ? APPGENERALDATASave['GRNNEXTDOCNO']
                    : transactionData[0]['TRANSTYPE'].toString() == "10"
                        ? APPGENERALDATASave['RPNEXTDOCNO']
                        : transactionData[0]['TRANSTYPE'].toString() == "5"
                            ? APPGENERALDATASave['TOOUTNEXTDOCNO']
                            : transactionData[0]['TRANSTYPE'].toString() == "6"
                                ? APPGENERALDATASave['TOINNEXTDOCNO']
                                : transactionData[0]['TRANSTYPE'].toString() ==
                                        "9"
                                    ? APPGENERALDATASave['RONEXTDOCNO']
                                    : transactionData[0]['TRANSTYPE']
                                                .toString() ==
                                            "11"
                                        ? APPGENERALDATASave['TONEXTDOCNO']
                                        : transactionData[0]['TRANSTYPE']
                                                    .toString() ==
                                                "22"
                                            ? APPGENERALDATASave['MJNEXTDOCNO']
                                            : "",

        "DOCNO": documentNoController?.text,
        "AXDOCNO": selectOrder == "" || selectOrder == null ? "" : selectOrder,
        "STORECODE": activatedStore,
        "TOSTORECODE": widget.type == "TO" ? selectStore : "",
        "TRANSTYPE": transactionData[0]['TRANSTYPE'].toString(),
        "STATUS": transactionData[0]['STATUS'].toString(),
        "USERNAME": username,
        "VRLOCATION": selectLocation ?? "0",
        "DESCRIPTION": descriptionController?.text,
        "CREATEDDATE": transactionData[0]['CREATEDDATE'].toString(),
        "DATAAREAID": companyCode ?? "",
        "DEVICEID": activatedDevice,
        "pushdata": transactionDetailsList
      }
    };
    if (kDebugMode) {
      print("request body ...435");
      print(transactionDetailsList.length);
      print(json.encode(body));
    }

    // return;

    // var ur = APIConstants.baseUrl + "pushTransactionTatmeen";
    var ur = "$pushStockTakeApi";
    print(ur);

    var js = json.encode(body);
    // return;
    var res;
    var responseJson;

    try {
      res = await http.post(headers: headers, Uri.parse(ur), body: js);

      responseJson = json.decode(res.body);
      setState(() {});
    } catch (e) {
      Navigator.pop(context);
      showDialogGotData("Network Error : ${e.toString()}");
      return;
    }

    print(res.statusCode);

    print(responseJson);

    if (res.statusCode == 200 || res.statusCode == 201) {
      print("Post closed success");
      print(res.body);

      if (responseJson[0]['Message'].toString().contains("success")) {
        await _sqlHelper.updateStatusStockCount(
            3,
            documentNoController?.text.trim() ?? "",
            widget.type == 'ST'
                ? "1"
                : widget.type == 'PO'
                    ? "3"
                    : widget.type == 'GRN'
                        ? "4"
                        : widget.type == 'RO'
                            ? "9"
                            : widget.type == 'RP'
                                ? "10"
                                : widget.type == 'TO'
                                    ? "11"
                                    : widget.type == "TO-OUT"
                                        ? "5"
                                        : widget.type == "TO-IN"
                                            ? "6"
                                            : widget.type == "TO-IN"
                                                ? "22"
                                                : "",
            selectOrder);

        setState(() {
          // setState(() {
          isActivated = false;

          isActivateSave = true;
          // });

          selectStore = null;
          selectLocation = null;
          isActivateNew = false;
          documentNoController?.clear();
          descriptionController?.clear();
          orderNos = [];
          selectOrder = null;
          isPostTransactions = false;
          isCloseTransactions = false;
        });
        showDialogGotData(
            "Transaction Posted ${responseJson[0]['Message'].toString()}fully");
      } else {
        showDialogGotData(responseJson[0]['Message'].toString());
      }
    } else {
      showDialogGotData(responseJson[0]['Message'].toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    print(isActivated);
    print(activatedStore);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("${widget.type} Header page"),
      // ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(child: Text("Store Code")),
                  Visibility(
                    visible: widget.type == "ST" || widget.type == "TO",
                    child: SizedBox(width: 10),
                  ),
                  Visibility(
                      visible: widget.type == "ST",
                      child: Expanded(child: Text("Location"))),
                  Visibility(
                      visible: widget.type == "TO",
                      child: Expanded(child: Text("TO Store Code")))
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: Container(
                    height: 35,

                    // margin: EdgeInsets.only(left: 13),
                    child: Center(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(activatedStore ?? "",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 15)),

                          // Spacer(),
                          // Icon(
                          //   Icons.arrow_forward_ios_rounded,
                          //   size: 14,
                          // ),
                          // SizedBox(
                          //   width: 10,
                          // )
                        ],
                      ),
                    ),
                    decoration: BoxDecoration(
                        color:
                            // isActivated != null && isActivated!
                            //     ? Colors.black12:
                            Colors.black12,
                        border: Border.all(color: Colors.black, width: 0.5),
                        borderRadius: BorderRadius.circular(5.0)),
                  )),
                  Visibility(
                      visible: widget.type == "TO",
                      child: SizedBox(
                        width: 10,
                      )),
                  Visibility(
                    visible: widget.type == "TO",
                    child: Expanded(
                      child: IgnorePointer(
                        ignoring: isActivated!,
                        child: stores.isEmpty
                            ? Row(
                                children: [
                                  Expanded(
                                      child: Container(
                                    height: 35,
                                    // margin: EdgeInsets.only(left: 13),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Select STORE",
                                            style: TextStyle(
                                                color: !isActivateNew! == true
                                                    ? Colors.black26
                                                    : Colors.black,
                                                fontSize: 15),
                                          ),
                                          Spacer(),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 14,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          )
                                        ],
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                        color:
                                            // isActivated != null && isActivated!
                                            //     ? Colors.black12:
                                            Colors.white,
                                        border: Border.all(
                                            color: Colors.black, width: 0.5),
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                  )),
                                ],
                              )
                            : Container(
                                height: 35,
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: Colors.white,
                                    // backgroundColor: Colors.black26,
                                    // cardColor: Colors.black12
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                      dropdownMaxHeight: 400,
                                      // underline: Divider(
                                      //   // indent: 2,
                                      //
                                      //   height: 1,
                                      //   thickness: 1,
                                      //   color: Colors.black,
                                      // ),
                                      barrierDismissible: true,
                                      // disabledHint: false,
                                      isExpanded: true,
                                      buttonHeight: 500,

                                      hint: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'To Store',
                                              style: TextStyle(
                                                // fontSize: 14,
                                                // fontWeight: FontWeight.bold,

                                                color: Colors.black38,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),

                                      items: stores
                                          .map((item) =>
                                              DropdownMenuItem<String>(
                                                value: item['storecode']
                                                    .toString(),
                                                child: Text(
                                                  item['storecode'] ?? "",
                                                  style: TextStyle(
                                                    // fontSize: 14,
                                                    // fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ))
                                          .toList(),
                                      value: selectStore,
                                      onChanged: (value) {
                                        setState(() {
                                          selectStore =
                                              value.toString() as String;
                                        });
                                      },
                                      icon: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 13.0),
                                        child: Icon(
                                          Icons.arrow_forward_ios_outlined,
                                        ),
                                      ),
                                      iconSize: 14,

                                      buttonDecoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        border: Border.all(
                                            color: Colors.black38, width: 0.5),
                                        // color: isActivated != null && isActivated!
                                        //     ? Colors.black12:
                                        // Colors.white,
                                      ),

                                      buttonElevation: 0,

                                      dropdownDecoration: BoxDecoration(
                                        border: Border.all(
                                          // style: BorderStyle.none,
                                          width: 0.2,
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                        // color: Colors.white,
                                      ),
                                      dropdownElevation: 0,
                                      scrollbarRadius: Radius.circular(40),
                                      scrollbarThickness: 6,

                                      scrollbarAlwaysShow: true,
                                    ),
                                  ),
                                ),
                              ),
                      ),

                      // TextFormField(
                      //
                      //   validator: (value) =>
                      //   value!.isEmpty ? 'Required *' : null,
                      //   controller: deviceIdController,
                      //   decoration: InputDecoration(
                      //     isDense: true,
                      //     contentPadding: EdgeInsets.only(left: 10.0),
                      //       fillColor: Colors.white,
                      //       focusColor: Colors.white,
                      //       labelText: "Device ID",
                      //       border: UnderlineInputBorder(
                      //
                      //           borderSide: BorderSide(
                      //               color: Colors.grey
                      //           )
                      //       )),
                      // )
                    ),
                  ),
                  Visibility(
                      visible: widget.type == "MJ",
                      child: SizedBox(
                        width: 10,
                      )),
                  Visibility(
                    visible: widget.type == "MJ",
                    child: Expanded(
                      child: IgnorePointer(
                        ignoring: isActivated!,
                        child: stores.isEmpty
                            ? Row(
                                children: [
                                  Expanded(
                                      child: Container(
                                    height: 35,
                                    // margin: EdgeInsets.only(left: 13),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Select Journal",
                                            style: TextStyle(
                                                color: !isActivateNew! == true
                                                    ? Colors.black26
                                                    : Colors.black,
                                                fontSize: 15),
                                          ),
                                          Spacer(),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 14,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          )
                                        ],
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                        color:
                                            // isActivated != null && isActivated!
                                            //     ? Colors.black12:
                                            Colors.white,
                                        border: Border.all(
                                            color: Colors.black, width: 0.5),
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                  )),
                                ],
                              )
                            : Container(
                                height: 35,
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: Colors.white,
                                    // backgroundColor: Colors.black26,
                                    // cardColor: Colors.black12
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                      dropdownMaxHeight: 400,
                                      // underline: Divider(
                                      //   // indent: 2,
                                      //
                                      //   height: 1,
                                      //   thickness: 1,
                                      //   color: Colors.black,
                                      // ),
                                      barrierDismissible: true,
                                      // disabledHint: false,
                                      isExpanded: true,
                                      buttonHeight: 500,

                                      hint: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Select Journal',
                                              style: TextStyle(
                                                // fontSize: 14,
                                                // fontWeight: FontWeight.bold,

                                                color: Colors.black38,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),

                                      items: movementJournals
                                          .map((item) =>
                                              DropdownMenuItem<String>(
                                                value: item['journalNameId']
                                                    .toString(),
                                                child: Text(
                                                  item['journalNameId'] ?? "",
                                                  style: TextStyle(
                                                    // fontSize: 14,
                                                    // fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ))
                                          .toList(),
                                      value: selectJournal,
                                      onChanged: (value) {
                                        setState(() {
                                          selectJournal =
                                              value.toString() as String;
                                        });
                                      },
                                      icon: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 13.0),
                                        child: Icon(
                                          Icons.arrow_forward_ios_outlined,
                                        ),
                                      ),
                                      iconSize: 14,

                                      buttonDecoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        border: Border.all(
                                            color: Colors.black38, width: 0.5),
                                        // color: isActivated != null && isActivated!
                                        //     ? Colors.black12:
                                        // Colors.white,
                                      ),

                                      buttonElevation: 0,

                                      dropdownDecoration: BoxDecoration(
                                        border: Border.all(
                                          // style: BorderStyle.none,
                                          width: 0.2,
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                        // color: Colors.white,
                                      ),
                                      dropdownElevation: 0,
                                      scrollbarRadius: Radius.circular(40),
                                      scrollbarThickness: 6,

                                      scrollbarAlwaysShow: true,
                                    ),
                                  ),
                                ),
                              ),
                      ),

                      // TextFormField(
                      //
                      //   validator: (value) =>
                      //   value!.isEmpty ? 'Required *' : null,
                      //   controller: deviceIdController,
                      //   decoration: InputDecoration(
                      //     isDense: true,
                      //     contentPadding: EdgeInsets.only(left: 10.0),
                      //       fillColor: Colors.white,
                      //       focusColor: Colors.white,
                      //       labelText: "Device ID",
                      //       border: UnderlineInputBorder(
                      //
                      //           borderSide: BorderSide(
                      //               color: Colors.grey
                      //           )
                      //       )),
                      // )
                    ),
                  ),
                  Visibility(
                    visible: widget.type == "ST",
                    child: Expanded(
                      child: IgnorePointer(
                        ignoring: isActivated!,
                        child: Container(
                          height: 35,
                          // color: !isActivateNew! ==true?
                          // Colors.black12 :
                          // Colors.white,
                          margin: EdgeInsets.symmetric(horizontal: 2),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: Colors.white,
                              // backgroundColor: Colors.black26,
                              // cardColor: Colors.black12
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                dropdownMaxHeight: 400,
                                // underline: Divider(
                                //   // indent: 2,
                                //
                                //   height: 1,
                                //   thickness: 1,
                                //   color: Colors.black,
                                // ),
                                barrierDismissible: true,
                                // disabledHint: false,
                                isExpanded: true,
                                buttonHeight: 500,

                                hint: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Location ...',
                                        style: TextStyle(
                                          // fontSize: 14,
                                          // fontWeight: FontWeight.bold,
                                          color: !isActivateNew! == true
                                              ? Colors.black12
                                              : Colors.black,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),

                                items: locations
                                    .map((item) => DropdownMenuItem<String>(
                                          value: item?.toString(),
                                          child: Text(
                                            item?.toString() ?? "",
                                            style: TextStyle(
                                              // fontSize: 14,
                                              // fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                    .toList(),
                                value: selectLocation,
                                onChanged: (value) {
                                  setState(() {
                                    selectLocation = value.toString() as String;
                                  });
                                },
                                icon: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 13.0),
                                  child: Icon(
                                    Icons.arrow_forward_ios_outlined,
                                  ),
                                ),
                                iconSize: 14,

                                buttonDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Colors.black38, width: 0.5),
                                  // color: isActivated != null && isActivated!
                                  //     ? Colors.black12:
                                  // Colors.white,
                                ),

                                buttonElevation: 0,

                                dropdownDecoration: BoxDecoration(
                                  border: Border.all(
                                    // style: BorderStyle.none,
                                    width: 0.2,
                                    color: Colors.black,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  // color: Colors.white,
                                ),
                                dropdownElevation: 0,
                                scrollbarRadius: Radius.circular(40),
                                scrollbarThickness: 6,

                                scrollbarAlwaysShow: true,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // TextFormField(
                      //
                      //   validator: (value) =>
                      //   value!.isEmpty ? 'Required *' : null,
                      //   controller: deviceIdController,
                      //   decoration: InputDecoration(
                      //     isDense: true,
                      //     contentPadding: EdgeInsets.only(left: 10.0),
                      //       fillColor: Colors.white,
                      //       focusColor: Colors.white,
                      //       labelText: "Device ID",
                      //       border: UnderlineInputBorder(
                      //
                      //           borderSide: BorderSide(
                      //               color: Colors.grey
                      //           )
                      //       )),
                      // )
                    ),
                  )
                ],
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     SizedBox(
              //       width: 5,
              //     ),
              //     Text("Store Code")
              //   ],
              // ),
              // SizedBox(
              //   height: 10,
              // ),
              // Row(
              //   children: [
              //     Expanded(
              //       flex: 2,
              //       child: IgnorePointer(
              //         // ignoring: isActivated ?? false,
              //         child: Container(
              //           height: 35,
              //
              //           margin: EdgeInsets.symmetric(horizontal: 2),
              //           child: new Theme(
              //             data: Theme.of(context).copyWith(
              //               canvasColor: Colors.white,
              //               // backgroundColor: Colors.black26,
              //               // cardColor: Colors.black12
              //             ),
              //             child: DropdownButtonHideUnderline(
              //               child: DropdownButton2(
              //
              //                 dropdownMaxHeight: 400,
              //                 // underline: Divider(
              //                 //   // indent: 2,
              //                 //
              //                 //   height: 1,
              //                 //   thickness: 1,
              //                 //   color: Colors.black,
              //                 // ),
              //                 barrierDismissible: true,
              //                 // disabledHint: false,
              //                 isExpanded: true,
              //                 buttonHeight: 500,
              //
              //                 hint: Row(
              //                   children: const [
              //                     Expanded(
              //                       child: Text(
              //                         'Select Store',
              //                         style: TextStyle(
              //                           // fontSize: 14,
              //                           // fontWeight: FontWeight.bold,
              //                           color: Colors.black,
              //                         ),
              //                         overflow: TextOverflow.ellipsis,
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //                 items: stores
              //                     .map((item) => DropdownMenuItem<String>(
              //                   value: item['storecode'].toString(),
              //                   child: Text(
              //                     item['storecode']??"",
              //                     style: const TextStyle(
              //                       // fontSize: 14,
              //                       // fontWeight: FontWeight.bold,
              //                       color: Colors.black,
              //                     ),
              //                     overflow: TextOverflow.ellipsis,
              //                   ),
              //                 ))
              //                     .toList(),
              //                 value: selectStore,
              //                 onChanged: (value) {
              //                   setState(() {
              //                     selectStore = value as String;
              //                   });
              //                 },
              //                 icon: Padding(
              //                   padding: const EdgeInsets.symmetric(
              //                       horizontal: 13.0),
              //                   child: const Icon(
              //                     Icons.arrow_forward_ios_outlined,
              //                   ),
              //                 ),
              //                 iconSize: 14,
              //
              //                 buttonDecoration: BoxDecoration(
              //                   borderRadius: BorderRadius.circular(10),
              //                   border: Border.all(
              //                     color: Colors.black38,
              //                   ),
              //                   // color: isActivated != null && isActivated!
              //                   //     ? Colors.black12:
              //                   // Colors.white,
              //                 ),
              //
              //                 buttonElevation: 0,
              //
              //                 dropdownDecoration: BoxDecoration(
              //                   border: Border.all(
              //                     // style: BorderStyle.none,
              //                     width: 0.2,
              //                     color: Colors.black,
              //                   ),
              //                   borderRadius: BorderRadius.circular(10),
              //                   // color: Colors.white,
              //                 ),
              //                 dropdownElevation: 0,
              //                 scrollbarRadius: const Radius.circular(40),
              //                 scrollbarThickness: 6,
              //
              //                 scrollbarAlwaysShow: true,
              //                 // items: ['store 1','store 2']
              //                 //     .map((item) => DropdownMenuItem<String>(
              //                 //
              //                 //   value: item.toString(),
              //                 //   child: Text(
              //                 //     item,
              //                 //     style: const TextStyle(
              //                 //       // fontSize: 14,
              //                 //       // fontWeight: FontWeight.bold,
              //                 //       color: Colors.black,
              //                 //     ),
              //                 //     overflow: TextOverflow.ellipsis,
              //                 //   ),
              //                 // ))
              //                 //     .toList(),
              //                 // value: selectStore,
              //                 // onChanged: (value) {
              //                 //   setState(() {
              //                 //     selectStore = value  as String;
              //                 //   });
              //                 // },
              //                 // // icon: Padding(
              //                 // //   padding: const EdgeInsets.symmetric(horizontal: 5.0),
              //                 // //   child: const Icon(
              //                 // //     Icons.arrow_forward_ios_outlined,
              //                 // //   ),
              //                 // // ),
              //                 // // iconSize: 14,
              //                 //
              //                 // buttonDecoration: BoxDecoration(
              //                 //   color: Colors.white,
              //                 //   borderRadius: BorderRadius.circular(10),
              //                 //   border: Border.all(
              //                 //     style: BorderStyle.none,
              //                 //     color: Colors.white,
              //                 //   ),
              //                 //
              //                 // ),
              //                 //
              //                 // buttonElevation: 0,
              //                 //
              //                 // dropdownDecoration: BoxDecoration(
              //                 //   borderRadius: BorderRadius.circular(10),
              //                 //   // color: Colors.white,
              //                 // ),
              //                 // dropdownElevation: 0,
              //                 // scrollbarRadius: const Radius.circular(40),
              //                 // scrollbarThickness: 6,
              //                 //
              //                 // scrollbarAlwaysShow: true,
              //               ),
              //             ),
              //           ),
              //         ),
              //       ),
              //
              //       // TextFormField(
              //       //
              //       //   validator: (value) =>
              //       //   value!.isEmpty ? 'Required *' : null,
              //       //   controller: deviceIdController,
              //       //   decoration: InputDecoration(
              //       //     isDense: true,
              //       //     contentPadding: EdgeInsets.only(left: 10.0),
              //       //       fillColor: Colors.white,
              //       //       focusColor: Colors.white,
              //       //       labelText: "Device ID",
              //       //       border: UnderlineInputBorder(
              //       //
              //       //           borderSide: BorderSide(
              //       //               color: Colors.grey
              //       //           )
              //       //       )),
              //       // )
              //     ),
              //   ],
              // ),

              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 5,
                  ),
                  Text("SEQ NO")
                ],
              ),
              IgnorePointer(
                child: Container(
                  child: TextFormField(
                    validator: (value) => value!.isEmpty ? 'Required *' : null,
                    controller: documentNoController,
                    decoration: InputDecoration(
                        focusedBorder: APPConstants().focusInputBorder,
                        enabledBorder: APPConstants().enableInputBorder,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            left: 10.0, bottom: 10.0, top: 10.0),
                        // hintText: "TOIN -Next Doc No",
                        labelText: "SEQ NO",
                        labelStyle: TextStyle(
                          color: !isActivateNew! == true
                              ? Colors.black26
                              : Colors.black,
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey))),
                  ),
                ),
              ),

              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 5,
                  ),
                  Text("Description")
                ],
              ),
              IgnorePointer(
                  ignoring: isActivated!,
                  child: Container(
                    child: TextFormField(
                      validator: (value) =>
                          value!.isEmpty ? 'Required *' : null,
                      controller: descriptionController,
                      decoration: InputDecoration(
                          focusedBorder: APPConstants().focusInputBorder,
                          enabledBorder: APPConstants().enableInputBorder,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                              left: 10.0, bottom: 10.0, top: 10.0),
                          // hintText: "TOIN -Next Doc No",
                          labelStyle: TextStyle(color: Colors.black26),
                          labelText: "Description",
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey))),
                    ),
                  )),
              SizedBox(
                height: 10,
              ),

              Visibility(
                visible: widget.type == "GRN" ||
                    widget.type == "RP" ||
                    widget.type == "TO-OUT" ||
                    widget.type == "TO-IN" ||
                    widget.type == "ST",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 5,
                    ),
                    Text("ERP-DOCNO")
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Visibility(
                visible: widget.type == "GRN" ||
                    widget.type == "RP" ||
                    widget.type == "TO-OUT" ||
                    widget.type == "TO-IN" ||
                    widget.type == "ST",
                child: orderNos.isEmpty
                    ? Row(
                        children: [
                          Expanded(
                              child: Container(
                            height: 35,

                            // margin: EdgeInsets.only(left: 13),
                            child: Center(
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    selectOrder ?? "Select ERP DOCNO",
                                    style: TextStyle(
                                        color: !isActivateNew! == true
                                            ? Colors.black26
                                            : Colors.black,
                                        fontSize: 15),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  )
                                ],
                              ),
                            ),
                            decoration: BoxDecoration(
                                color:
                                    // isActivated != null && isActivated!
                                    //     ? Colors.black12:
                                    Colors.white,
                                border:
                                    Border.all(color: Colors.black, width: 0.5),
                                borderRadius: BorderRadius.circular(10.0)),
                          )),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: IgnorePointer(
                              ignoring: isActivated!,
                              child: Container(
                                height: 35,
                                color: !isActivateNew! == true
                                    ? Colors.black12
                                    : Colors.white,
                                // margin: EdgeInsets.symmetric(horizontal: 2),
                                child: new Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: Colors.white,
                                    // backgroundColor: Colors.black26,
                                    // cardColor: Colors.black12
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                      dropdownMaxHeight: 400,
                                      // underline: Divider(
                                      //   // indent: 2,
                                      //
                                      //   height: 1,
                                      //   thickness: 1,
                                      //   color: Colors.black,
                                      // ),
                                      barrierDismissible: true,
                                      // disabledHint: false,
                                      isExpanded: true,
                                      buttonHeight: 500,

                                      hint: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Order No ...',
                                              style: TextStyle(
                                                // fontSize: 14,
                                                // fontWeight: FontWeight.bold,
                                                color: Colors.black12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),

                                      items: orderNos
                                          .map((item) =>
                                              DropdownMenuItem<String>(
                                                value:
                                                    item['AXDOCNO']?.toString(),
                                                child: Text(
                                                  item['AXDOCNO'] ?? "",
                                                  style: TextStyle(
                                                    // fontSize: 14,
                                                    // fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ))
                                          .toList(),
                                      value: selectOrder,
                                      onChanged: (value) {
                                        setState(() {
                                          selectOrder = value as String;
                                        });
                                      },
                                      icon: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 13.0),
                                        child: Icon(
                                          Icons.arrow_forward_ios_outlined,
                                        ),
                                      ),
                                      iconSize: 14,

                                      buttonDecoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.black38, width: 0.5),
                                        // color: isActivated != null && isActivated!
                                        //     ? Colors.black12:
                                        // Colors.white,
                                      ),

                                      buttonElevation: 0,

                                      dropdownDecoration: BoxDecoration(
                                        border: Border.all(
                                          // style: BorderStyle.none,
                                          width: 0.2,
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        // color: Colors.white,
                                      ),
                                      dropdownElevation: 0,
                                      scrollbarRadius: Radius.circular(40),
                                      scrollbarThickness: 6,

                                      scrollbarAlwaysShow: true,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // TextFormField(
                            //
                            //   validator: (value) =>
                            //   value!.isEmpty ? 'Required *' : null,
                            //   controller: deviceIdController,
                            //   decoration: InputDecoration(
                            //     isDense: true,
                            //     contentPadding: EdgeInsets.only(left: 10.0),
                            //       fillColor: Colors.white,
                            //       focusColor: Colors.white,
                            //       labelText: "Device ID",
                            //       border: UnderlineInputBorder(
                            //
                            //           borderSide: BorderSide(
                            //               color: Colors.grey
                            //           )
                            //       )),
                            // )
                          ),
                        ],
                      ),
              ),

              // SizedBox(height: 20,),
              Visibility(
                visible: transactionData.isNotEmpty,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          if (!isActivateNew! && isActivateSave!) {
                            showDialogGotData("Transaction Not Found");
                          } else {
                            showDialogMessage(context);
                          }
                        },
                        icon: Icon(
                          Icons.delete_forever_outlined,
                          size: 35,
                          color: Colors.red,
                        )),
                  ],
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: IgnorePointer(
                      ignoring: isActivateNew!,
                      child: TextButton(
                          style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              backgroundColor: Colors.green),
                          onPressed: () async {
                            await getOrderNos();
                            transactionData = await _sqlHelper.getTRANSHEADER(
                                widget.type == 'ST'
                                    ? "1"
                                    : widget.type == 'PO'
                                        ? "3"
                                        : widget.type == 'GRN'
                                            ? "4"
                                            : widget.type == 'RO'
                                                ? "9"
                                                : widget.type == 'RP'
                                                    ? "10"
                                                    : widget.type == 'TO'
                                                        ? "11"
                                                        : widget.type ==
                                                                "TO-OUT"
                                                            ? "5"
                                                            : widget.type ==
                                                                    "TO-IN"
                                                                ? "6"
                                                                : widget.type ==
                                                                        "MJ"
                                                                    ? "22"
                                                                    : "");
                            print("isActivateNew : new ");
                            int i = 1050000;

                            int length = i.toString().length; // 7
// or
                            print(length.toString());
                            await getOrderNos();

                            if (widget.type == "ST") {
                              print(APPGENERALDATASave['STNEXTDOCNO']
                                  .runtimeType);
                              if (APPGENERALDATASave['STNEXTDOCNO'] >= 0 &&
                                  APPGENERALDATASave['STNEXTDOCNO'] <= 9) {
                                docNo =
                                    "000${APPGENERALDATASave['STNEXTDOCNO']}";
                              }
                              if (APPGENERALDATASave['STNEXTDOCNO'] >= 10 &&
                                  APPGENERALDATASave['STNEXTDOCNO'] <= 99) {
                                docNo =
                                    "00${APPGENERALDATASave['STNEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['STNEXTDOCNO'] >= 100 &&
                                  APPGENERALDATASave['STNEXTDOCNO'] <= 999) {
                                docNo = "0${APPGENERALDATASave['STNEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['STNEXTDOCNO'] >= 1000) {
                                docNo = "${APPGENERALDATASave['STNEXTDOCNO']}";
                              }

                              documentNoController?.text =
                                  "${widget.type}-${activatedDevice}-${docNo ?? ""}";
                              print(documentNoController?.text);
                              setState(() {
                                isActivated = false;
                                isActivateNew = true;
                                isActivateSave = false;
                              });
                            }

                            if (widget.type == "PO") {
                              print(APPGENERALDATASave['PONEXTDOCNO']
                                  .runtimeType);
                              print(APPGENERALDATASave['PONEXTDOCNO']);
                              print("1310 ....");
                              if (APPGENERALDATASave['PONEXTDOCNO'] >= 0 &&
                                  APPGENERALDATASave['PONEXTDOCNO'] <= 9) {
                                docNo =
                                    "000${APPGENERALDATASave['PONEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['PONEXTDOCNO'] >= 10 &&
                                  APPGENERALDATASave['PONEXTDOCNO'] <= 99) {
                                docNo =
                                    "00${APPGENERALDATASave['PONEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['PONEXTDOCNO'] >= 100 &&
                                  APPGENERALDATASave['PONEXTDOCNO'] <= 999) {
                                docNo = "0${APPGENERALDATASave['PONEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['PONEXTDOCNO'] >= 1000) {
                                docNo = "${APPGENERALDATASave['PONEXTDOCNO']}";
                              }

                              documentNoController?.text =
                                  "${widget.type}-${activatedDevice}-${docNo ?? ""}";
                              print(documentNoController?.text);
                              setState(() {
                                isActivated = false;
                                isActivateNew = true;
                                isActivateSave = false;
                              });
                            }

                            if (widget.type == "GRN") {
                              print(APPGENERALDATASave['GRNNEXTDOCNO']
                                  .runtimeType);
                              if (APPGENERALDATASave['GRNNEXTDOCNO'] >= 0 &&
                                  APPGENERALDATASave['GRNNEXTDOCNO'] <= 9) {
                                docNo =
                                    "000${APPGENERALDATASave['GRNNEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['GRNNEXTDOCNO'] >= 10 &&
                                  APPGENERALDATASave['GRNNEXTDOCNO'] <= 99) {
                                docNo =
                                    "00${APPGENERALDATASave['GRNNEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['GRNNEXTDOCNO'] >= 100 &&
                                  APPGENERALDATASave['GRNNEXTDOCNO'] <= 999) {
                                docNo =
                                    "0${APPGENERALDATASave['GRNNEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['GRNNEXTDOCNO'] >= 1000) {
                                docNo = "${APPGENERALDATASave['GRNNEXTDOCNO']}";
                              }

                              documentNoController?.text =
                                  "${widget.type}-${activatedDevice}-${docNo ?? ""}";
                              print(documentNoController?.text);
                              setState(() {
                                isActivated = false;
                                isActivateNew = true;
                                isActivateSave = false;
                              });
                            }

                            if (widget.type == "RO") {
                              print(APPGENERALDATASave['RONEXTDOCNO']
                                  .runtimeType);
                              print(APPGENERALDATASave['RONEXTDOCNO']);
                              print("1310 ....");
                              if (APPGENERALDATASave['RONEXTDOCNO'] >= 0 &&
                                  APPGENERALDATASave['RONEXTDOCNO'] <= 9) {
                                docNo =
                                    "000${APPGENERALDATASave['RONEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['RONEXTDOCNO'] >= 10 &&
                                  APPGENERALDATASave['RONEXTDOCNO'] <= 99) {
                                docNo =
                                    "00${APPGENERALDATASave['RONEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['RONEXTDOCNO'] >= 100 &&
                                  APPGENERALDATASave['RONEXTDOCNO'] <= 999) {
                                docNo = "0${APPGENERALDATASave['RONEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['RONEXTDOCNO'] >= 1000) {
                                docNo = "${APPGENERALDATASave['RONEXTDOCNO']}";
                              }

                              documentNoController?.text =
                                  "${widget.type}-${activatedDevice}-${docNo ?? ""}";
                              print(documentNoController?.text);
                              setState(() {
                                isActivated = false;
                                isActivateNew = true;
                                isActivateSave = false;
                              });
                            }

                            if (widget.type == "RP") {
                              print(APPGENERALDATASave['RPNEXTDOCNO']
                                  .runtimeType);
                              print(APPGENERALDATASave['RPNEXTDOCNO']);
                              print("1310 ....");
                              if (APPGENERALDATASave['RPNEXTDOCNO'] >= 0 &&
                                  APPGENERALDATASave['RPNEXTDOCNO'] <= 9) {
                                docNo =
                                    "000${APPGENERALDATASave['RPNEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['RPNEXTDOCNO'] >= 10 &&
                                  APPGENERALDATASave['RPNEXTDOCNO'] <= 99) {
                                docNo =
                                    "00${APPGENERALDATASave['RPNEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['RPNEXTDOCNO'] >= 100 &&
                                  APPGENERALDATASave['RPNEXTDOCNO'] <= 999) {
                                docNo = "0${APPGENERALDATASave['RPNEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['RPNEXTDOCNO'] >= 1000) {
                                docNo = "${APPGENERALDATASave['RPNEXTDOCNO']}";
                              }

                              documentNoController?.text =
                                  "${widget.type}-${activatedDevice}-${docNo ?? ""}";
                              print(documentNoController?.text);
                              setState(() {
                                isActivated = false;
                                isActivateNew = true;
                                isActivateSave = false;
                              });
                            }

                            if (widget.type == "MJ") {
                              print(APPGENERALDATASave['MJNEXTDOCNO']
                                  .runtimeType);
                              print(APPGENERALDATASave['MJNEXTDOCNO']);
                              print("1310 ....");
                              if (APPGENERALDATASave['MJNEXTDOCNO'] >= 0 &&
                                  APPGENERALDATASave['MJNEXTDOCNO'] <= 9) {
                                docNo =
                                    "000${APPGENERALDATASave['MJNEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['MJNEXTDOCNO'] >= 10 &&
                                  APPGENERALDATASave['MJNEXTDOCNO'] <= 99) {
                                docNo =
                                    "00${APPGENERALDATASave['MJNEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['MJNEXTDOCNO'] >= 100 &&
                                  APPGENERALDATASave['MJNEXTDOCNO'] <= 999) {
                                docNo = "0${APPGENERALDATASave['MJNEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['MJNEXTDOCNO'] >= 1000) {
                                docNo = "${APPGENERALDATASave['MJNEXTDOCNO']}";
                              }

                              documentNoController?.text =
                                  "${widget.type}-${activatedDevice}-${docNo ?? ""}";
                              print(documentNoController?.text);
                            await   getMovementJournal();
                              setState(() {
                                isActivated = false;
                                isActivateNew = true;
                                isActivateSave = false;
                              });
                            }

                            if (widget.type == "TO") {
                              print(APPGENERALDATASave['TONEXTDOCNO']
                                  .runtimeType);
                              print(APPGENERALDATASave['TONEXTDOCNO']);
                              print("1310 ....");
                              if (APPGENERALDATASave['TONEXTDOCNO'] >= 0 &&
                                  APPGENERALDATASave['TONEXTDOCNO'] <= 9) {
                                docNo =
                                    "000${APPGENERALDATASave['TONEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['TONEXTDOCNO'] >= 10 &&
                                  APPGENERALDATASave['TONEXTDOCNO'] <= 99) {
                                docNo =
                                    "00${APPGENERALDATASave['TONEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['TONEXTDOCNO'] >= 100 &&
                                  APPGENERALDATASave['TONEXTDOCNO'] <= 999) {
                                docNo = "0${APPGENERALDATASave['TONEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['TONEXTDOCNO'] >= 1000) {
                                docNo = "${APPGENERALDATASave['TONEXTDOCNO']}";
                              }

                              documentNoController?.text =
                                  "${widget.type}-${activatedDevice}-${docNo ?? ""}";
                              print(documentNoController?.text);
                              setState(() {
                                isActivated = false;
                                isActivateNew = true;
                                isActivateSave = false;
                              });
                            }

                            if (widget.type == "TO-OUT") {
                              print(APPGENERALDATASave['TOOUTNEXTDOCNO']
                                  .runtimeType);
                              print(APPGENERALDATASave['TOOUTNEXTDOCNO']);
                              print("1310 ....");
                              if (APPGENERALDATASave['TOOUTNEXTDOCNO'] >= 0 &&
                                  APPGENERALDATASave['TOOUTNEXTDOCNO'] <= 9) {
                                docNo =
                                    "000${APPGENERALDATASave['TOOUTNEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['TOOUTNEXTDOCNO'] >= 10 &&
                                  APPGENERALDATASave['TOOUTNEXTDOCNO'] <= 99) {
                                docNo =
                                    "00${APPGENERALDATASave['TOOUTNEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['TOOUTNEXTDOCNO'] >= 100 &&
                                  APPGENERALDATASave['TOOUTNEXTDOCNO'] <= 999) {
                                docNo =
                                    "0${APPGENERALDATASave['TOOUTNEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['TOOUTNEXTDOCNO'] >=
                                  1000) {
                                docNo =
                                    "${APPGENERALDATASave['TOOUTNEXTDOCNO']}";
                              }

                              documentNoController?.text =
                                  "${widget.type}-${activatedDevice}-${docNo ?? ""}";
                              print(documentNoController?.text);
                              setState(() {
                                isActivated = false;
                                isActivateNew = true;
                                isActivateSave = false;
                              });
                            }

                            if (widget.type == "TO-IN") {
                              print(APPGENERALDATASave['TOINNEXTDOCNO']
                                  .runtimeType);
                              print(APPGENERALDATASave['TOINNEXTDOCNO']);
                              print("1310 ....");
                              if (APPGENERALDATASave['TOINNEXTDOCNO'] >= 0 &&
                                  APPGENERALDATASave['TOINNEXTDOCNO'] <= 9) {
                                docNo =
                                    "000${APPGENERALDATASave['TOINNEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['TOINNEXTDOCNO'] >= 10 &&
                                  APPGENERALDATASave['TOINNEXTDOCNO'] <= 99) {
                                docNo =
                                    "00${APPGENERALDATASave['TOINNEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['TOINNEXTDOCNO'] >= 100 &&
                                  APPGENERALDATASave['TOINNEXTDOCNO'] <= 999) {
                                docNo =
                                    "0${APPGENERALDATASave['TOINNEXTDOCNO']}";
                              }

                              if (APPGENERALDATASave['TOINNEXTDOCNO'] >= 1000) {
                                docNo =
                                    "${APPGENERALDATASave['TOINNEXTDOCNO']}";
                              }

                              documentNoController?.text =
                                  "${widget.type}-${activatedDevice}-${docNo ?? ""}";
                              print(documentNoController?.text);
                              setState(() {
                                isActivated = false;
                                isActivateNew = true;
                                isActivateSave = false;
                              });
                            }
                          },
                          child: Text(
                            "NEW",
                            style: TextStyle(
                                color: !isActivateNew! == true
                                    ? Colors.white
                                    : APPConstants().colorGreen),
                          )),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: IgnorePointer(
                    ignoring: isActivateSave!,
                    child: TextButton(
                        style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            backgroundColor: Colors.green),
                        onPressed: () async {
                          if (selectOrder == "" ||
                              selectOrder == null &&
                                  widget.type != "PO" &&
                                  widget.type != "RO" &&
                                  widget.type != "TO" &&
                                  widget.type != "MJ") {
                            showDialogGotData("Select ERP:Document No ");
                            return;
                          }
                          if (selectLocation == "" ||
                              selectLocation == null &&
                                  widget.type != "PO" &&
                                  widget.type != 'GRN' &&
                                  widget.type != "RO" &&
                                  widget.type != "RP" &&
                                  widget.type != "TO" &&
                                  widget.type != "TO-OUT" &&
                                  widget.type != "TO-IN" &&
                                  widget.type != "MJ") {
                            showDialogGotData("Select Location");
                            return;
                          }
                          if (widget.type == "TO") {
                            if (selectStore == null) {
                              showDialogGotData("Select Store Code ");
                              return;
                            }
                            // showDialogGotData("Select ERP:Document No ");
                            // return;
                          }

                          if (widget.type == "MJ") {
                            if (selectJournal == null) {
                              showDialogGotData("Select Movement Journal");
                              return;
                            }

                            // return;
                          }

                          print("isActivateNew : save ");
                          setState(() {
                            isActivateSave = true;
                            isActivateNew = false;
                          });
                          // 1- Counting                 2- Item master   ,
                          //  3 - Open Purchase order lines
                          // 4- Invoiced Purchase lines

                          if (widget.type == 'ST') {
                            await _sqlHelper.addTRANSHEADER(
                                DOCNO: documentNoController?.text,
                                AXDOCNO: selectOrder,
                                STORECODE: activatedStore,
                                TOSTORECODE:
                                    widget.type == "TO" ? selectStore : "",
                                TRANSTYPE: widget.type == "ST"
                                    ? 1
                                    : widget.type == "PO"
                                        ? 3
                                        : widget.type == 'GRN'
                                            ? 4
                                            : "",
                                STATUS: 1,
                                USERNAME: username,
                                DESCRIPTION: descriptionController?.text,
                                CREATEDDATE: DateTime.now().toString(),
                                DATAAREAID: companyCode,
                                DEVICEID: activatedDevice,
                                TYPEDESCR: widget.type,
                                JournalName:
                                    widget.type == "MJ" ? selectJournal : "",
                                VRLOCATION: selectLocation);
                            await _sqlHelper.updateAPPGENERALDATASTNEXTDOCNO(
                                APPGENERALDATASave['STNEXTDOCNO'] + 1);
                          }

                          if (widget.type == 'PO') {
                            await _sqlHelper.addTRANSHEADER(
                                DOCNO: documentNoController?.text,
                                AXDOCNO: "",
                                STORECODE: activatedStore,
                                TOSTORECODE:
                                    widget.type == "TO" ? selectStore : "",
                                TRANSTYPE: widget.type == "ST"
                                    ? 1
                                    : widget.type == "PO"
                                        ? 3
                                        : widget.type == 'GRN'
                                            ? 4
                                            : "",
                                STATUS: 1,
                                USERNAME: username,
                                DESCRIPTION: descriptionController?.text,
                                CREATEDDATE: DateTime.now().toString(),
                                DATAAREAID: companyCode,
                                DEVICEID: activatedDevice,
                                TYPEDESCR: widget.type,
                                JournalName:
                                    widget.type == "MJ" ? selectJournal : "",
                                VRLOCATION: "");
                            await _sqlHelper.updateAPPGENERALDATAPONEXTDOCNO(
                                APPGENERALDATASave['PONEXTDOCNO'] + 1);
                          }

                          if (widget.type == 'GRN') {
                            await _sqlHelper.addTRANSHEADER(
                                DOCNO: documentNoController?.text,
                                AXDOCNO: selectOrder,
                                STORECODE: activatedStore,
                                TOSTORECODE:
                                    widget.type == "TO" ? selectStore : "",
                                TRANSTYPE: widget.type == "ST"
                                    ? 1
                                    : widget.type == "PO"
                                        ? 3
                                        : widget.type == 'GRN'
                                            ? 4
                                            : "",
                                STATUS: 1,
                                USERNAME: username,
                                DESCRIPTION: descriptionController?.text,
                                CREATEDDATE: DateTime.now().toString(),
                                DATAAREAID: companyCode,
                                DEVICEID: activatedDevice,
                                TYPEDESCR: widget.type,
                                JournalName:
                                    widget.type == "MJ" ? selectJournal : "",
                                VRLOCATION: "");
                            await _sqlHelper.updateAPPGENERALDATAGRNNEXTDOCNO(
                                APPGENERALDATASave['GRNNEXTDOCNO'] + 1);
                          }

                          if (widget.type == 'RO') {
                            await _sqlHelper.addTRANSHEADER(
                                DOCNO: documentNoController?.text,
                                AXDOCNO: "",
                                STORECODE: activatedStore,
                                TOSTORECODE:
                                    widget.type == "TO" ? selectStore : "",
                                TRANSTYPE: widget.type == "ST"
                                    ? 1
                                    : widget.type == "PO"
                                        ? 3
                                        : widget.type == 'GRN'
                                            ? 4
                                            : widget.type == 'RO'
                                                ? 9
                                                : "",
                                STATUS: 1,
                                USERNAME: username,
                                DESCRIPTION: descriptionController?.text,
                                CREATEDDATE: DateTime.now().toString(),
                                DATAAREAID: companyCode,
                                DEVICEID: activatedDevice,
                                TYPEDESCR: widget.type,
                                JournalName:
                                    widget.type == "MJ" ? selectJournal : "",
                                VRLOCATION: "");
                            await _sqlHelper.updateAPPGENERALDATARONEXTDOCNO(
                                APPGENERALDATASave['RONEXTDOCNO'] + 1);
                          }

                          if (widget.type == 'RP') {
                            await _sqlHelper.addTRANSHEADER(
                                DOCNO: documentNoController?.text,
                                AXDOCNO: selectOrder,
                                STORECODE: activatedStore,
                                TOSTORECODE:
                                    widget.type == "TO" ? selectStore : "",
                                TRANSTYPE: widget.type == "ST"
                                    ? 1
                                    : widget.type == "PO"
                                        ? 3
                                        : widget.type == 'GRN'
                                            ? 4
                                            : widget.type == 'RO'
                                                ? 9
                                                : widget.type == 'RP'
                                                    ? 10
                                                    : "",
                                STATUS: 1,
                                USERNAME: username,
                                DESCRIPTION: descriptionController?.text,
                                CREATEDDATE: DateTime.now().toString(),
                                DATAAREAID: companyCode,
                                DEVICEID: activatedDevice,
                                TYPEDESCR: widget.type,
                                JournalName:
                                    widget.type == "MJ" ? selectJournal : "",
                                VRLOCATION: "");
                            await _sqlHelper.updateAPPGENERALDATARPNEXTDOCNO(
                                APPGENERALDATASave['RPNEXTDOCNO'] + 1);
                          }

                          if (widget.type == 'MJ') {
                            await _sqlHelper.addTRANSHEADER(
                                DOCNO: documentNoController?.text,
                                AXDOCNO: "",
                                STORECODE: activatedStore,
                                TOSTORECODE:
                                    widget.type == "TO" ? selectStore : "",
                                TRANSTYPE: 22,
                                STATUS: 1,
                                USERNAME: username,
                                DESCRIPTION: descriptionController?.text,
                                CREATEDDATE: DateTime.now().toString(),
                                DATAAREAID: companyCode,
                                DEVICEID: activatedDevice,
                                TYPEDESCR: widget.type,
                                JournalName:
                                    widget.type == "MJ" ? selectJournal : "",
                                VRLOCATION: "");
                            await _sqlHelper.updateAPPGENERALDATAMJNEXTDOCNO(
                                APPGENERALDATASave['MJNEXTDOCNO'] + 1);
                          }

                          if (widget.type == 'TO') {
                            await _sqlHelper.addTRANSHEADER(
                                DOCNO: documentNoController?.text,
                                AXDOCNO: "",
                                STORECODE: activatedStore,
                                TOSTORECODE:
                                    widget.type == "TO" ? selectStore : "",
                                TRANSTYPE: widget.type == "ST"
                                    ? 1
                                    : widget.type == "PO"
                                        ? 3
                                        : widget.type == 'GRN'
                                            ? 4
                                            : widget.type == 'RO'
                                                ? 9
                                                : widget.type == 'RP'
                                                    ? 10
                                                    : widget.type == 'TO'
                                                        ? 11
                                                        : "",
                                STATUS: 1,
                                USERNAME: username,
                                DESCRIPTION: descriptionController?.text,
                                CREATEDDATE: DateTime.now().toString(),
                                DATAAREAID: companyCode,
                                DEVICEID: activatedDevice,
                                TYPEDESCR: widget.type,
                                JournalName:
                                    widget.type == "MJ" ? selectJournal : "",
                                VRLOCATION: "");
                            await _sqlHelper.updateAPPGENERALDATATONEXTDOCNO(
                                APPGENERALDATASave['TONEXTDOCNO'] + 1);
                          }
                          // documentNoController?.clear();
                          // descriptionController?.clear();
                          // selectLocation=null;
                          // selectOrder=null;
                          // selectStore=null;

                          if (widget.type == 'TO-OUT' ||
                              widget.type == "TO-IN") {
                            await _sqlHelper.addTRANSHEADER(
                                DOCNO: documentNoController?.text,
                                AXDOCNO: selectOrder,
                                STORECODE: activatedStore,
                                TOSTORECODE:
                                    widget.type == "TO" ? selectStore : "",
                                TRANSTYPE: widget.type == "ST"
                                    ? 1
                                    : widget.type == "PO"
                                        ? 3
                                        : widget.type == 'GRN'
                                            ? 4
                                            : widget.type == 'RO'
                                                ? 9
                                                : widget.type == 'RP'
                                                    ? 10
                                                    : widget.type == 'TO'
                                                        ? 11
                                                        : widget.type ==
                                                                "TO-OUT"
                                                            ? 5
                                                            : widget.type ==
                                                                    "TO-IN"
                                                                ? 6
                                                                : "",
                                STATUS: 1,
                                USERNAME: username,
                                DESCRIPTION: descriptionController?.text,
                                CREATEDDATE: DateTime.now().toString(),
                                DATAAREAID: companyCode,
                                DEVICEID: activatedDevice,
                                TYPEDESCR: widget.type,
                                JournalName:
                                    widget.type == "MJ" ? selectJournal : "",
                                VRLOCATION: "");
                            if (widget.type == "TO-OUT") {
                              await _sqlHelper
                                  .updateAPPGENERALDATATOOUTNEXTDOCNO(
                                      APPGENERALDATASave['TOOUTNEXTDOCNO'] + 1);
                            } else {
                              await _sqlHelper
                                  .updateAPPGENERALDATATOINNEXTDOCNO(
                                      APPGENERALDATASave['TOINNEXTDOCNO'] + 1);
                            }
                          }
                          transactionData = await _sqlHelper.getTRANSHEADER(
                              widget.type == 'ST'
                                  ? "1"
                                  : widget.type == 'PO'
                                      ? "3"
                                      : widget.type == 'GRN'
                                          ? "4"
                                          : widget.type == 'RO'
                                              ? "9"
                                              : widget.type == 'RP'
                                                  ? "10"
                                                  : widget.type == 'TO'
                                                      ? "11"
                                                      : widget.type == "TO-OUT"
                                                          ? "5"
                                                          : widget.type ==
                                                                  "TO-IN"
                                                              ? "6"
                                                              : widget.type ==
                                                                      "MJ"
                                                                  ? "22"
                                                                  : "");

                          setState(() {
                            isActivated = true;
                            isActivateSave = true;
                            isActivateNew = true;
                          });
                        }
                        //     widget.type=="TO-OUT" ? "5":
                        // widget.type=="TO-IN" ? "6":
                        ,
                        child: Text(
                          "SAVE",
                          style: TextStyle(
                              color: !isActivateSave! == true
                                  ? Colors.white
                                  : APPConstants().colorGreen),
                        )),
                  )),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: IgnorePointer(
                    ignoring: !isCloseTransactions!,
                    child: TextButton(
                        style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            // backgroundColor:  Color(0xffed648e)
                            backgroundColor: Colors.red),
                        onPressed: () async {
                          await _sqlHelper.updateStatusStockCount(
                              2,
                              documentNoController?.text.trim() ?? "",
                              widget.type == 'ST'
                                  ? "1"
                                  : widget.type == 'PO'
                                      ? "3"
                                      : widget.type == 'GRN'
                                          ? "4"
                                          : widget.type == 'RO'
                                              ? "9"
                                              : widget.type == 'RP'
                                                  ? "10"
                                                  : widget.type == 'TO'
                                                      ? "11"
                                                      : widget.type == "TO-OUT"
                                                          ? "5"
                                                          : widget.type ==
                                                                  "TO-IN"
                                                              ? "6"
                                                              : "",
                              selectOrder);
                          if (transactionDetails.length > 0) {
                            isPostTransactions = true;
                            isCloseTransactions = false;
                            setState(() {});
                          }
                        },
                        child: Text(
                          "CLOSE TRANSACTION",
                          style: TextStyle(
                              color: !isCloseTransactions!
                                  ? APPConstants().disabledRed
                                  : Colors.white),
                        )),
                  )),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: IgnorePointer(
                    ignoring: !isPostTransactions!,
                    child: TextButton(
                        style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            backgroundColor: Colors.red
                            // Color(0xffed648e)
                            ),
                        onPressed: () async {
                          if (_connectionStatus == ConnectivityResult.none) {
                            print("Internet connection false 431");

                            showDialogGotData("No Internet Connection");

                            // ScaffoldMessenger.of(context).showSnackBar(
                            //
                            //   const SnackBar(
                            //     duration:Duration(seconds: 2) ,
                            //     backgroundColor: Colors.red,
                            //       content: Text(
                            //         'No Internet Connection',
                            //         textAlign: TextAlign.center,
                            //       )),
                            // );

                            // Navigator.pop(context);

                            return;
                          }

                          showDialogGotDataPost(
                              "Do You Want to Post This Transaction ? ");

                          print("post transactions");
                        },
                        child: Text(
                          "POST TRANSACTION",
                          style: TextStyle(
                              color: !isPostTransactions!
                                  ? APPConstants().disabledRed
                                  : Colors.white),
                        )),
                  )),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: TextButton(
                          style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              backgroundColor: Colors.orangeAccent),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LandingHomePage()));
                          },
                          child: Text(
                            "HOME",
                            style: TextStyle(color: Colors.white),
                          ))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  showDialogGotDataPost(String text) {
    // set up the button
    Widget yesButton = TextButton(
      style: APPConstants().btnBackgroundYes,
      child: Text("Yes", style: APPConstants().YesText),
      onPressed: () {
        pushTransactionToPost();

        setState(() {});
        Navigator.pop(context);
      },
    );
    //
    //
    //
    Widget noButton = TextButton(
      style: APPConstants().btnBackgroundNo,
      child: Text("No", style: APPConstants().bodyText),
      onPressed: () {
        print("Scanning code");
        setState(() {});
        Navigator.pop(context);
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

  showDialogMessage(context) {
    // print(onpress);
    // return;
    showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("DynamicsConnect"),
            content: Text("Are You Sure to Delete this transaction ?"),
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
                child: Text("Yes", style: APPConstants().YesText),
                onPressed: () async {
                  Navigator.pop(context);

                  await _sqlHelper.deleteTRANSHEADER(
                      documentNoController?.text,
                      widget.type == 'ST'
                          ? "1"
                          : widget.type == 'PO'
                              ? "3"
                              : widget.type == 'GRN'
                                  ? "4"
                                  : widget.type == 'RO'
                                      ? "9"
                                      : widget.type == 'RP'
                                          ? "10"
                                          : widget.type == 'TO'
                                              ? "11"
                                              : widget.type == 'MJ'
                                                  ? "22"
                                                  : "");

                  setState(() {
                    isActivated = false;
                    // isActivateNew = true;
                    // isActivateSave = false;
                    movementJournals=[];
                    selectJournal = null;
                    selectStore = null;
                    selectLocation = null;
                    documentNoController?.clear();
                    descriptionController?.clear();
                    selectOrder = null;
                    isActivateNew = false;
                    isActivateSave = true;
                  });

                  await prefs!.setBool("lineDeleted", true);
                  showDialogGotData("Transaction Deleted");
                  getOrderNos();
                  // Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  getMovementJournal() async {
    var tk = 'Bearer ${token.toString()}';
    Map<String, String> headers = {
      "Content-type": "application/json",
      'Authorization': tk
    };
    var body = {
      "dataAreaId": "$companyCode" // 1 - to get only counting journal lines
    };
    // var ur = APIConstants.baseUrl + "pushTransactionTatmeen";
    // var ur = "$getMovementJournals";

    var ur =
        "https://hsins28ce7a8bf606d8744bdevaos.axcloud.dynamics.com/api/services/CustomServiceGroup/CustomService/getJournalName";
    print(ur);
    var js = json.encode(body);
    var res = await http.post(headers: headers, Uri.parse(ur), body: js);
    var responseJson = json.decode(res.body);
    // print(responseJson);

    if (res.statusCode == 200 || res.statusCode == 201) {


      print("got it device movement journal");

      setState(() {
        movementJournals = responseJson[0]['InventJourName'];

      });


    }
  }
}
