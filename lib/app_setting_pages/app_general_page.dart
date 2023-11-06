import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dynamicconnectapp/helper/local_db.dart';
import 'package:dynamicconnectapp/common_pages/login_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../constants/constant.dart';
import '../common_pages/home_page.dart';

class AppGeneralPage extends StatefulWidget {
  AppGeneralPage({Key? key}) : super(key: key);

  @override
  State<AppGeneralPage> createState() => _AppGeneralPageState();
}

class _AppGeneralPageState extends State<AppGeneralPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectDevice;
  String? selectStore;
  List<dynamic> homeList = [];
  TextEditingController PONextDocNoController = TextEditingController();
  TextEditingController storeCodeController = TextEditingController();
  TextEditingController deviceIdController = TextEditingController();

  TextEditingController GRNNextDocNoController = TextEditingController();

  TextEditingController TOINNextDocNoController = TextEditingController();
  TextEditingController TOOutNextDocNoController = TextEditingController();
  TextEditingController TONextDocNoController = TextEditingController();

  TextEditingController STNextDocNoController = TextEditingController();
  TextEditingController RPNextDocNoController = TextEditingController();
  TextEditingController RONextDocNoController = TextEditingController();

  TextEditingController MJNextDocNoController = TextEditingController();

  bool disabledCamera = false;
  bool disabledUOMSelection = false;
  bool disabledContinuosScan = false;

  bool  ? showDimension= false;

  bool ? showQuantityExceed= false;


  final SQLHelper _sqlHelper = SQLHelper();
  bool? isLoad = true;



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
    getToken();
    listenStatusValues();
    setValues();

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
  var token;
  List<dynamic> stores = [];
  List<dynamic> devices = [];
  List<dynamic> getApiResponse = [];

  bool? isActivated;
  TextEditingController confirmPasswordController = TextEditingController();


  getDevices() async {
    var tk = 'Bearer ${token.toString()}';
    Map<String, String> headers = {
      "Content-type": "application/json",
      'Authorization': tk
    };
    var body = {"dataAreaId": "$companyCode"};
    // var ur = APIConstants.baseUrl + "pushTransactionTatmeen";
    var ur = "$getDevice";
    print(ur);
    var js = json.encode(body);
    var res;
    var responseJson;

    try{
   js = json.encode(body);
    res = await http.post(headers: headers, Uri.parse(ur), body: js);
   responseJson = json.decode(res.body);
    }
    catch(e){
      showDialogCheck("Error : ${e.toString()}");
      return;
    }

    print("got it device 99");
    print(responseJson);

    if (res.statusCode == 200 || res.statusCode == 201) {
      print("got it device");
      // print(selectDevice);
      print(selectStore);
      if(responseJson[0]['pullData'] == null){

        showDialogCheck("Error : ${responseJson[0]['Message']}");
        return;
      }

      setState(() {
        getApiResponse = [];
        getApiResponse = responseJson;

        devices = [];
        devices = responseJson[0]['pullData'];
        homeList = [];

        homeList.add({"type": "IMPORT DATA", "value": true});
        homeList.add({"type": "VIEW ITEMS", "value": true});

        responseJson[0]['SC'] == true
            ? homeList
                .add({"type": "STOCK COUNT", "value": responseJson[0]['SC']})
            : null;

        responseJson[0]['GRN'] == true
            ? homeList
                .add({"type": "GOODS RECEIVE", "value": responseJson[0]['GRN']})
            : null;
        responseJson[0]['PO'] == true
            ? homeList
                .add({"type": "PURCHASE ORDER", "value": responseJson[0]['PO']})
            : null;
        responseJson[0]['RO'] == true
            ? homeList
                .add({"type": "RETURN ORDER", "value": responseJson[0]['RO']})
            : null;
        responseJson[0]['RP'] == true
            ? homeList
                .add({"type": "RETURN PICK", "value": responseJson[0]['RP']})
            : null;
        responseJson[0]['TO'] == true
            ? homeList
                .add({"type": "TRANSFER ORDER", "value": responseJson[0]['TO']})
            : null;

        responseJson[0]['TOOUT'] == true
            ? homeList.add(
                {"type": "TRANSFER OUT", "value": responseJson[0]['TOOUT']})
            : null;
        responseJson[0]['TOIN'] == true
            ? homeList
                .add({"type": "TRANSFER IN", "value": responseJson[0]['TOIN']})
            : null;
        responseJson[0]['OnHand'] == true
            ? homeList
                .add({"type": "ON HAND", "value": responseJson[0]['OnHand']})
            : null;
        responseJson[0]['ItemPrice'] == true
            ? homeList.add(
                {"type": "PRICE CHECK", "value": responseJson[0]['ItemPrice']})
            : null;

        homeList.add({"type": "HISTORY", "value": true});
      });

      if (APPGENERALDATASave != null) {
        setState(() {
          selectDevice = APPGENERALDATASave['DEVICEID'];
        });
      }
    } else {
      showDialogCheck(responseJson['Message']);
    }
  }

  deactivateDevice() async {
    var tk = 'Bearer ${token.toString()}';
    Map<String, String> headers = {
      "Content-type": "application/json",
      'Authorization': tk
    };
    var body = {
      "dataAreaId": "$companyCode",
      "deviceid": "$selectDevice",
    };
    print(body);
    print(isActivated);
    print("deactivated");
    // var ur = APIConstants.baseUrl + "pushTransactionTatmeen";
    var ur = "$getDeactivate";
    print(ur);
    var js = json.encode(body);
    var res = await http.post(headers: headers, Uri.parse(ur), body: js);
    print("Status : ${res.statusCode}");
    var responseJson = json.decode(res.body);
    print(responseJson);
    if (res.statusCode == 200 || res.statusCode == 201) {
      // isActivated = false;
      print("deactivated");
      await _sqlHelper.updateAPPGENERALDATAActivate(isDeactivate: false);
      await _sqlHelper.deleteGeneralSaveHomeData();
      await listenStatusValues();

      setState(() {
        APPGENERALDATASave = null;
        isActivated = false;
        selectDevice = null;
        selectStore = null;
      });
    }
    // devices = [];
    // devices = responseJson[0]['pullData'];
  }

  showDialogGotRoute({String? text, dynamic op}) {
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

  activateDeviceOrUpdateDevice() async {
    var tk = 'Bearer ${token.toString()}';
    Map<String, String> headers = {
      "Content-type": "application/json",
      'Authorization': tk
    };

    var body = {
      "dataAreaId": "$companyCode",
      "deviceid": "$selectDevice",
      "storecode": "$selectStore"
    };

    var ur = "$updateDevice";
    print(ur);
    var js = json.encode(body);
    var res = await http.post(headers: headers, Uri.parse(ur), body: js);
    var responseJson = json.decode(res.body);
    print(responseJson);
    print("api 299 res");
    if (responseJson[0]['Message'].toString().contains("already")) {
      showDialogCheck("Details Updated");
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        showDialogGotRoute(
            op: Navigator.push(
                context, MaterialPageRoute(builder: (context) => LoginPage())),
            text: "Details Updated");
      });
      return;
    } else {
      // showDialogCheck("${responseJson[0]['Message'].toString()}");
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Navigator.push(context, MaterialPageRoute(
        //     builder: (context)=>LoginPage()));

        showDialogGotRoute(
            op: Navigator.push(
                context, MaterialPageRoute(builder: (context) => LoginPage())),
            text: "${responseJson[0]['Message'].toString()}");
      });
      setState(() {});
    }

    // devices = [];
    // devices = responseJson[0]['pullData'];
  }

  showDialogCheck(String text) {
    // set up the button
    // Widget yesButton = TextButton(
    //   child: Text("Yes"),
    //   onPressed: () {
    //     saveSettings();
    //     setState(() {
    //
    //     });
    //     Navigator.pop(context);
    //   },
    // );

    Widget noButton = TextButton(
      style: APPConstants().btnBackgroundYes,
      child: Text(
        "Ok",
        style: APPConstants().YesText,
      ),
      onPressed: () {
        print("Scanning code");
        setState(() {});
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("DynamicsConnect"),
      content: Text("$text"),
      actions: [
        noButton,
        // yesButton
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
    var js;

    var res;
    var responseJson;
    try{
      js = json.encode(body);
   res = await http.post(headers: headers,
    Uri.parse(ur), body: js);
  responseJson  = json.decode(res.body);
    }
    catch(e){
      showDialogCheck("Error :${e.toString()}");
      return;
    }
    print("Status : ${res.statusCode}");




    print(responseJson);

    if (res.statusCode == 200 || res.statusCode == 201) {
      print("got it device");
      // print(selectDevice);
      print(selectStore);
      print("got it device");
      setState(() {
        stores = [];
        stores = responseJson[0]['Stores'];
      });
      // if (APPGENERALDATASave != null) {
      //   setState(() {
      //     selectStore = APPGENERALDATASave['STORECODE'];
      //   });
      // }
    }
  }

  getToken() async {
    setState(() {});
    print("init Api");
    prefs = await SharedPreferences.getInstance();
    print("camera status");
    print(await prefs?.getString("camera"));
    disableCamera = await prefs?.getString("camera");

    var v = await prefs?.getString("camera");
    disableCamera = v.toString() == "true" ? "true" : "false";

    await prefs?.getString("disableCamera");
    disabledCamera = prefs?.getString("disableCamera") == "true" ? true : false;
    await prefs?.getString("enableUOMSelection");
    disabledUOMSelection =
        prefs?.getString("enableUOMSelection") == "true" ? true : false;
    await prefs?.getString("enableContinuousScan");
    disabledContinuosScan =
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
    getDeactivate = await prefs!.getString("deactivate");
    updateDevice = await prefs!.getString("updateDevice");
    print("...169");
    print(updateDevice);

    showDimension =    await prefs?.getBool("showDimensions") == null? false:
    await prefs?.getBool("showDimensions");

    showDimension =
    prefs?.getBool("showDimensions") == true ? true : false;

    // showQuantityExceed =
    // prefs?.getBool("showQuantityExceed") == true ? true : false;
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
      print("res.body 466");
      var dt = json.decode(res.body);
print(dt['access_token']);
      setState(() {
        token = dt['access_token'].toString();
      });


      print("The token is : "
          "$token");
      getStoreCode();
      getDevices();
      // getTatmeenDetails();
      print(token);
    } catch (e) {}
  }

  setValues() async {
    await _sqlHelper.getLastColumnAPPGENERALDATA();

    if (await _sqlHelper.getLastColumnAPPGENERALDATA() == "" ||
        await _sqlHelper.getLastColumnAPPGENERALDATA() == []) {
      print("No Data");
      PONextDocNoController.text = 1.toString();
      GRNNextDocNoController.text = 1.toString();
      TOINNextDocNoController.text = 1.toString();
      TOOutNextDocNoController.text = 1.toString();
      TONextDocNoController.text = 1.toString();

      STNextDocNoController.text = 1.toString();
      RPNextDocNoController.text = 1.toString();
      RONextDocNoController.text = 1.toString();
      MJNextDocNoController.text = 1.toString();

      setState(() {});
    } else {
      print("Found Data");
      // [
      //   {
      //     id: 1, DEVICEID: , STORECODE:
      //   AJM0070, PONEXTDOCNO: 1, GRNNEXTDOCNO: 1,
      //   RONEXTDOCNO: 1, RPNEXTDOCNO: 1,
      //   STNEXTDOCNO: 1, TONEXTDOCNO: 1,
      //     TOOUTNEXTDOCNO: 1, TOINNEXTDOCNO: 1}
      // ]

      APPGENERALDATASave = await _sqlHelper.getLastColumnAPPGENERALDATA();

      setState(() {});
      print("...248 dt");
      print(APPGENERALDATASave);

      isActivated = APPGENERALDATASave['isDeactivate'] == 1 ? true : false;
      //   "DEVICEID": DEVICEID,
      // "STORECODE": STORECODE,
      // print("Selected Device is : ${selectDevice}");

      PONextDocNoController.text = APPGENERALDATASave['PONEXTDOCNO'].toString();
      GRNNextDocNoController.text =
          APPGENERALDATASave['GRNNEXTDOCNO'].toString();
      TOINNextDocNoController.text =
          (APPGENERALDATASave['TOINNEXTDOCNO']).toString();
      TOOutNextDocNoController.text =
          APPGENERALDATASave['TOOUTNEXTDOCNO'].toString();
      TONextDocNoController.text =
          (APPGENERALDATASave['TOINNEXTDOCNO']).toString();

      STNextDocNoController.text = APPGENERALDATASave['STNEXTDOCNO'].toString();
      RPNextDocNoController.text = APPGENERALDATASave['RPNEXTDOCNO'].toString();
      RONextDocNoController.text = APPGENERALDATASave['RONEXTDOCNO'].toString();
      MJNextDocNoController.text = APPGENERALDATASave['MJNEXTDOCNO'].toString();

      selectDevice = APPGENERALDATASave['DEVICEID'].toString();
      selectStore = APPGENERALDATASave['STORECODE'].toString();
      setState(() {});
      print("Data : ${APPGENERALDATASave['STORECODE'].toString()}");
    }
  }
  

  var APPGENERALDATASave;

  listenStatusValues() async {
    await _sqlHelper.getLastColumnAPPGENERALDATA();

    if (await _sqlHelper.getLastColumnAPPGENERALDATA() == "" ||
        await _sqlHelper.getLastColumnAPPGENERALDATA() == []) {
      print("No Data");
      // isActivated = false;
    } else {
      // [
      //   {
      //     id: 1, DEVICEID: , STORECODE:
      //   AJM0070, PONEXTDOCNO: 1, GRNNEXTDOCNO: 1,
      //   RONEXTDOCNO: 1, RPNEXTDOCNO: 1,
      //   STNEXTDOCNO: 1, TONEXTDOCNO: 1,
      //     TOOUTNEXTDOCNO: 1, TOINNEXTDOCNO: 1}
      // ]

      APPGENERALDATASave = await _sqlHelper.getLastColumnAPPGENERALDATA();
      print("...248 dt");
      print(APPGENERALDATASave);

      isActivated =
          await APPGENERALDATASave['isDeactivate'] == 1 ? true : false;

      setState(() {});
      await Future.delayed(Duration(seconds: 1));
      isLoad = false;
      setState(() {});
      print("Data");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("build sudden");
    print(isActivated);
    print(selectDevice);
    return isLoad! && APPGENERALDATASave != null
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("App Version  :  ${APPConstants.appVersion}",
                    style: TextStyle(color: Colors.red.withOpacity(0.7),
                    fontWeight: FontWeight.w300,
                    fontSize: 10),
                    )
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Text("Device Id"),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 3,
                    ),
                    isActivated == true
                        ? Expanded(
                            flex: 2,
                            child: Container(
                              height: 35,
                              margin: EdgeInsets.only(left: 13),
                              child: Center(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(child:
                                    Text("$selectDevice",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 13),
                                    ),),
                                    SizedBox(width: 5,),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    )
                                  ],
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: isActivated != null && isActivated!
                                      ? Colors.black12
                                      : Colors.white,
                                  border: Border.all(
                                      color: Colors.black, width: 0.5),
                                  borderRadius: BorderRadius.circular(5.0)),
                            ))
                        : Expanded(
                            flex: 2,
                            child: IgnorePointer(
                              ignoring: isActivated ?? false,
                              child: Container(
                                height: 40,
                                margin: EdgeInsets.only(left: 13,right: 0.0),
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
                                        children: [

                                          Expanded(
                                            child: Text(
                                              'Select Device',
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
                                      items: devices
                                          .map((item) =>
                                              DropdownMenuItem<String>(
                                                value:
                                                    item['deviceid'].toString(),
                                                child: Text(
                                                  item['deviceid'].toString(),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    // fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ))
                                          .toList(),
                                      value: selectDevice,
                                      onChanged: (value) {

                                        setState(() {
                                          selectDevice = value as String;
                                        });

                                        int index =
                                        devices.indexWhere((element) => element['deviceid'] == selectDevice);

                                          print(devices[index]);



                                       PONextDocNoController.text = (devices[index]['NumSeqPO']+1).toString();
                                        TONextDocNoController.text = (devices[index]['NumSeqTO']+1).toString();

                                        TOINNextDocNoController.text = (devices[index]['NumSeqTOIN']+1).toString();

                                        TOOutNextDocNoController.text = (devices[index]['NumSeqTOOUT']+1).toString();

                                        GRNNextDocNoController.text = (devices[index]['NumSeqGRN']+1).toString();

                                        STNextDocNoController.text = (devices[index]['NumSeqST']+1).toString();



                                        RONextDocNoController.text = (devices[index]['NumSeqRO']+1).toString();

                                        RPNextDocNoController.text = (devices[index]['NumSeqRP']+1).toString();

                                        MJNextDocNoController.text = (devices[index]['NumSeqMJ']+1).toString();



                                        // "NumSeqPO": 0,
                                        // "NumSeqGRN": 0,
                                        // "NumSeqRO": 0,
                                        // "NumSeqRP": 0,
                                        // "NumSeqST": 0,
                                        // "NumSeqTO": 0,
                                        // "NumSeqTOOUT": 0,
                                        // "NumSeqTOIN": 0,
                                        // "NumSeqMJ": 0

                                        setState(() {
                                        });
                                      },
                                      icon: Padding(
                                        padding: EdgeInsets.only(
                                            right: 5.0),
                                        child: Icon(
                                          Icons.arrow_forward_ios_outlined,
                                        ),
                                      ),
                                      iconSize: 14,

                                      buttonDecoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.black38,
                                        ),
                                        color: Colors.white,
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
                          ),
                    SizedBox(
                      width: 3,
                    ),
                    Expanded(
                      flex: 1,
                      child: IgnorePointer(
                        ignoring: isActivated ?? false,
                        child: TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.green),
                          onPressed: () {
                            if(_connectionStatus == ConnectivityResult.none){

                              showDialogCheck("No Internet Connection");
                              return;
                            }

                            getDevices();
                            getStoreCode();
                            // if (usernameController.text ==""
                            //    ) {
                            //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            //
                            //     content: Text('Invalid Credentials',textAlign: TextAlign.center,),
                            //   ));
                            // }
                            // else{
                            //   // Navigator.push(
                            //   //     context,
                            //   //     MaterialPageRoute(
                            //   //         builder: (context) => LandingHomePage()));
                            // }
                          },
                          child: Text(
                            "REFRESH",
                            style: TextStyle(
                                color: isActivated != null && isActivated!
                                    ? Colors.black
                                    : Colors.white,

                                fontSize: 8.6),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Expanded(
                        flex: 1,
                        child: IgnorePointer(
                      ignoring:
                          isActivated != null && isActivated! ? false : true,
                      // isActivated != null &&  isActivated! ? true :false ,
                      child: TextButton(
                        style:
                            TextButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () {
                          if(_connectionStatus == ConnectivityResult.none){

                            showDialogCheck("No Internet Connection");
                            return;
                          }

                          deactivateDevice();
                        },
                        child: Text(
                          "DEACTIVATE",
                          style: TextStyle(
                              color: isActivated != null && isActivated!
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 8.6),
                        ),
                      ),
                    )),
                    SizedBox(
                      width: 5,
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            Text("Store Code")
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            isActivated == true
                                ? Expanded(
                                    flex: 2,
                                    child: Container(
                                      height: 35,
                                      child: Center(
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "$selectStore",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 17),
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
                                          color: isActivated != null &&
                                                  isActivated!
                                              ? Colors.black12
                                              : Colors.white,
                                          border: Border.all(
                                              color: Colors.black, width: 0.5),
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                    ))
                                : Expanded(
                                    flex: 2,
                                    child: IgnorePointer(
                                      ignoring: isActivated ?? false,
                                      child: Container(
                                        height: 35,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 2),
                                        child: Theme(
                                          data: Theme.of(context).copyWith(
                                            canvasColor: Colors.white,
                                            // backgroundColor: Colors.black26,
                                            // cardColor: Colors.black12
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton2(
                                              dropdownMaxHeight: 400,
                                              barrierDismissible: true,
                                              // disabledHint: false,
                                              isExpanded: true,
                                              buttonHeight: 500,

                                              hint: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      'Select Store',
                                                      style: TextStyle(
                                                        // fontSize: 14,
                                                        // fontWeight: FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                                          item['storecode'],
                                                          style: TextStyle(
                                                            // fontSize: 14,
                                                            // fontWeight: FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ))
                                                  .toList(),
                                              value: selectStore,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectStore = value as String;
                                                });
                                              },
                                              icon: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 13.0),
                                                child: Icon(
                                                  Icons
                                                      .arrow_forward_ios_outlined,
                                                ),
                                              ),
                                              iconSize: 14,

                                              buttonDecoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: Colors.black38,
                                                ),
                                                color: isActivated != null &&
                                                        isActivated!
                                                    ? Colors.black12
                                                    : Colors.white,
                                              ),
                                              buttonElevation: 0,
                                              dropdownDecoration: BoxDecoration(
                                                border: Border.all(
                                                  // style: BorderStyle.none,
                                                  width: 0.2,
                                                  color: Colors.black,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                // color: Colors.white,
                                              ),
                                              dropdownElevation: 0,
                                              scrollbarRadius:
                                                  Radius.circular(40),
                                              scrollbarThickness: 6,
                                              scrollbarAlwaysShow: true,
                                              // items: ['store 1','store 2']
                                              //     .map((item) => DropdownMenuItem<String>(
                                              //
                                              //   value: item.toString(),
                                              //   child: Text(
                                              //     item,
                                              //     style: const TextStyle(
                                              //       // fontSize: 14,
                                              //       // fontWeight: FontWeight.bold,
                                              //       color: Colors.black,
                                              //     ),
                                              //     overflow: TextOverflow.ellipsis,
                                              //   ),
                                              // ))
                                              //     .toList(),
                                              // value: selectStore,
                                              // onChanged: (value) {
                                              //   setState(() {
                                              //     selectStore = value  as String;
                                              //   });
                                              // },
                                              // // icon: Padding(
                                              // //   padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                              // //   child: const Icon(
                                              // //     Icons.arrow_forward_ios_outlined,
                                              // //   ),
                                              // // ),
                                              // // iconSize: 14,
                                              //
                                              // buttonDecoration: BoxDecoration(
                                              //   color: Colors.white,
                                              //   borderRadius: BorderRadius.circular(10),
                                              //   border: Border.all(
                                              //     style: BorderStyle.none,
                                              //     color: Colors.white,
                                              //   ),
                                              //
                                              // ),
                                              //
                                              // buttonElevation: 0,
                                              //
                                              // dropdownDecoration: BoxDecoration(
                                              //   borderRadius: BorderRadius.circular(10),
                                              //   // color: Colors.white,
                                              // ),
                                              // dropdownElevation: 0,
                                              // scrollbarRadius: const Radius.circular(40),
                                              // scrollbarThickness: 6,
                                              //
                                              // scrollbarAlwaysShow: true,
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
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          readOnly: true,
                          validator: (value) =>
                              value!.isEmpty ? 'Required *' : null,
                          controller: PONextDocNoController,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                          ],
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                              focusedBorder: APPConstants().focusInputBorder,
                              enabledBorder: APPConstants().enableInputBorder,
                              labelText: 'PO-Next Doc No',
                              labelStyle: TextStyle(color: Colors.black26),
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10.0, bottom: 10.0, top: 10.0),
                              // hintText: "PO-Next Doc No",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey))),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          readOnly:true,
                          validator: (value) =>
                              value!.isEmpty ? 'Required *' : null,
                          controller: GRNNextDocNoController,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                          ],
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                              focusedBorder: APPConstants().focusInputBorder,
                              enabledBorder: APPConstants().enableInputBorder,
                              labelText: 'GRN-Next Doc No',
                              labelStyle: TextStyle(color: Colors.black26),
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10.0, bottom: 10.0, top: 10.0),
                              // hintText: "GRN-Next Doc No",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey))),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          readOnly: true,
                          validator: (value) =>
                              value!.isEmpty ? 'Required *' : null,
                          controller: RONextDocNoController,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                          ],
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                              focusedBorder: APPConstants().focusInputBorder,
                              enabledBorder: APPConstants().enableInputBorder,
                              labelText: "RO-Next Doc No",
                              labelStyle: TextStyle(color: Colors.black26),
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10.0, bottom: 10.0, top: 10.0),
                              // hintText: "RO-Next Doc No",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey))),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(

                          readOnly: true,
                          validator: (value) =>
                              value!.isEmpty ? 'Required *' : null,
                          controller: RPNextDocNoController,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                          ],
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                              focusedBorder: APPConstants().focusInputBorder,
                              enabledBorder: APPConstants().enableInputBorder,
                              labelText: "RP-Next Doc No",
                              labelStyle: TextStyle(color: Colors.black26),
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10.0, bottom: 10.0, top: 10.0),
                              // hintText: "RP-Next Doc No",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey))),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          readOnly:true,
                          validator: (value) =>
                              value!.isEmpty ? 'Required *' : null,
                          controller: STNextDocNoController,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                          ],
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                              focusedBorder: APPConstants().focusInputBorder,
                              enabledBorder: APPConstants().enableInputBorder,
                              labelText: "ST-Next Doc No",
                              labelStyle: TextStyle(color: Colors.black26),
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10.0, bottom: 10.0, top: 10.0),
                              // hintText: "ST-Next Doc No",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey))),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(

                          readOnly:true,
                          validator: (value) =>
                              value!.isEmpty ? 'Required *' : null,
                          controller: TONextDocNoController,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                          ],
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                              focusedBorder: APPConstants().focusInputBorder,
                              enabledBorder: APPConstants().enableInputBorder,
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10.0, bottom: 10.0, top: 10.0),
                              // hintText: "TO-Next Doc No",
                              labelText: "TO-Next Doc No",
                              labelStyle: TextStyle(color: Colors.black26),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey))),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          readOnly:true,
                          validator: (value) =>
                              value!.isEmpty ? 'Required *' : null,
                          controller: TOOutNextDocNoController,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                          ],
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                              focusedBorder: APPConstants().focusInputBorder,
                              enabledBorder: APPConstants().enableInputBorder,
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10.0, bottom: 10.0, top: 10.0),
                              labelText: "TOOUT -Next Doc No",
                              labelStyle: TextStyle(color: Colors.black26),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey))),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          readOnly:true,
                          validator: (value) =>
                              value!.isEmpty ? 'Required *' : null,
                          controller: TOINNextDocNoController,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                            ],
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                              focusedBorder: APPConstants().focusInputBorder,
                              enabledBorder: APPConstants().enableInputBorder,
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10.0, bottom: 10.0, top: 10.0),
                              // hintText: "TOIN -Next Doc No",
                              labelText: "TOIN -Next Doc No",
                              labelStyle: TextStyle(color: Colors.black26),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey))),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          readOnly:true,
                          validator: (value) =>
                          value!.isEmpty ? 'Required *' : null,
                          controller: MJNextDocNoController,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                          ],
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                              focusedBorder: APPConstants().focusInputBorder,
                              enabledBorder: APPConstants().enableInputBorder,
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10.0, bottom: 10.0, top: 10.0),
                              // hintText: "TOIN -Next Doc No",
                              labelText: "MJ -Next Doc No",
                              labelStyle: TextStyle(color: Colors.black26),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey))),
                        ),
                        SizedBox(height: 10,),
                        Row(
                          children: [

                            Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 30,
                                      child: Checkbox(
                                        activeColor: APPConstants().colorRed,
                                        value: disabledCamera,
                                        onChanged: (v) {
                                          disabledCamera = v!;
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    Text(
                              "Disable Camera",
                              style: TextStyle(fontSize: 11),
                            ),

                                  ],
                                )),

                            Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 30,
                                      child: Checkbox(
                                        activeColor: APPConstants().colorRed,
                                        value: disabledUOMSelection,
                                        onChanged: (v) {
                                          disabledUOMSelection = v!;
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    Text(
                              "Enable UOM Selection",
                              style: TextStyle(fontSize: 11),
                            ),
                                  ],
                                ))
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 30,
                                    child: Checkbox(

                                      activeColor: APPConstants().colorRed,
                                      value: disabledContinuosScan,
                                      onChanged: (v) {
                                        disabledContinuosScan = v!;
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  Text(
                                    "Enable Continuous Scan",
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            // SizedBox(width: 5,),
                           Expanded(


                             child: Row(

                               children: [
                                 Container(
                                   width: 30,
                                   child: Checkbox(

                                     activeColor: APPConstants().colorRed,
                                     value: showDimension,
                                     onChanged: (v) {
                                       showDimension = v!;
                                       setState(() {});
                                     },
                                   ),
                                 ),
                                 Text(
                                   "Show Dimensions",
                                   style: TextStyle(fontSize: 11),
                                 ),
                               ],
                             ),
                           )
                          ],
                        ),
                        // Row(
                        //   children: [
                        //
                        //     // SizedBox(width: 5,),
                        //     Expanded(
                        //
                        //       child: Row(
                        //
                        //         children: [
                        //           Container(
                        //             width: 30,
                        //             child: Checkbox(
                        //
                        //               activeColor: APPConstants().colorRed,
                        //               value:showQuantityExceed,
                        //               onChanged: (v) {
                        //                 showQuantityExceed = v!;
                        //                 setState(() {});
                        //               },
                        //             ),
                        //           ),
                        //           Text(
                        //             "Show Quantity Exceed",
                        //             style: TextStyle(fontSize: 11),
                        //           ),
                        //         ],
                        //       ),
                        //     )
                        //   ],
                        // ),

                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.green),
                                onPressed: () async {
                                  var st = _formKey.currentState;
                                  if (!st!.validate()) {
                                    print("not valid");
                                    return;
                                  }

                                  // if(_connectionStatus == ConnectivityResult.none){
                                  //
                                  //   showDialogCheck("No Internet Connection");
                                  //   return;
                                  // }
                                  showDialogGotData(
                                      "Are You Sure to Save Settings ?");

                                  // if (usernameController.text ==""||
                                  //     passwordController.text =="") {
                                  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  //
                                  //     content: Text('Invalid Credentials',textAlign: TextAlign.center,),
                                  //   ));
                                  // }
                                  // else{
                                  //   // Navigator.push(
                                  //   //     context,
                                  //   //     MaterialPageRoute(
                                  //   //         builder: (context) => LandingHomePage()));
                                  // }
                                },
                                child: Text(
                                  "SAVE",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                                child: TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.orange),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            LandingHomePage()));
                              },
                              child: Text(
                                "HOME",
                                style: TextStyle(color: Colors.white),
                              ),
                            ))
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  saveSettings() async {
    var st = _formKey.currentState;
    print(st!.validate());
    // final FormState? form = _formKey.currentState!;


    if (st.validate() && selectStore != null && selectDevice != null) {
      print('Form is valid');
      print(disabledCamera);
      print(disabledUOMSelection);
      print(disabledContinuosScan);
      // return;
      await prefs?.setString("disableCamera", disabledCamera.toString());
      await prefs?.setString(
          "enableUOMSelection", disabledUOMSelection.toString());
      await prefs?.setString(
          "enableContinuousScan", disabledContinuosScan.toString());


      await prefs?.setBool(
          "showDimensions", showDimension!);


      await prefs?.setBool(
          "showQuantityExceed", showQuantityExceed!);


      print("conditions 936");
      print(selectDevice);
      print(APPGENERALDATASave);
      devices.forEach(print);

      // devices.any((element) => print(element['deviceid']));
      int index =
          devices.indexWhere((element) => element['deviceid'] == selectDevice);
      print(index);
      if (index != -1) {
        print(devices[index]['storeDevice'].runtimeType);
        // return;
        setState(() {
          // devices = [];
          // devices = responseJson[0]['pullData'];
          homeList = [];

          homeList.add({
            "type":
                devices[index]['storeDevice'] == 1 ? "REFRESH" : "IMPORT DATA",
            "value": true
          });
          homeList.add({"type": "VIEW ITEMS", "value": true});

          devices[index]['storeDevice'] == 0 && getApiResponse[0]['SC'] == true
              ? homeList.add(
                  {"type": "STOCK COUNT", "value": getApiResponse[0]['SC']})
              : null;
          devices[index]['storeDevice'] == 0 && getApiResponse[0]['GRN'] == true
              ? homeList.add(
                  {"type": "GOODS RECEIVE", "value": getApiResponse[0]['GRN']})
              : null;
          devices[index]['storeDevice'] == 0 && getApiResponse[0]['PO'] == true
              ? homeList.add(
                  {"type": "PURCHASE ORDER", "value": getApiResponse[0]['PO']})
              : null;
          devices[index]['storeDevice'] == 0 && getApiResponse[0]['RO'] == true
              ? homeList.add(
                  {"type": "RETURN ORDER", "value": getApiResponse[0]['RO']})
              : null;

          devices[index]['storeDevice'] == 0 && getApiResponse[0]['RP'] == true
              ? homeList.add(
                  {"type": "RETURN PICK", "value": getApiResponse[0]['RP']})
              : null;
          devices[index]['storeDevice'] == 0 && getApiResponse[0]['TO'] == true
              ? homeList.add(
                  {"type": "TRANSFER ORDER", "value": getApiResponse[0]['TO']})
              : null;
          devices[index]['storeDevice'] == 0 &&
                  getApiResponse[0]['TOOUT'] == true
              ? homeList.add(
                  {"type": "TRANSFER OUT", "value": getApiResponse[0]['TOOUT']})
              : null;
          devices[index]['storeDevice'] == 0 &&
                  getApiResponse[0]['TOIN'] == true
              ? homeList.add(
                  {"type": "TRANSFER IN", "value": getApiResponse[0]['TOIN']})
              : null;

          getApiResponse[0]['OnHand'] == true
              ? homeList.add(
                  {"type": "ON HAND", "value": getApiResponse[0]['OnHand']})
              : null;
          getApiResponse[0]['ItemPrice'] == true
              ? homeList.add({
                  "type": "PRICE CHECK",
                  "value": getApiResponse[0]['ItemPrice']
                })
              : null;
          devices[index]['storeDevice'] == 0
              ? homeList.add({"type": "HISTORY", "value": true})
              : null;
        });
      }
      // return;

      // return;
      if (APPGENERALDATASave == "" || APPGENERALDATASave == null) {
        print("conditions if 1357");
// return;
        homeList.forEach((element) {
          print("For Each Conditions");

          print(element);
          if (element['value'] == true) {
            _sqlHelper.addGeneralSaveHomeData(
                element['type'], element['value']);
          }
        });
        await _sqlHelper.addAPPGENERALDATA(
            selectDevice,
            selectStore,
            PONextDocNoController.text,
            GRNNextDocNoController.text,
            RONextDocNoController.text,
            RPNextDocNoController.text,
            STNextDocNoController.text,
            TONextDocNoController.text,
            TOOutNextDocNoController.text,
            TOINNextDocNoController.text,
            MJNextDocNoController.text,
            true);
        listenStatusValues();
        await activateDeviceOrUpdateDevice();
      } else {
        print("conditions if 1383");
        // return;
        homeList.forEach((element) {
          if (element['value'] == true) {
            _sqlHelper.updateGeneralSaveHomeData(
                element['type'], element['value']);
          }
        });
        await _sqlHelper.updateAPPGENERALDATA(
            APPGENERALDATASave['id'],
            selectDevice,
            selectStore,
            PONextDocNoController.text,
            GRNNextDocNoController.text,
            RONextDocNoController.text,
            RPNextDocNoController.text,
            STNextDocNoController.text,
            TONextDocNoController.text,
            TOOutNextDocNoController.text,
            TOINNextDocNoController.text,
            MJNextDocNoController.text,
            true);
        listenStatusValues();
        await activateDeviceOrUpdateDevice();
      }
    } else {
      // Navigator.pop(context);



      print('Form is invalid');
      print(selectDevice);
      print(selectStore);
    }
  }

  showDialogGotData(String text) {
    // set up the button
    Widget yesButton = TextButton(
      style: APPConstants().btnBackgroundYes,
      child: Text(
        "Yes",
        style: APPConstants().YesText,
      ),
      onPressed: () {
        if (selectStore == null && selectDevice == null) {

          Navigator.pop(context);

          showDialogCheck("Please Choose a Store And Device");

          return;
        }
        if (selectStore == null) {
          Navigator.pop(context);
          showDialogCheck("Please Choose a Store");
          return;
        }
        if (selectDevice == null) {
          Navigator.pop(context);
          showDialogCheck("Please Select a Device");
          return;
        }
        saveSettings();
        setState(() {});
        Navigator.pop(context);
      },
    );

    Widget noButton = TextButton(
      style: APPConstants().btnBackgroundNo,
      child: Text(
        "No",
        style: APPConstants().noText,
      ),
      onPressed: () {
        print("Scanning code");
        setState(() {});
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(

      title: Text("DynamicsConnect"),
      content: Text("$text"),
      actions:
      [noButton, yesButton],
    );


     // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (BuildContext context)
      {
        return alert;
      },
    );
  }
}
