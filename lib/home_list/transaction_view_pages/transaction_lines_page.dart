import 'dart:convert';

import 'package:dynamicconnectapp/constants/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'dart:io';
import '../../helper/local_db.dart';
import 'package:http/http.dart' as http;

class TranscationLinesPage extends StatefulWidget {
  TranscationLinesPage({this.type});
  final dynamic type;
  @override
  State<TranscationLinesPage> createState() => _TranscationLinesPageState();
}

class _TranscationLinesPageState extends State<TranscationLinesPage> {
  TextEditingController barcodeController = TextEditingController();
  final SQLHelper _sqlHelper = SQLHelper();

  bool isLoading = true;
  ScrollController _scrollController = ScrollController();

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

  @override
  void dispose() {

    // FocusScope.of(context).unfocus();
    super.dispose();
  }

  var transType = "";

  getTransTypes() {


    print("Line 459 The previous route is : lines");


    print(widget.type);
    if (widget.type == "ST") {
      setState(() {
        transType = "STOCK COUNT";
      });
    }
    if (widget.type == "PO") {
      transType = "PURCHASE ORDER";
      setState(() {});
    }
    if (widget.type == "GRN") {
      transType = "GOODS RECEIVE";
      setState(() {});
    }

    if (widget.type == "RP") {
      transType = "RETURN PICK";
      setState(() {});
    }

    if (widget.type == "RO") {
      transType = "RETURN ORDER";
      setState(() {});
    }
    if (widget.type == "MJ") {
      transType = "MOVEMENT JOURNAL";
      setState(() {});
    }

    if (widget.type == "TO") {
      transType = "TRANSFER ORDER";
      setState(() {});
    }

    if (widget.type == "TO-OUT") {
      transType = "TRANSFER OUT";
      setState(() {});
    }

    if (widget.type == "TO-IN") {
      transType = "TRANSFER IN";
      setState(() {});
    }
  }

  dynamic transactionData;

  getTransactionHeaderDetails() async {
    transactionData = await _sqlHelper.getTRANSHEADER(widget.type == 'ST'
        ? "1"
        : widget.type == 'PO'
            ? "3"
            : widget.type == 'RO'
                ? "9"
                : widget.type == 'RP'
                    ? "10"
                    : widget.type == 'TO'
                        ? "11"
                        : widget.type == 'MJ'
                            ? "22"
                            : "");
    setState(() {});
  }

  bool? lineDeleted = false;

  getToken() async {
    getTransTypes();
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



    lineDeleted = await prefs!.setBool("lineDeleted", true);
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


  @override
  void initState() {
    FocusManager.instance.primaryFocus!.unfocus();

    // Focus.of(context).dispose();
    // FocusScope.of(context).unfocus();
    getTransTypes();
    gettransactionDetails();
    getToken();
    getTransactionHeaderDetails();
    super.initState();
  }

  gettransactionDetails() async {
    transactionDetails =

    await _sqlHelper.getTRANSDETAILS(widget.type == 'ST'
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
                            : widget.type == 'TO-OUT'
                                ? "5"
                                : widget.type == 'TO-IN'
                                    ? "6"
                                    : widget.type == 'MJ'
                                        ? "22"
                                        : "");
    print(transactionData);
    setState(() {});

    if (transactionDetails.length <= 15) {
      print("data is less 15");
      transactionDetailsLists.addAll(transactionDetails);

      setState(() {});
    } else {
      for (var i = 0; i < 15; i++) {
        transactionDetailsLists.add(transactionDetails[i]);
      }
      setState(() {});
    }

    print("data list is : ${transactionDetails.length}");
    setState(() {
      isLoading = false;
    });
  }

  List<dynamic> transactionDetails = [];
  List<dynamic> transactionDetailsLists = [];

  setValueLoadtransactionDetails(String? key) async {
    print("key");
    print(key);

    transactionDetails =
    // widget.type == 'ST'?
    //
    // await _sqlHelper.getTRANSDETAILSDetailsBySearchStockCount(
    // key,"1"):


    await _sqlHelper.getTRANSDETAILSDetailsBySearch(
        key,
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
                                : widget.type == 'TO-OUT'
                                    ? "5"
                                    : widget.type == 'TO-IN'
                                        ? "6"
                                        : widget.type == 'MJ'
                                            ? "22"
                                            : "");

    print(transactionDetails.length);
    if (transactionDetails.length <= 15) {
      print("data is less 15");
      transactionDetailsLists.addAll(transactionDetails);

      setState(() {});
    } else {
      for (var i = 0; i < 15; i++) {
        transactionDetailsLists.add(transactionDetails[i]);
      }
    }
    // return;

    setState(() {
      isLoading = false;
    });

  }

  set() {
    for (var i = 0; i < 5; i++) {
      transactionDetailsLists.add(transactionDetails[i]);
    }

    setState(() {});
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
                child: Column(children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: transactionData == null ||
                                transactionData.length == 0
                            ? Container()
                            : Container(
                                height: 40,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(
                                        color: Colors.red[100]!, width: 3)),
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                child: Center(
                                  child: Text(
                                    "DOCUMENT NO :${transactionData[0]['DOCNO'] ?? ""}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey),
                                  ),
                                )),
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
                            onChanged: (value) async {
                              print(transType);
                              if (barcodeController.text.trim() == "") {
                                setState(() {
                                  isLoading = true;
                                  transactionDetailsLists = [];
                                  transactionDetails = [];
                                });
                                await gettransactionDetails();

                                setState(() {
                                  isLoading = false;
                                });
                                return;
                              }
                              var result =
                                  widget.type == 'ST' ?
                              await _sqlHelper
                              .getTRANSDETAILSDetailsBySearchStock(
                              barcodeController.text,
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
                              'TO-OUT'
                              ? "5"
                                  : widget.type ==
                              'TO-IN'
                              ? "6"
                                  : widget.type ==
                              'MJ'
                              ? "22"
                                  : "")
                              :
                              await _sqlHelper
                                  .getTRANSDETAILSDetailsBySearch(
                                      barcodeController.text,
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
                                                                      'TO-OUT'
                                                                  ? "5"
                                                                  : widget.type ==
                                                                          'TO-IN'
                                                                      ? "6"
                                                                      : widget.type ==
                                                                              'MJ'
                                                                          ? "22"
                                                                          : "");

                              print(result);
                              if (result.length > 0) {
                                setState(() {
                                  isLoading = true;
                                  transactionDetailsLists = [];
                                  transactionDetails = [];
                                });

                                await setValueLoadtransactionDetails(
                                    barcodeController.text);
                                setState(() {
                                  isLoading = false;
                                });
                                return;
                                print("search is found");
                              } else {
                                setState(() {
                                  isLoading = true;
                                  transactionDetailsLists = [];
                                  transactionDetails = [];
                                });

                                Future.delayed(const Duration(seconds: 3), () {
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                                print("search is not found");
                              }
                            },
                            validator: (value) =>
                                value!.isEmpty ? 'Required *' : null,
                            controller: barcodeController,
                            decoration: InputDecoration(
                                focusedBorder: APPConstants().focusInputBorder,
                                enabledBorder: APPConstants().enableInputBorder,
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    print(transType);
                                    print(widget.type);
                                    if (barcodeController.text.trim() == "") {
                                      setState(() {
                                        isLoading = true;
                                        transactionDetailsLists = [];
                                        transactionDetails = [];
                                      });
                                      await gettransactionDetails();

                                      setState(() {
                                        isLoading = false;
                                      });
                                      return;
                                    }
                                    print(transType == "PURCHASE ORDER");

                                    // return;

                                    if (transType == "PURCHASE ORDER" ||
                                        transType == "RETURN ORDER") {}

                                    var result = await _sqlHelper
                                        .getTRANSDETAILSDetailsBySearch(
                                            barcodeController.text,
                                            widget.type == 'ST'
                                                ? "1"
                                                : widget.type == 'PO'
                                                    ? "3"
                                                    : widget.type == 'GRN'
                                                        ? "4"
                                                        : transType ==
                                                                "RETURN ORDER"
                                                            ? "9"
                                                            : widget.type ==
                                                                    'RP'
                                                                ? "10"
                                                                : widget.type ==
                                                                        'TO'
                                                                    ? "11"
                                                                    : widget.type ==
                                                                            'TO-OUT'
                                                                        ? "5"
                                                                        : widget.type ==
                                                                                'TO-IN'
                                                                            ? "6"
                                                                            : widget.type == 'MJ'
                                                                                ? "22"
                                                                                : "");

                                    print(result.length);
                                    if (result.length > 0) {
                                      setState(() {
                                        isLoading = true;
                                        transactionDetailsLists = [];
                                        transactionDetails = [];
                                      });
                                      await setValueLoadtransactionDetails(
                                          barcodeController.text);
                                      setState(() {
                                        isLoading = false;
                                      });
                                      return;
                                      print("search is found");
                                    } else {
                                      setState(() {
                                        isLoading = true;
                                        transactionDetailsLists = [];
                                        transactionDetails = [];
                                      });

                                      Future.delayed(const Duration(seconds: 3),
                                          () {
                                        setState(() {
                                          isLoading = false;
                                        });
                                      });
                                      print("search is not found");
                                    }
                                  },
                                  icon: Icon(
                                    Icons.manage_search,
                                    size: 20,
                                  ),
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                    left: 15, right: 15, top: 2, bottom: 2),
                                hintText: "Bar Code",
                                helperStyle: TextStyle(color: Colors.black26),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  // borderSide: Border()
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  isLoading
                      ? Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CupertinoActivityIndicator(
                                    // color: Colors.green,
                                    radius: 50,
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: Container(
                          height: MediaQuery.of(context).size.height,
                          child: SmartRefresher(
                            // scrollController: _scrollController,
                            enablePullDown: transactionDetails.length !=
                                    transactionDetailsLists.length
                                ? true
                                : false,
                            enablePullUp: true,
                            header: WaterDropHeader(),
                            footer: CustomFooter(
                              builder:
                                  (BuildContext? context, LoadStatus? mode) {
                                Widget body;
                                // print("last index 272");
                                // print(mode);
                                // print(mode?.index == items.length-1);
                                // print(mode == LoadStatus.noMore);
                                if (transactionDetails.length ==
                                    transactionDetailsLists.length) {
                                  // print("full loaded");
                                  body = Container();
                                } else {}
                                if (mode == LoadStatus.idle) {

                                  if (transactionDetailsLists.length <=
                                      transactionDetails.length) {
                                    body = Container()
                                        // Text("pull up load")
                                        ;
                                  } else {
                                    body = Container();
                                  }
                                } else if (mode == LoadStatus.loading &&
                                    transactionDetailsLists.length !=
                                        transactionDetails.length) {
                                  body = CupertinoActivityIndicator(
                                    radius: 20,
                                  );
                                } else if (mode == LoadStatus.failed) {
                                  body = Text("Load Failed!Click retry!");
                                } else if (mode == LoadStatus.canLoading) {
                                  body = Text("release to load more");
                                } else {
                                  body = Container();
                                  // Text("No more Data");
                                }

                                return Container(
                                  height: 55.0,
                                  child: Center(child: body),
                                );
                              },
                            ),
                            controller: _refreshController,
                            onRefresh: _onRefresh,
                            onLoading: _onLoading,
                            child: ListView.builder(
                              itemBuilder: (context, int index) {
                                return
                                widget.type =='ST'
                                  ?
                                InkWell(
                                  hoverColor: Colors.red,
                                  onTap: () {},
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.yellow[50],
                                          borderRadius:
                                          BorderRadius.circular(15.0),
                                          border: Border.all(
                                              color: Colors.black12, width: 1.2)
                                        // color: Colors.red,
                                      ),
                                      margin: EdgeInsets.only(
                                          right: 10.0,
                                          bottom: 10.0,
                                          top: 10.0,
                                          left: 10.0),
                                      padding: EdgeInsets.only(
                                          left: 10.0, bottom: 15, top: 15),
                                      //   height: 300,

                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Expanded(child: Text("Status  :")),
                                              Expanded(
                                                  child: Text(
                                                      transactionDetailsLists[
                                                  index]
                                                  ['STATUS'] == 1 ?
                                                  "New" :
                                                  transactionDetailsLists[
                                                  index] ['STATUS'] == 2 ? "Posted" :
                                                  ""))

                                            ],
                                          ),
                                          SizedBox(height: 5,),
                                          Row(
                                            children: [
                                              Expanded(child: Text("Sl No  :")),
                                              Expanded(
                                                  child: Text("${index + 1}"))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              // {id: 2, ITEMBARCODE: 3330000307227, ItemId: 33300003,
                                              //   ItemName: 21ST CENT FOLICACID TAB 100S,
                                              //   DATAAREAID: 1000, WAREHOUSE: ,
                                              //   CONFIGID: , COLORID: , SIZEID: , STYLEID: ,
                                              //   INVENTSTATUS: , QTY: 0.0, UNIT: PACK, ItemAmount: 0.0}
                                              Expanded(
                                                  child: Text("Item ID :")),
                                              Expanded(
                                                  child: Text(
                                                      transactionDetailsLists[
                                                      index]
                                                      ['ITEMID'] ??
                                                          "")),
                                              Expanded(
                                                  child: IconButton(
                                                    hoverColor: Colors.red,
                                                    onPressed: () async {

                                                      // return;

                                                      showDialogMessage(
                                                          context,
                                                          transactionDetailsLists[
                                                          index]['id'],
                                                          index);
                                                      // return;

                                                      // await _sqlHelper.addTRANSDETAILS(
                                                      //     HRecId :  transactionData[0]['RecId']  ,
                                                      //     DOCNO :  transactionData[0]['DOCNO'] ,
                                                      //     ITEMID :transactionDetailsLists[index]['ITEMID'] ,
                                                      //     ITEMNAME : transactionDetailsLists[index]['ITEMNAME'],
                                                      //     TRANSTYPE : widget.transactionType == "STOCK COUNT" ? 1 :"" ,
                                                      //     DEVICEID :activatedDevice ,
                                                      //     QTY : transactionDetailsLists[index]['QTY'],
                                                      //     UOM  : transactionDetailsLists[index]['UOM'],
                                                      //     BARCODE :transactionDetailsLists[index]['BARCODE'],
                                                      //     CREATEDDATE : DateTime.now().toString() ,
                                                      //     INVENTSTATUS : transactionDetailsLists[index]['INVENTSTATUS'],
                                                      //     SIZEID : transactionDetailsLists[index]['SIZEID'],
                                                      //     COLORID :  transactionDetailsLists[index]['COLORID'],
                                                      //     CONFIGID :  transactionDetailsLists[index]['CONFIGID'],
                                                      //     STYLESID :  transactionDetailsLists[index]['STYLESID'],
                                                      //     STORECODE :  activatedStore,
                                                      //     LOCATION :  transactionData[0]['VRLOCATION'].toString()
                                                      // );
                                                      //
                                                      // Navigator.push(context, MaterialPageRoute(
                                                      //     builder: (context)=>TransactionViewPage(
                                                      //       currentIndex: 1,
                                                      //       pageType: widget.transactionType,
                                                      //     )));
                                                    },
                                                    icon: Icon(
                                                      Icons.delete_forever_outlined,
                                                      color: Colors.red,
                                                      size: 45,
                                                    ),
                                                  ))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Text("BARCODE  :")),
                                              Expanded(
                                                  child: Text(
                                                      transactionDetailsLists[
                                                      index]
                                                      ['BARCODE'] ??
                                                          ""))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Text("Item Name :")),
                                              Expanded(
                                                  child: Text(
                                                      transactionDetailsLists[
                                                      index]
                                                      ['ITEMNAME'] ??
                                                          ""))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(child: Text("QTY : ")),
                                              Expanded(
                                                  child: Text(
                                                      "${transactionDetailsLists[index]['QTY'] ?? ""}   ${transactionDetailsLists[index]['UOM'] ?? ""}"))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Text("BATCH NO  :")),
                                              Expanded(
                                                  child: Text(
                                                      transactionDetailsLists[
                                                      index]
                                                      ['BATCHNO'] ??
                                                          ""))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                      "Manufacturer Date :")),
                                              Expanded(
                                                  child: Text(
                                                    // DateTime.parse(
                                                      transactionDetailsLists[
                                                      index]
                                                      [
                                                      'PRODDATE']
                                                          .toString()
                                                          // )
                                                          ==
                                                          "null"
                                                          ? ""
                                                          : transactionDetailsLists[
                                                      index]
                                                      ['PRODDATE']
                                                          .toString()
                                                    // .substring(0,10)
                                                  ))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Text("Expiry Date :")),
                                              Expanded(
                                                  child: Text(
                                                      transactionDetailsLists[
                                                      index]
                                                      [
                                                      'EXPDATE']
                                                          .toString() ==
                                                          "null"
                                                          ? ""
                                                          : transactionDetailsLists[
                                                      index]
                                                      ['EXPDATE']
                                                          .toString()
                                                    // .substring(0,10)

                                                  ))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child:
                                                  Text("Batch Enabled :")),
                                              Expanded(
                                                  child: Text(
                                                      transactionDetailsLists[
                                                      index]
                                                      [
                                                      'BatchEnabled']
                                                          .toString() ==
                                                          "1"
                                                          ? "true"
                                                          : "false"))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child:
                                                  Text("Batched Item :")),
                                              Expanded(
                                                  child: Text(
                                                      "${transactionDetailsLists[index]['BatchedItem'].toString() == "1" ? "true" : "false"}"))
                                            ],
                                          ),
                                        ],
                                      )),
                                )
                                :

                                  InkWell(
                                  hoverColor: Colors.red,
                                  onTap: () {},
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.yellow[50],
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          border: Border.all(
                                              color: Colors.black12, width: 1.2)
                                          // color: Colors.red,
                                          ),
                                      margin: EdgeInsets.only(
                                          right: 10.0,
                                          bottom: 10.0,
                                          top: 10.0,
                                          left: 10.0),
                                      padding: EdgeInsets.only(
                                          left: 10.0, bottom: 15, top: 15),
                                      //   height: 300,

                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(child: Text("Sl No  :")),
                                              Expanded(
                                                  child: Text("${index + 1}"))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              // {id: 2, ITEMBARCODE: 3330000307227, ItemId: 33300003,
                                              //   ItemName: 21ST CENT FOLICACID TAB 100S,
                                              //   DATAAREAID: 1000, WAREHOUSE: ,
                                              //   CONFIGID: , COLORID: , SIZEID: , STYLEID: ,
                                              //   INVENTSTATUS: , QTY: 0.0, UNIT: PACK, ItemAmount: 0.0}
                                              Expanded(
                                                  child: Text("Item ID :")),
                                              Expanded(
                                                  child: Text(
                                                      transactionDetailsLists[
                                                                  index]
                                                              ['ITEMID'] ??
                                                          "")),
                                              Expanded(
                                                  child: IconButton(
                                                hoverColor: Colors.red,
                                                onPressed: () async {

                                                  // return;

                                                  showDialogMessage(
                                                      context,
                                                      transactionDetailsLists[
                                                          index]['id'],
                                                      index);
                                                  // return;

                                                  // await _sqlHelper.addTRANSDETAILS(
                                                  //     HRecId :  transactionData[0]['RecId']  ,
                                                  //     DOCNO :  transactionData[0]['DOCNO'] ,
                                                  //     ITEMID :transactionDetailsLists[index]['ITEMID'] ,
                                                  //     ITEMNAME : transactionDetailsLists[index]['ITEMNAME'],
                                                  //     TRANSTYPE : widget.transactionType == "STOCK COUNT" ? 1 :"" ,
                                                  //     DEVICEID :activatedDevice ,
                                                  //     QTY : transactionDetailsLists[index]['QTY'],
                                                  //     UOM  : transactionDetailsLists[index]['UOM'],
                                                  //     BARCODE :transactionDetailsLists[index]['BARCODE'],
                                                  //     CREATEDDATE : DateTime.now().toString() ,
                                                  //     INVENTSTATUS : transactionDetailsLists[index]['INVENTSTATUS'],
                                                  //     SIZEID : transactionDetailsLists[index]['SIZEID'],
                                                  //     COLORID :  transactionDetailsLists[index]['COLORID'],
                                                  //     CONFIGID :  transactionDetailsLists[index]['CONFIGID'],
                                                  //     STYLESID :  transactionDetailsLists[index]['STYLESID'],
                                                  //     STORECODE :  activatedStore,
                                                  //     LOCATION :  transactionData[0]['VRLOCATION'].toString()
                                                  // );
                                                  //
                                                  // Navigator.push(context, MaterialPageRoute(
                                                  //     builder: (context)=>TransactionViewPage(
                                                  //       currentIndex: 1,
                                                  //       pageType: widget.transactionType,
                                                  //     )));
                                                },
                                                icon: Icon(
                                                  Icons.delete_forever_outlined,
                                                  color: Colors.red,
                                                  size: 45,
                                                ),
                                              ))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Text("BARCODE  :")),
                                              Expanded(
                                                  child: Text(
                                                      transactionDetailsLists[
                                                                  index]
                                                              ['BARCODE'] ??
                                                          ""))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Text("Item Name :")),
                                              Expanded(
                                                  child: Text(
                                                      transactionDetailsLists[
                                                                  index]
                                                              ['ITEMNAME'] ??
                                                          ""))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(child: Text("QTY : ")),
                                              Expanded(
                                                  child: Text(
                                                      "${transactionDetailsLists[index]['QTY'] ?? ""}   ${transactionDetailsLists[index]['UOM'] ?? ""}"))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Text("BATCH NO  :")),
                                              Expanded(
                                                  child: Text(
                                                      transactionDetailsLists[
                                                                  index]
                                                              ['BATCHNO'] ??
                                                          ""))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                      "Manufacturer Date :")),
                                              Expanded(
                                                  child: Text(
                                                      // DateTime.parse(
                                                      transactionDetailsLists[
                                                                          index]
                                                                      [
                                                                      'PRODDATE']
                                                                  .toString()
                                                              // )
                                                              ==
                                                              "null"
                                                          ? ""
                                                          : transactionDetailsLists[
                                                                      index]
                                                                  ['PRODDATE']
                                                              .toString()
                                                      // .substring(0,10)
                                                      ))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Text("Expiry Date :")),
                                              Expanded(
                                                  child: Text(
                                                      transactionDetailsLists[
                                                                          index]
                                                                      [
                                                                      'EXPDATE']
                                                                  .toString() ==
                                                              "null"
                                                          ? ""
                                                          : transactionDetailsLists[
                                                                      index]
                                                                  ['EXPDATE']
                                                              .toString()
                                                      // .substring(0,10)

                                                      ))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child:
                                                      Text("Batch Enabled :")),
                                              Expanded(
                                                  child: Text(
                                                      transactionDetailsLists[
                                                                          index]
                                                                      [
                                                                      'BatchEnabled']
                                                                  .toString() ==
                                                              "1"
                                                          ? "true"
                                                          : "false"))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child:
                                                      Text("Batched Item :")),
                                              Expanded(
                                                  child: Text(
                                                      "${transactionDetailsLists[index]['BatchedItem'].toString() == "1" ? "true" : "false"}"))
                                            ],
                                          ),
                                        ],
                                      )),
                                );
                              },

                              // itemBuilder: (c, i) => Card(child: Center(child: Text(items[i]))),
                              // itemExtent: 300.0,
                              itemCount: transactionDetailsLists.length,
                            ),
                          ),
                        ))
                ])));
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  showDialogMessage(context, int id, int index) {
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
                child: Text("No", style: APPConstants().noText),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                style: APPConstants().btnBackgroundYes,
                child: Text("Yes", style: APPConstants().YesText),
                onPressed: () async {
                  Navigator.pop(context);
                  // print(transactionDetailsLists[index]);
                  // print(widget.transactionType);

                  // return;
                  var ind;
                  setState(() {
                    ind = transactionDetails.indexWhere((element) =>
                        transactionDetailsLists[index][id.toString()] ==
                        element[id.toString()]);
                    print(transactionDetails[ind]);
                    print(ind);

                    print(transactionDetails[ind]);
                    // return;
                    // transactionDetails.removeWhere((element) =>  transactionDetailsLists[index][id.toString()] == element[id.toString()]);
                    // transactionDetailsLists.removeAt(index);
                    // transactionDetails.removeAt(ind);
                  });

                  //
                  //  transactionDetails.removeWhere((element) => transactionDetailsLists[index] == element);
                  transactionDetails.remove(transactionDetails[ind]);
                  await transactionDetailsLists.removeAt(index);
                  await _sqlHelper.deleteTRANSDETAILS(id);

                  await prefs!.setBool("lineDeleted", true);
                  // setState((){
                  //   isActivateNew=false;
                  //   isActivateSave=true;
                  // });

                  showDialogGotData("Transaction Deleted");
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

  List<dynamic> transList = [];
  setvalue() async {
    // return;
    List<Map<String, dynamic>> users = [
      {"id": 123, "name": "Bob", "age": 25},
      {"id": 345, "name": "Joe", "age": 44},
      {"id": 35, "name": "Joxe", "age": 40},
    ];

    setState(() {
      transList = [];

      transList.addAll(transactionDetailsLists);
    });
    if (transList.isNotEmpty) {
      transList.sort((a, b) => a['LISTID'].compareTo(b['LISTID']));
      print("line 922 last List Id is");
      print(transList.first['LISTID']);
      print("line 922");

      print("Data is 914");
      // return;

      print(transactionDetailsLists[transactionDetailsLists.length - 1]
              ['LISTID']
          .runtimeType);

      print(transactionDetailsLists[transactionDetailsLists.length - 1]
          ['LISTID']);

      var maxListId;
      transactionDetailsLists.forEach((element) {
        print(element['LISTID']);
        print("List elements 942");
      });

      transactionDetailsLists
          .addAll(await _sqlHelper.getTRANSDETAILSDetailsBySearchLoad(
              transList.first['LISTID'].toString(),
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
                                      : widget.type == 'TO-OUT'
                                          ? "5"
                                          : widget.type == 'TO-IN'
                                              ? "6"
                                              : widget.type == 'MJ'
                                                  ? "22"
                                                  : "",
              transList.first['AXDOCNO']));
    }
    // transactionDetailsLists.addAll(await _sqlHelper.getIMPORTDETAILS(
    // transactionDetailsLists[transactionDetailsLists.length -1]['id'],
    //     widget.axDocNo));

    print("data list is : ${transactionDetailsLists.length}");
    print(transactionDetailsLists.last['id']);
    print("data list is : ");
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });

    return;

    // for(var i= transactionDetailsLists.length-1; i < transactionDetails.length -1;i++ ){
    //   var u =0;
    //   u++;
    //
    //   // item1.add(items[i-1]);
    //   // print("contains value");
    //   // print(!item1.any((element) => element.contains(items[i])));
    //   //     if(!item1.any((element) => element.contains(items[i]))){
    //   if(u<4){
    //     print("contains value items : ${transactionDetails.length.toString()}");
    //     print("contains value item1 : ${transactionDetailsLists.length.toString()}");
    //     if(transactionDetailsLists.length <=transactionDetails.length){
    //       print(transactionDetailsLists[i]);
    //       // item1.add(items[i]);
    //       // item1.add(items[i+1]);
    //       // item1.add(items[i+2]);
    //
    //       transactionDetailsLists.length <=transactionDetails.length  && transactionDetails[i] !=null ?  transactionDetailsLists.add(transactionDetails[i]):null;
    //
    //       transactionDetailsLists.length <=transactionDetails.length  && transactionDetails[i+1] !=null ?  transactionDetailsLists.add(transactionDetails[i+1]):null;
    //
    //       transactionDetailsLists.length <=transactionDetails.length  && transactionDetails[i+2] !=null ?  transactionDetailsLists.add(transactionDetails[i+2]):null;
    //
    //       transactionDetailsLists.length <=transactionDetails.length  && transactionDetails[i+3] !=null ?  transactionDetailsLists.add(transactionDetails[i+3]):null;
    //       transactionDetailsLists.length <=transactionDetails.length  && transactionDetails[i+4] !=null ?  transactionDetailsLists.add(transactionDetails[i+4]):null;
    //
    //       transactionDetailsLists.length <=transactionDetails.length  && transactionDetails[i+5] !=null ?  transactionDetailsLists.add(transactionDetails[i+5]):null;
    //
    //       transactionDetailsLists.length <=transactionDetails.length  && transactionDetails[i+6] !=null ?  transactionDetailsLists.add(transactionDetails[i+6]):null;
    //
    //       transactionDetailsLists.length <=transactionDetails.length  && transactionDetails[i+7] !=null ?  transactionDetailsLists.add(transactionDetails[i+7]):null;
    //       transactionDetailsLists.length <=transactionDetails.length  && transactionDetails[i+8] !=null ?  transactionDetailsLists.add(transactionDetails[i+8]):null;
    //       transactionDetailsLists.length <=transactionDetails.length  && transactionDetails[i+9] !=null ?  transactionDetailsLists.add(transactionDetails[i+9] ):null;
    //
    //       transactionDetailsLists.length <=transactionDetails.length  && transactionDetails[i+10] !=null ?  transactionDetailsLists.add(transactionDetails[i+10]):null;
    //
    //       transactionDetailsLists.length <=transactionDetails.length  && transactionDetails[i+11] !=null ?  transactionDetailsLists.add(transactionDetails[i+11]):null;
    //       transactionDetailsLists.length <=transactionDetails.length  && transactionDetails[i+12] !=null ?  transactionDetailsLists.add(transactionDetails[i+12]):null;
    //       transactionDetailsLists.length <=transactionDetails.length  && transactionDetails[i+13] !=null ?  transactionDetailsLists.add(transactionDetails[i+13] ):null;
    //
    //       transactionDetailsLists.length <=transactionDetails.length  && transactionDetails[i+14] !=null ?  transactionDetailsLists.add(transactionDetails[i+14] ):null;
    //
    //       //   item1.length <=items.length   && items[i+1] !=null ?  item1.add(items[i+1]):null;
    //       // item1.length <=items.length   && items[i+2] !=null  ?  item1.add(items[i+2]):null;
    //       // item1.length <=items.length   && items[i+3] !=null  ?  item1.add(items[i+3]):null;
    //       // // print( items[i+4]);
    //       //
    //       // item1.length <= items.length   && items[i+3] !=null  ?  item1.add(items[i+4]):null;
    //
    //
    //       // item1.add(items[i+4]);
    //     }
    //     else{
    //
    //     }
    //
    //
    //
    //     return;
    //   }
    //   else{
    //
    //     return;
    //   }
    //
    //
    //   //     }
    // }
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    print("load 351");
    // print(item1.length == items.length);
    // print(items.length.toString());
    // print(item1.length);
    // if()
    setvalue();
    // print(_refreshController.position);

    if (mounted) setState(() {});
    // }
    _refreshController.loadComplete();
  }
}

