// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:dynamicconnectapp/helper/local_db.dart';
// import 'package:dynamicconnectapp/home_list/transaction_view_pages/transaction_view_page.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// import '../constants/constant.dart';
//
//
//
// class SearchImportedDetailsPage extends StatefulWidget {
//   // SearchImportedDetailsPage();
//   SearchImportedDetailsPage(
//       {this.axDocNo,
//       this.transactionType,
//       this.searchKey,
//       this.isContinousScan});
//   final dynamic axDocNo;
//   final dynamic transactionType;
//   final dynamic searchKey;
//   final dynamic isContinousScan;
//
//   @override
//   State<SearchImportedDetailsPage> createState() =>
//       _SearchImportedDetailsPageState();
// }
//
// class _SearchImportedDetailsPageState extends State<SearchImportedDetailsPage> {
//   TextEditingController barcodeController = TextEditingController();
//   final SQLHelper _sqlHelper = SQLHelper();
//
//   bool isLoading = true;
//   ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     getUserData();
//     getTransTypes();
//     getImportedDetailsInit();
//     super.initState();
//   }
//
//   var transType = "";
//
//   getTransTypes() {
//     print(widget.transactionType);
//     if (widget.transactionType == "STOCK COUNT") {
//       setState(() {
//         transType = "STOCK COUNT";
//       });
//     }
//     if (widget.transactionType == "PO") {
//       transType = "PURCHASE ORDER";
//       setState(() {});
//     }
//     if (widget.transactionType == "GRN") {
//       transType = "GOODS RECEIVE";
//       setState(() {});
//     }
//
//     if (widget.transactionType == "RP") {
//       transType = "RETURN PICK";
//       setState(() {});
//     }
//
//     if (widget.transactionType == "RO") {
//       transType = "RETURN ORDER";
//       setState(() {});
//     }
//
//     if (widget.transactionType == "TO") {
//       transType = "TRANSFER ORDER";
//       setState(() {});
//     }
//
//     if (widget.transactionType == "TO-OUT") {
//       transType = "TRANSFER OUT";
//       setState(() {});
//     }
//
//     if (widget.transactionType == "TO-IN") {
//       transType = "TRANSFER IN";
//       setState(() {});
//     }
//   }
//
//   dynamic transactionData;
//   bool? disabledContinuosScan;
//
//   getImportedDetailsInit() async {
//     preferences = await SharedPreferences.getInstance();
//     disabledContinuosScan =
//         preferences?.getString("enableContinuousScan") == "true" ? true : false;
//
//     transactionData =
//         await _sqlHelper.getTRANSHEADER(widget.transactionType == "STOCK COUNT"
//             ? "1"
//             : widget.transactionType == "PO"
//                 ? "3"
//                 : widget.transactionType == "GRN"
//                     ? "4"
//                     : widget.transactionType == "RP"
//                         ? "10"
//                         : widget.transactionType == "TO-OUT"
//                             ? "5"
//                             : widget.transactionType == "TO-IN"
//                                 ? "6"
//                                 : "");
//     print(transactionData);
//     print("document no 107");
//
//     setState(() {});
//
//     // print(widget.searchKey);
//     // // return;
//     // itemImportedLists.addAll(await _sqlHelper.getIMPORTDETAILS(
//     //     itemImportedLists[itemImportedLists.length -1]['id'],
//     //     widget.axDocNo));
//
//     itemImported
//         .addAll(await _sqlHelper.getIMPORTDETAILSByCountInit(widget.axDocNo));
//
//     setState(() {});
//
//     itemImported.addAll(await _sqlHelper.getIMPORTDETAILSByCount(
//         itemImported[itemImported.length - 1]['id'], widget.axDocNo));
//     Future.delayed(const Duration(seconds: 1), () {
//       setState(() {
//         isLoading = false;
//       });
//     });
//
//     if (itemImported.length <= 15) {
//       print("data is less 15");
//       itemImportedLists.addAll(itemImported);
//
//       Future.delayed(const Duration(seconds: 1), () {
//         setState(() {
//           isLoading = false;
//         });
//       });
//     } else {
//       for (var i = 0; i < 15; i++) {
//         itemImportedLists.add(itemImported[i]);
//       }
//       Future.delayed(Duration(seconds: 1), () {
//         setState(() {
//           isLoading = false;
//         });
//       });
//     }
//   }
//
//   List<dynamic> transactionDetails=[];
//   SharedPreferences ? prefs;
//   String? companyCode;
//   String? accessUrl;
//   String? tenantId;
//   String? clientId;
//   String? clientSecretId;
//   String? resource;
//   String? grantType;
//   String ? token;
//
//
//
//   getToken() async {
//     getTransTypes();
//     setState(() {});
//
//
//     print("data is 94 : ${widget.transactionType}");
//     print(transactionData);
//
//     setState(() {});
//     // if (transactionData == "" || transactionData.length == 0) {
//     //   print("list is empty : $transactionData");
//     //   isActivateNew = false;
//     //   isActivateSave = true;
//     // } else {
//     //   print("list is not empty : $transactionData");
//     //   isActivateNew = true;
//     //   isActivateSave = true;
//     // }
//
//
//     transactionDetails =
//
//     await _sqlHelper.getTRANSDETAILSINHeader(widget.transactionType == "STOCK COUNT"
//         ? "1"
//         : widget.transactionType == "PO"
//         ? "3"
//         : widget.transactionType == "GRN"
//         ? "4"
//         : widget.transactionType == "RP"
//         ? "10"
//         : widget.transactionType == "TO-OUT"
//         ? "5"
//         : widget.transactionType == "TO-IN"
//         ? "6"
//         : ""
//        );
//
//
//     print(transactionDetails.length);
//     print("Line 224 ");
//
//     if (transactionDetails.isNotEmpty && transactionData[0]['STATUS'] < 2) {
//       // isCloseTransactions = true;
//       setState(() {});
//     } else {
//       // isCloseTransactions = false;
//       setState(() {});
//     }
//
//     // isPostTransactions =false;
//     // isCloseTransactions =false;
//
//     // if (transactionData.length > 0) {
//     //   transactionData[0]['STATUS'] == 0
//     //       ? isActivateSave = true
//     //       : transactionData[0]['STATUS'] == 2
//     //       ? isPostTransactions = true
//     //       : transactionData[0]['STATUS'] == 3
//     //       ? isActivateNew = false
//     //       : "";
//     //   setState(() {});
//     //   if (transactionData[0]['STATUS'] < 3) {
//     //     // widget.type == 'PO' ?
//     //     // selectLocation =     transactionData[0]['VRLOCATION'].toString() ??"" : selectLocation =  "";
//     //     // widget.type == 'PO' ?
//     //     if (widget.type == 'ST') {
//     //       print("ST ...143");
//     //       selectLocation = transactionData[0]['VRLOCATION']?.toString() ?? "";
//     //     }
//     //     documentNoController?.text = transactionData[0]['DOCNO'] ?? "";
//     //     descriptionController?.text = transactionData[0]['DESCRIPTION'] ?? "";
//     //     selectOrder = transactionData[0]['AXDOCNO'] == ""
//     //         ? null
//     //         : transactionData[0]['AXDOCNO'] ?? "";
//     //     setState(() {});
//     //     if (transactionData[0]['TYPEDESCR'] == "TO") {
//     //       selectStore = transactionData[0]['TOSTORECODE'] ?? "";
//     //       setState(() {});
//     //     }
//     //
//     //     if (transactionData[0]['TYPEDESCR'] == "MJ") {
//     //       selectJournal = transactionData[0]['JournalName'] ?? "";
//     //       setState(() {});
//     //     }
//     //
//     //     print("137 ..data : ${transactionData[0]['AXDOCNO']}");
//     //     print(selectStore);
//     //   }
//     // }
//
//     print("init Api");
//
//
//
//     prefs = await SharedPreferences.getInstance();
//     print("camera status");
//     print(await prefs?.getString("camera"));
//
//     username = await prefs?.getString("username") ??"";
//
//
//     // await prefs?.getString("disableCamera");
//     // disabledCamera = prefs?.getString("disableCamera") == "true" ? true : false;
//
//
//
//     setState(() {});
//     print("uom data available 398");
//
//     print("disables");
//     print(await prefs?.getString("disableCamera"));
//     print(await prefs?.getString("enableUOMSelection").runtimeType);
//     print("disables");
//     print(await prefs?.getString("enableContinuousScan"));
//
//     print(await _sqlHelper.getLastColumnAPPGENERALDATA());
//     print("disables app generals");
//     print(await prefs!.getString("baseUrl"));
//     print(await prefs!.getString("pushStockTakeApi"));
//     pushStockTakeApi = await prefs!.getString("pushStockTakeApi");
//
//     companyCode = await prefs!.getString("companyCode");
//     setState(() {});
//
//
//
//
//     print("update...");
//     // if(baseUrlString=="null"|| baseUrlString == "" || baseUrlString ==null ||
//     //     accessUrl == "null" || accessUrl ==""  || accessUrl ==null){
//     //   Navigator.push(context,
//     //       MaterialPageRoute(builder:(context)=>ProjectSettingsEnvironmentPage()));
//     //   return;
//     // }
//
//     // APIConstants.getTokenUrl
//     // var url = APIConstants.getTokenUrl +
//     //     "?"
//     //         "tenant_id=46f6488b-4363-4b2a-a0b3-4e889a754c02&"
//     //         "client_id=6bfc7b07-0841-4076-b922-9998367d7ced&"
//     //         "client_secret=Qxr7Q~TjBjm0fTKjZzniZyO_llYWrVOrdIYAA"
//     //         "&resource=https://hsins28ce7a8bf606d8744bdevaos.axcloud.dynamics.com&"
//     //         "grant_type=client_credentials";
//
//     var url = "${accessUrl.toString()}/oauth2/token" +
//         "?"
//             "tenant_id=$tenantId&"
//             "client_id=$clientId&"
//             "client_secret=$clientSecretId"
//             "&resource=$resource&"
//             "grant_type=$grantType";
//
//     print(url);
//
//     try {
//       var map = Map<String, dynamic>();
//       map['tenant_id'] = '$tenantId';
//       map['client_id'] = '$clientId';
//       map['client_secret'] = '$clientSecretId';
//       map['resource'] = '$resource';
//       map['grant_type'] = '$grantType';
//
//       http.Response res = await http.post(
//         Uri.parse(url),
//         body: map,
//       );
//       print("res.body");
//       print(res.body);
//       print("res.body");
//
//       var dt = json.decode(res.body);
//       setState(() {
//         token = dt['access_token'].toString();
//       });
//
//
//       // getStoreCode();
//       // getDevices();
//       // getTatmeenDetails();
//       print(token);
//     } catch (e) {}
//   }
//
//
//   List<dynamic> transactionDetailsList = [];
//
//   String? username;
//
//   String? pushStockTakeApi;
//
//
//   showDialogGotData(BuildContext contextMsg ,String text) {
//     // set up the button
//     Widget yesButton = TextButton(
//       style: APPConstants().btnBackgroundYes,
//       child: Text("Ok", style: APPConstants().YesText),
//       onPressed: () {
//         // saveSettings();
//         setState(() {});
//         Navigator.pop(contextMsg);
//       },
//     );
//     //
//     //
//     //
//     // Widget noButton = TextButton(
//     //   child: Text("No"),
//     //   onPressed: () {
//     //     print("Scanning code");
//     //     setState(() {
//     //
//     //     });
//     //     Navigator.pop(context);
//     //   },
//     // );
//
//     // set up the AlertDialog
//     AlertDialog alert = AlertDialog(
//       title: Text("DynamicsConnect"),
//       content: Text(
//         "$text",
//       ),
//       actions: [
//         // noButton,
//         yesButton
//       ],
//     );
//
//     // show the dialog
//     showDialog(
//       barrierDismissible: true,
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }
//
//

//   pushTransactionToPost() async {
//
//     // print(_connectionStatus.runtimeType);
//
//     var tk = 'Bearer ${token.toString()}';
//     Map<String, String> headers = {
//       "Content-type": "application/json",
//       'Authorization': tk
//     };
//
//     transactionDetailsList = [];
//     setState(() {});
//     // if(transactionDetails.length <=0){
//     //   showDialogGotData("");
//     // }
//
//
//     transactionDetails.forEach((element) {
//       print("445 .. line");
//       print(element);
//       var dt = {
//         "DOCNO": element['DOCNO'],
//         "STORECODE": element['STORECODE'],
//         "BARCODE": element['BARCODE'],
//         "TRANSTYPE": element['TRANSTYPE'],
//         "ITEMID": element['ITEMID'],
//         "UOM": element['UOM'],
//         "CONFIGID": element['CONFIGID'],
//         "SIZEID": element['SIZEID'],
//         "COLORID": element['COLORID'],
//         "STYLESID": element['STYLESID'],
//         "QTY": element['QTY'],
//         "BATCHNO": element['BATCHNO'],
//         "EXPDATE": element['EXPDATE'],
//         "PRODDATE": element['PRODDATE'],
//         "BatchEnabled": element['BatchEnabled'] == 1 ? true : false,
//         "BatchedItem": element['BatchedItem'] == 1 ? true : false,
//         "LOCATION": "",
//         "DEVICEID": element['DEVICEID'],
//         "CREATEDDATE": element['CREATEDDATE']
//       };
//       transactionDetailsList.add(dt);
//
//       // print(element);
//     });
//     print(transactionDetailsList.length);
//     print("element transaction list 331");
//     transactionDetailsList.forEach((ele) {
//       print(json.encode(ele));
//     });
//
//     print(activatedStore);
//     print(activatedDevice);
//
//     print(
//         "The line header is : ${transactionData[0]['TRANSTYPE'].runtimeType}");
//
//     // return;
//
//     var body = {
//       "contract": {
//
//
//         //     transType == "STOCK COUNT"
//         //         ? 1
//         //         : widget.type == "GRN"
//         //         ? 4
//         //         : widget.type == "RP"
//         //         ? 10
//         //         : widget.type == "TO-OUT"
//         //         ? 5
//         //         : widget.type == "TO-IN"
//         //         ? 6
//         // : transType == "RETURN ORDER"
//         // ? 9
//         //     : transType == "TRANSFER ORDER"
//         // ? 11
//
//
//         "JournalName": transactionData[0]['TRANSTYPE'].toString() == "22"
//             ? transactionData[0]['JournalName']
//             : "",
//         "DeviceNumSeq": transactionData[0]['TRANSTYPE'].toString() == "1"
//             ? APPGENERALDATASave['STNEXTDOCNO']
//             : transactionData[0]['TRANSTYPE'].toString() == "3"
//             ? APPGENERALDATASave['PONEXTDOCNO']
//             : transactionData[0]['TRANSTYPE'].toString() == "4"
//             ? APPGENERALDATASave['GRNNEXTDOCNO']
//             : transactionData[0]['TRANSTYPE'].toString() == "10"
//             ? APPGENERALDATASave['RPNEXTDOCNO']
//             : transactionData[0]['TRANSTYPE'].toString() == "5"
//             ? APPGENERALDATASave['TOOUTNEXTDOCNO']
//             : transactionData[0]['TRANSTYPE'].toString() == "6"
//             ? APPGENERALDATASave['TOINNEXTDOCNO']
//             : transactionData[0]['TRANSTYPE'].toString() ==
//             "9"
//             ? APPGENERALDATASave['RONEXTDOCNO']
//             : transactionData[0]['TRANSTYPE']
//             .toString() ==
//             "11"
//             ? APPGENERALDATASave['TONEXTDOCNO']
//             : transactionData[0]['TRANSTYPE']
//             .toString() ==
//             "22"
//             ? APPGENERALDATASave['MJNEXTDOCNO']
//             : "",
//
//         "DOCNO": transactionData[0]['DOCNO'],
//         "AXDOCNO":transactionData[0]['AXDOCNO'],
//         "STORECODE": activatedStore,
//         "TOSTORECODE": "",
//         "TRANSTYPE": transactionData[0]['TRANSTYPE'].toString(),
//         "STATUS": transactionData[0]['STATUS'].toString(),
//         "USERNAME": username,
//         "VRLOCATION": transactionData[0]['VRLOCATION']  ?? "0",
//         "DESCRIPTION": transactionData[0]['DESRIPTION']  ?? "",
//         "CREATEDDATE": transactionData[0]['CREATEDDATE'].toString(),
//         "DATAAREAID": companyCode ?? "",
//         "DEVICEID": activatedDevice,
//         "pushdata": transactionDetailsList
//       }
//     };
//
//     print("request body ...435");
//     print(transactionDetailsList.length);
//     print(json.encode(body));
//
//
//     // return;
//
//     // var ur = APIConstants.baseUrl + "pushTransactionTatmeen";
//     var ur = "$pushStockTakeApi";
//     print(ur);
//
//     var js = json.encode(body);
//     // return;
//     var res;
//     var responseJson;
//
//     try {
//       res = await http.post(headers: headers, Uri.parse(ur), body: js);
//
//       responseJson = json.decode(res.body);
//       setState(() {});
//     } catch (e) {
//       Navigator.pop(context);
//       showDialogGotData(context,"Network Error : ${e.toString()}");
//       return;
//     }
//
//     print(res.statusCode);
//
//     print(responseJson);
//
//     if (res.statusCode == 200 || res.statusCode == 201) {
//       print("Post closed success");
//       print(res.body);
//
//
//
//       if (responseJson[0]['Message'].toString().contains("success")) {
//
//         await _sqlHelper.updateStatusStockCount(
//             3, transactionData[0]['DOCNO'] ?? "",
//             "1", transactionData[0]['AXDOCNO']);
//
//         // setState(() {
//         //   // setState(() {
//         //   isActivated = false;
//         //
//         //   isActivateSave = true;
//         //   // });
//         //
//         //   selectStore = null;
//         //   selectLocation = null;
//         //   isActivateNew = false;
//         //   documentNoController?.clear();
//         //   descriptionController?.clear();
//         //   orderNos = [];
//         //   selectJournal ="";
//         //   movementJournals = [];
//         //   selectOrder = null;
//         //   isPostTransactions = false;
//         //   isCloseTransactions = false;
//         // });
//         showDialogGotData(context,
//             "Transaction Posted ${responseJson[0]['Message'].toString()}fully");
//
//       } else {
//         showDialogGotData(context,
//             responseJson[0]['Message'].toString());
//       }
//     } else {
//       showDialogGotData(
//           context,responseJson[0]['Message'].toString());
//     }
//   }
//
//
//   getImportedDetails() async {
//     transactionData =
//         await _sqlHelper.getTRANSHEADER(widget.transactionType == "STOCK COUNT"
//             ? "1"
//             : widget.transactionType == "PO"
//                 ? "3"
//                 : widget.transactionType == "GRN"
//                     ? "4"
//                     : widget.transactionType == "RP"
//                         ? "10"
//                         : widget.transactionType == "TO-OUT"
//                             ? "5"
//                             : widget.transactionType == "TO-IN"
//                                 ? "6"
//                                 : "");
//     print("document no 146");
//     print(transactionData);
//     setState(() {});
//
//     // print(widget.searchKey);
//     // // return;
//     itemImported.addAll(await _sqlHelper.getImportedDetailsBySearch(
//         widget.searchKey, widget.axDocNo));
//     setState(() {});
//
//     if (itemImported.length <= 15) {
//       print("data is less 15");
//       itemImportedLists.addAll(itemImported);
//
//       setState(() {});
//     } else {
//       for (var i = 0; i < 15; i++) {
//         itemImportedLists.add(itemImported[i]);
//       }
//       setState(() {});
//     }
//     if (kDebugMode) {
//       print("data list is : ${itemImported.length}");
//     }
//     Future.delayed(Duration(seconds: 2), () {
//       setState(() {
//         isLoading = false;
//       });
//     });
//   }
//
//   List<dynamic> itemImported = [];
//   List<dynamic> itemImportedLists = [];
//
//   setValueLoadImportedDetails(String? key) async {
//     print("key");
//     print(key);
//
//     itemImported.addAll(
//         await _sqlHelper.getImportedDetailsBySearch(key, widget.axDocNo));
//
//     print(itemImported.length);
//     if (itemImported.length <= 15) {
//       print("data is less 15");
//       itemImportedLists.addAll(itemImported);
//
//       setState(() {});
//     } else {
//       for (var i = 0; i < 15; i++) {
//         itemImportedLists.add(itemImported[i]);
//       }
//     }
//     // return;
//
//     Future.delayed(const Duration(seconds: 2), () {
//       setState(() {
//         isLoading = false;
//       });
//     });
//   }
//
//   set() {
//     for (var i = 0; i < 5; i++) {
//       itemImportedLists.add(itemImported[i]);
//     }
//     setState(() {});
//   }
//
//   dynamic APPGENERALDATASave;
//   dynamic activatedStore;
//   dynamic activatedDevice;
//   SharedPreferences? preferences;
//
//
//   getUserData() async {
//     getTransTypes();
//
//     // password = await prefs?.getString("password");
//
//     APPGENERALDATASave = await _sqlHelper.getLastColumnAPPGENERALDATA();
//     setState(() {});
//     print("69 ... line");
//     print(APPGENERALDATASave.isEmpty);
//     print("71 ... line");
//     if (APPGENERALDATASave != [] || APPGENERALDATASave != null) {
//       print("store codes 72");
//       print(activatedStore);
//       print("store codes 74");
//       setState(() {
//         activatedStore = APPGENERALDATASave['STORECODE'] ?? "";
//         activatedDevice = APPGENERALDATASave['DEVICEID'] ?? "";
//       });
//     }
//   }
//
//   TextEditingController searchController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         automaticallyImplyLeading: false,
//         title: Column(
//           children: [
//             SizedBox(
//               height: 15,
//             ),
//             TextFormField(
//               textInputAction: TextInputAction.go,
//               onFieldSubmitted: (value) async {
//                 var result = await _sqlHelper.getImportedDetailsBySearch(
//                     searchController.text.trim(), widget.axDocNo);
//
//                 print(result.length);
//                 if (result.length > 0) {
//                   setState(() {
//                     isLoading = true;
//                     itemImportedLists = [];
//                     itemImported = [];
//                   });
//
//                   await setValueLoadImportedDetails(
//                       searchController.text.trim());
//                   Future.delayed(const Duration(seconds: 2), () {
//                     setState(() {
//                       isLoading = false;
//                     });
//                   });
//                   return;
//                   print("search is found");
//                 } else {
//                   setState(() {
//                     isLoading = true;
//                     itemImportedLists = [];
//                     itemImported = [];
//                   });
//
//                   Future.delayed(const Duration(seconds: 3), () {
//                     setState(() {
//                       isLoading = false;
//                     });
//                   });
//                   print("search is not found");
//                 }
//               },
//               maxLines: 1,
//               minLines: 1,
//               controller: searchController,
//               decoration: InputDecoration(
//                 isDense: true,
//
//                 // focusColor: Colors.white,
//                 //   fillColor: Colors.white,
//                 fillColor: Colors.white,
//                 hintText: "Search",
//                 hintStyle: TextStyle(color: Colors.black26),
//                 prefixIcon: IconButton(
//                   icon: Icon(Icons.search),
//                   onPressed: () async {
//                     if (searchController.text.trim() == "") {
//                       setState(() {
//                         isLoading = true;
//                         itemImportedLists = [];
//                         itemImported = [];
//                       });
//                       await getImportedDetails();
//
//                       Future.delayed(const Duration(seconds: 2), () {
//                         setState(() {
//                           isLoading = false;
//                         });
//                       });
//                       return;
//                     }
//                     var result = await _sqlHelper.getImportedDetailsBySearch(
//                         searchController.text, widget.axDocNo);
//
//                     print(result.length);
//                     if (result.length > 0) {
//                       setState(() {
//                         isLoading = true;
//                         itemImportedLists = [];
//                         itemImported = [];
//                       });
//                       await setValueLoadImportedDetails(searchController.text);
//                       Future.delayed(Duration(seconds: 2), () {
//                         setState(() {
//                           isLoading = false;
//                         });
//                       });
//
//                       return;
//                       print("search is found");
//                     } else {
//                       setState(() {
//                         isLoading = true;
//                         itemImportedLists = [];
//                         itemImported = [];
//                       });
//
//                       Future.delayed(const Duration(seconds: 3), () {
//                         setState(() {
//                           isLoading = false;
//                         });
//                       });
//
//                       print("search is not found");
//                     }
//                   },
//                 ),
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     Icons.close,
//                     color: Colors.red,
//                   ),
//                   onPressed: () async {
//                     // await _sqlHelper.getItemMatersBySearch(searchController.text);
//                     searchController.clear();
//                     print("search");
//                   },
//                 ),
//                 border: InputBorder.none,
//                 focusedBorder: OutlineInputBorder(
//                   borderSide:
//                       const BorderSide(color: Colors.black54, width: 0.1),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide:
//                       const BorderSide(color: Colors.black54, width: 0.1),
//                 ),
//                 errorBorder: InputBorder.none,
//                 disabledBorder: InputBorder.none,
//
//                 // border: OutlineInputBorder(
//                 //
//                 //   borderSide: const BorderSide(
//                 //       color: Colors.white, width: 0.5),
//                 // ),
//                 // enabledBorder: OutlineInputBorder(
//                 //   borderSide: const BorderSide(
//                 //       color: Colors.white, width: 0.5),
//                 // ),
//                 // borderSide: BorderSide(
//                 //
//                 //   style: BorderStyle.solid,
//                 //   width: 0.1
//                 // ),
//                 //   borderRadius: BorderRadius.circular(20.0)
//               ),
//             ),
//             SizedBox(
//               height: 15,
//             ),
//           ],
//         ),
//       ),
//       body: Container(
//         margin: EdgeInsets.symmetric(horizontal: 20),
//         child: Column(
//           children: [
//             // SizedBox(height: 60,),
//
//             // SizedBox(height: 20,),
//             isLoading
//                 ? Expanded(
//                     child: Container(
//                       height: MediaQuery.of(context).size.height,
//                       child: Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             CupertinoActivityIndicator(
//                               // color: Colors.green,
//                               radius: 50,
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   )
//                 : Expanded(
//                     child: Container(
//                     height: MediaQuery.of(context).size.height,
//                     child: SmartRefresher(
//                       // scrollController: _scrollController,
//                       enablePullDown:
//                           itemImported.length != itemImportedLists.length
//                               ? true
//                               : false,
//                       enablePullUp: true,
//                       header: WaterDropHeader(),
//                       footer: CustomFooter(
//                         builder: (BuildContext? context, LoadStatus? mode) {
//                           Widget body;
//
//
//                           // print(mode == LoadStatus.noMore);
//                           if (itemImported.length == itemImportedLists.length) {
//
//                             body = Container();
//                           } else {}
//                           if (mode == LoadStatus.idle) {
//
//
//                             if (itemImportedLists.length <=
//                                 itemImported.length) {
//                               body = Container()
//                                   // Text("pull up load")
//                                   ;
//                             } else {
//                               body = Container();
//                             }
//                           } else if (mode == LoadStatus.loading &&
//                               itemImportedLists.length != itemImported.length) {
//                             body = CupertinoActivityIndicator(
//                               radius: 20,
//                             );
//                           } else if (mode == LoadStatus.failed) {
//                             body = Text("Load Failed!Click retry!");
//                           } else if (mode == LoadStatus.canLoading) {
//                             body = Text("release to load more");
//                           } else {
//                             body = Container();
//                             // Text("No more Data");
//                           }
//                           return Container(
//                             height: 55.0,
//                             child: Center(child: body),
//                           );
//                         },
//                       ),
//                       controller: _refreshController,
//                       onRefresh: _onRefresh,
//                       onLoading: _onLoading,
//                       child: ListView.builder(
//                         itemBuilder: (context, int index) {
//                           return InkWell(
//                             hoverColor: Colors.red,
//                             onTap: () {},
//                             child: Container(
//                                 decoration: BoxDecoration(
//                                     color: Color(0xfff5deb4),
//                                     // color: Colors.yellow[50],
//                                     borderRadius: BorderRadius.circular(15.0),
//                                     border: Border.all(
//                                         color: Colors.black12, width: 1.2)
//                                     // color: Colors.red,
//                                     ),
//                                 margin: EdgeInsets.only(
//                                     right: 0.0,
//                                     bottom: 10.0,
//                                     top: 10.0,
//                                     left: 0.0),
//                                 padding: EdgeInsets.only(
//                                     left: 10.0, bottom: 15, top: 15),
//                                 //   height: 300,
//
//                                 child: Column(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceAround,
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Expanded(child: Text("Sl No :")),
//                                         Expanded(child: Text("${index + 1}")),
//                                       ],
//                                     ),
//
//                                     Row(
//
//                                       children: [
//                                         // {id: 2, ITEMBARCODE: 3330000307227, ItemId: 33300003,
//                                         //   ItemName: 21ST CENT FOLICACID TAB 100S,
//                                         //   DATAAREAID: 1000, WAREHOUSE: ,
//                                         //   CONFIGID: , COLORID: , SIZEID: , STYLEID: ,
//                                         //   INVENTSTATUS: , QTY: 0.0, UNIT: PACK, ItemAmount: 0.0}
//                                         Expanded(child: Text("Item ID :")),
//
//                                         Expanded(
//                                             child: Text(itemImportedLists[index]
//                                                     ['ITEMID'] ??
//                                                 "")),
//                                         Expanded(
//                                             child: IconButton(
//                                           hoverColor: Colors.red,
//                                           onPressed: () async {
//                                             // print(itemImportedLists[index]
//                                             //     .toString());
//                                             // print(widget.transactionType);
//                                             // print(transType);
//                                             // print(widget.isContinousScan);
//
//                                             // return;
//                                             if (widget.isContinousScan !=
//                                                     null &&
//                                                 widget.isContinousScan &&
//                                                 widget.transactionType ==
//                                                     "STOCK COUNT") {
//                                               var dt = await _sqlHelper
//                                                   .getFindItemExistOrnotTRANSDETAILS(
//                                                       DOCNO: transactionData[0]
//                                                           ['DOCNO'],
//                                                       ITEMID: itemImportedLists[
//                                                           index]['ITEMID'],
//                                                       ITEMNAME:
//                                                           itemImportedLists[index]
//                                                               ['ITEMNAME'],
//                                                       BARCODE:
//                                                           itemImportedLists[index]
//                                                               ['BARCODE'],
//                                                       TRANSTYPE: widget
//                                                                   .transactionType ==
//                                                               "STOCK COUNT"
//                                                           ? 1
//                                                           : widget.transactionType ==
//                                                                   "PURCHASE ORDER"
//                                                               ? 2
//                                                               : "",
//                                                       UOM: itemImportedLists[
//                                                           index]['UOM']);
//
//                                               // print(dt.length);
//
//                                               if (dt.length > 0) {
//
//                                                 if(
//                                                 disabledContinuosScan! &&
//                                                     itemImportedLists[index][
//                                                     'BatchEnabled']
//                                                         .toString() ==
//                                                         "1" &&
//                                                     itemImportedLists[index][
//                                                     'BatchedItem']
//                                                         .toString() ==
//                                                         "0" &&
//                                                     widget.transactionType ==
//                                                         "STOCK COUNT" ||
//                                                     widget.transactionType ==
//                                                         "ST"
//                                                 )
//                                                 {
//
//
//                                                 }
//                                                 else{
//
//
//                                                   await _sqlHelper
//                                                       .updateTRANSDETAILSWithQty(
//                                                       dt[0]['id'],
//                                                       int.parse(
//                                                           dt[0]['QTY']) +
//                                                           1);
//
//                                                 }
//
//
//                                               } else {
//
//                                                 if(
//                                                 disabledContinuosScan! &&
//                                                     itemImportedLists[index][
//                                                     'BatchEnabled']
//                                                         .toString() ==
//                                                         "1" &&
//                                                     itemImportedLists[index][
//                                                     'BatchedItem']
//                                                         .toString() ==
//                                                         "0" &&
//                                                     widget.transactionType ==
//                                                         "STOCK COUNT" ||
//                                                     widget.transactionType ==
//                                                         "ST"
//                                                 ){
//
//                                                   Navigator.push(
//                                                       context,
//                                                       MaterialPageRoute(
//                                                           builder: (context) =>
//                                                               TransactionViewPage(
//                                                                 isImportedSearch:
//                                                                 true,
//                                                                 currentIndex: 1,
//                                                                 pageType: widget
//                                                                     .transactionType,
//                                                                 transDetails:
//                                                                 itemImportedLists[
//                                                                 index],
//                                                               )));
//                                                 }
//                                                 else{
//
//
//                                                   print("adding data 1");
//
//                                                   await _sqlHelper
//                                                       .addTRANSDETAILS(
//
//                                                       HRecId: transactionData[0]
//                                                       ['RecId'],
//                                                       STATUS: 1,
//                                                       AXDOCNO: transactionData[0]
//                                                       ['AXDOCNO'],
//                                                       DOCNO: transactionData[0]
//                                                       ['DOCNO'],
//                                                       ITEMID: itemImportedLists[index]
//                                                       ['ITEMID'],
//                                                       ITEMNAME: itemImportedLists[index]
//                                                       ['ITEMNAME'],
//                                                       TRANSTYPE: widget.transactionType ==
//                                                           "STOCK COUNT"
//                                                           ? 1
//                                                           : widget.transactionType ==
//                                                           "PURCHASE ORDER"
//                                                           ? 2
//                                                           : "",
//                                                       DEVICEID:
//                                                       activatedDevice,
//                                                       QTY: widget.isContinousScan
//
//                                                   ? "0"
//                                                       : itemImportedLists[index]
//                                                       ['QTY'],
//                                                       UOM: itemImportedLists[index]
//                                                       ['UOM'],
//                                                       BARCODE: itemImportedLists[index]
//                                                       ['BARCODE'],
//                                                       CREATEDDATE: DateTime.now()
//                                                           .toString(),
//                                                       INVENTSTATUS: itemImportedLists[index]
//                                                       ['INVENTSTATUS'],
//                                                       SIZEID: itemImportedLists[index]
//                                                       ['SIZEID'],
//                                                       COLORID: itemImportedLists[index]
//                                                       ['COLORID'],
//                                                       CONFIGID:
//                                                       itemImportedLists[index]
//                                                       ['CONFIGID'],
//                                                       STYLESID: itemImportedLists[index]['STYLESID'],
//                                                       STORECODE: activatedStore,
//                                                       LOCATION: transactionData[0]['VRLOCATION'].toString(),
//                                                     BatchEnabled: itemImportedLists[index]['BatchEnabled']
//                                                     .toString()=="1"? true:false,
//                                                     BatchedItem:itemImportedLists[index]['BatchedItem']
//                                                         .toString()=="1"? true:false,
//
//
//                                                   );
//
//
//
//                                                   var  d= {
//                                                     "HRecId": transactionData[0]
//                                                     ['RecId'],
//                                                     "STATUS": 0,
//                                                     "AXDOCNO": transactionData[0]
//                                                     ['AXDOCNO'],
//                                                     "DOCNO": transactionData[0]
//                                                     ['DOCNO'],
//                                                     "ITEMID": itemImportedLists[index]
//                                                     ['ITEMID'],
//                                                     "ITEMNAME": itemImportedLists[index]
//                                                     ['ITEMNAME'],
//                                                     "TRANSTYPE": widget.transactionType ==
//                                                         "STOCK COUNT"
//                                                         ? 1
//                                                         : widget.transactionType ==
//                                                         "PURCHASE ORDER"
//                                                         ? 2
//                                                         : "",
//                                                     "DEVICEID":
//                                                     activatedDevice,
//                                                     "QTY": widget.isContinousScan
//                                                         ? 1
//                                                         : itemImportedLists[index]
//                                                     ['QTY'],
//                                                     "UOM": itemImportedLists[index]
//                                                     ['UOM'],
//                                                     "BARCODE": itemImportedLists[index]
//                                                     ['BARCODE'],
//                                                     "CREATEDDATE": DateTime.now()
//                                                         .toString(),
//                                                     "INVENTSTATUS": itemImportedLists[index]
//                                                     ['INVENTSTATUS'],
//                                                     "SIZEID": itemImportedLists[index]
//                                                     ['SIZEID'],
//                                                     "COLORID": itemImportedLists[index]
//                                                     ['COLORID'],
//                                                     "CONFIGID":
//                                                     itemImportedLists[index]
//                                                     ['CONFIGID'],
//                                                     'STYLESID': itemImportedLists[index]['STYLESID'],
//                                                     "STORECODE": activatedStore,
//                                                     "LOCATION": transactionData[0]['VRLOCATION'].toString()
//                                                   };
//
//
//                                                  await getUserData();
//                                                   List<dynamic > pushedStocks= [];
//                                                   print(await _sqlHelper.getTRANSDETAILSINHeaderByStockCount("1"));
//                                                   // print("The data is ...1216");
//
//                                                   pushedStocks.addAll(await _sqlHelper.getTRANSDETAILSINHeaderByStockCount("1"));
//                                                   if( (widget.transactionType ==
//                                                       "STOCK COUNT" ||
//                                                       widget.transactionType ==
//                                                           "ST") &&
//                                                       pushedStocks.length ==
//                                                           int.parse(APPGENERALDATASave['SetDefaultQtyByOne'].toString())
//                                                   ){
//
//                                                     print("Item Are Equal ... search page");
//                                                     // return;
//                                                    await pushTransactionToPost();
//                                                   }
//
//                                                   print("line 759 .");
//                                                   print(d);
//                                                   return;
//
//
//
//                                                 }
//
//                                                 return;
//                                               }
//
//                                               Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           TransactionViewPage(
//                                                             currentIndex: 1,
//                                                             pageType: widget
//                                                                 .transactionType,
//                                                           )));
//
//                                               if (disabledContinuosScan! &&
//                                                       widget.transactionType ==
//                                                           "STOCK COUNT" ||
//                                                   widget.transactionType ==
//                                                       "ST") {
//                                                 print("BATCH Check line 718");
//
//                                                 print(itemImportedLists[index]
//                                                         ['BatchEnabled']
//                                                     .runtimeType);
//
//                                                 print(itemImportedLists[index]
//                                                     ['BatchedItem']);
//                                               }
//
//
//                                               if (disabledContinuosScan! &&
//                                                       itemImportedLists[index][
//                                                                   'BatchEnabled']
//                                                               .toString() ==
//                                                           "1" &&
//                                                       itemImportedLists[index][
//                                                                   'BatchedItem']
//                                                               .toString() ==
//                                                           "0" &&
//                                                       widget.transactionType ==
//                                                           "STOCK COUNT" ||
//                                                   widget.transactionType ==
//                                                       "ST") {
//
//
//                                                 Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             TransactionViewPage(
//                                                               isImportedSearch:
//                                                                   true,
//                                                               currentIndex: 1,
//                                                               pageType: widget
//                                                                   .transactionType,
//                                                               transDetails:
//                                                                   itemImportedLists[
//                                                                       index],
//                                                             )));
//                                               } else {
//                                                 if (disabledContinuosScan! &&
//                                                         widget.transactionType ==
//                                                             "STOCK COUNT" ||
//                                                     widget.transactionType ==
//                                                         "ST") {
//
//                                                   List<dynamic > pushedStocks= [];
//
//                                                   pushedStocks.addAll(await _sqlHelper.getTRANSDETAILSINHeaderByStockCount("1"));
//                                                   if( (widget.transactionType ==
//                                                       "STOCK COUNT" ||
//                                                       widget.transactionType ==
//                                                           "ST") &&
//                                                       pushedStocks.length ==
//                                                           int.parse(APPGENERALDATASave['SetDefaultQtyByOne'].toString())
//                                                   ){
//
//                                                     print("Item Are Equal ...");
//                                                     // return;
//                                                   await  pushTransactionToPost();
//                                                   }
//
//                                                   ScaffoldMessenger.of(context)
//                                                       .showSnackBar(
//                                                     const SnackBar(
//                                                         backgroundColor:
//                                                             Colors.red,
//                                                         content: Text(
//                                                           'Item Adding Successfully',
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                         )),
//                                                   );
//
//
//
//
//
//
//
//
//
//
//                                                 } else {
//                                                   Navigator.push(
//                                                       context,
//                                                       MaterialPageRoute(
//                                                           builder: (context) =>
//                                                               TransactionViewPage(
//                                                                 isImportedSearch:
//                                                                     true,
//                                                                 currentIndex: 1,
//                                                                 pageType: widget
//                                                                     .transactionType,
//                                                                 transDetails:
//                                                                     itemImportedLists[
//                                                                         index],
//                                                               )));
//                                                 }
//                                               }
//                                             } else {
//                                               Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           TransactionViewPage(
//                                                             isImportedSearch:
//                                                                 true,
//                                                             currentIndex: 1,
//                                                             pageType: widget
//                                                                 .transactionType,
//                                                             transDetails:
//                                                                 itemImportedLists[
//                                                                     index],
//                                                           )));
//
//                                               // if(     disabledContinuosScan! &&
//                                               //     widget
//                                               //         .transactionType == "STOCK COUNT" ||
//                                               //     widget
//                                               //         .transactionType == "ST"){
//
//                                               // }
//
//                                               if (disabledContinuosScan! &&
//                                                       widget.transactionType ==
//                                                           "STOCK COUNT" ||
//                                                   widget.transactionType ==
//                                                       "ST") {
//                                                 print("BATCH Check line 718");
//
//                                                 print(itemImportedLists[index]
//                                                     ['BatchEnabled']);
//
//                                                 print(itemImportedLists[index]
//                                                     ['BatchedItem']);
//                                                 List<dynamic> pushedStocks= [];
//                                                 pushedStocks.addAll(await _sqlHelper.getTRANSDETAILSINHeaderByStockCount("1"));
//                                                 if( (widget.transactionType ==
//                                                     "STOCK COUNT" ||
//                                                     widget.transactionType ==
//                                                         "ST") &&
//                                                     pushedStocks.length ==
//                                                         int.parse(APPGENERALDATASave['SetDefaultQtyByOne'].toString())
//                                                 )
//                                                 {
//
//                                                   print("Item Are Equal ...");
//                                                   // return;
//                                                  await pushTransactionToPost();
//                                                 }
//
//                                                 ScaffoldMessenger.of(context)
//                                                     .showSnackBar(
//                                                   const SnackBar(
//                                                       backgroundColor:
//                                                           Colors.red,
//                                                       content: Text(
//                                                         'Item Adding Successfully',
//                                                         textAlign:
//                                                             TextAlign.center,
//                                                       )),
//                                                 );
//
//
//
//
//
//                                               } else {}
//
//                                               //   ?
//                                               // :null;
//                                             }
//
//
//
//                                             print("adding data 2");
//                                             await _sqlHelper.addTRANSDETAILS(
//                                                 HRecId: transactionData[0]
//                                                     ['RecId'],
//                                                 STATUS: 0,
//                                                 AXDOCNO: transactionData[0]
//                                                     ['AXDOCNO'],
//                                                 DOCNO: transactionData[0]
//                                                     ['DOCNO'],
//                                                 ITEMID: itemImportedLists[index]
//                                                     ['ITEMID'],
//                                                 ITEMNAME: itemImportedLists[index]
//                                                     ['ITEMNAME'],
//                                                 TRANSTYPE: widget.transactionType ==
//                                                         "STOCK COUNT"
//                                                     ? 1
//                                                     : "",
//                                                 DEVICEID: activatedDevice,
//                                                 QTY: widget.isContinousScan
//                                                     ? 1
//                                                     : itemImportedLists[index]
//                                                         ['QTY'],
//                                                 UOM: itemImportedLists[index]
//                                                     ['UOM'],
//                                                 BARCODE: itemImportedLists[index]
//                                                     ['BARCODE'],
//                                                 CREATEDDATE:
//                                                     DateTime.now().toString(),
//                                                 INVENTSTATUS: itemImportedLists[index]
//                                                     ['INVENTSTATUS'],
//                                                 SIZEID: itemImportedLists[index]
//                                                     ['SIZEID'],
//                                                 COLORID: itemImportedLists[index]['COLORID'],
//                                                 CONFIGID: itemImportedLists[index]['CONFIGID'],
//                                                 STYLESID: itemImportedLists[index]['STYLESID'],
//                                                 STORECODE: activatedStore,
//                                                 LOCATION: transactionData[0]['VRLOCATION'].toString());
//
//
//
//
//                                             Navigator.push(
//                                                 context,
//                                                 MaterialPageRoute(
//                                                     builder: (context) =>
//                                                         TransactionViewPage(
//                                                           currentIndex: 1,
//                                                           pageType: widget
//                                                               .transactionType,
//                                                         )));
//                                           },
//                                           icon: Icon(
//                                             Icons.downloading_outlined,
//                                             color: Colors.red,
//                                             size: 45,
//                                           ),
//                                         ))
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       height: 20,
//                                     ),
//                                     Row(
//                                       children: [
//                                         Expanded(child: Text("BARCODE  :")),
//                                         Expanded(
//                                             child: Text(itemImportedLists[index]
//                                                     ['BARCODE'] ??
//                                                 ""))
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Row(
//                                       children: [
//                                         Expanded(child: Text("Item Name :")),
//                                         Expanded(
//                                             child: Text(itemImportedLists[index]
//                                                     ['ITEMNAME'] ??
//                                                 ""))
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Row(
//                                       children: [
//                                         Expanded(child: Text("Unit :")),
//                                         Expanded(
//                                             child: Text(itemImportedLists[index]
//                                                     ['UOM'] ??
//                                                 ""))
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Row(
//                                       children: [
//                                         Expanded(child: Text("Style :")),
//                                         Expanded(
//                                             child: Text(itemImportedLists[index]
//                                                     ['SIZEID'] ??
//                                                 ""))
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Row(
//                                       children: [
//                                         Expanded(child: Text("Config :")),
//                                         Expanded(
//                                             child: Text(itemImportedLists[index]
//                                                     ['CONFIGID'] ??
//                                                 ""))
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Row(
//                                       children: [
//                                         Expanded(child: Text("Color :")),
//                                         Expanded(
//                                             child: Text(itemImportedLists[index]
//                                                     ['COLORID'] ??
//                                                 ""))
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Row(
//                                       children: [
//                                         Expanded(child: Text("Size :")),
//                                         Expanded(
//                                             child: Text(itemImportedLists[index]
//                                                     ['SIZEID'] ??
//                                                 ""))
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                             child: Text("Batched Enabled:")),
//                                         Expanded(
//                                             child: Text(itemImportedLists[index]
//                                                             ['BatchEnabled']
//                                                         .toString() ==
//                                                     "1"
//                                                 ? "true"
//                                                 : "false")),
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Row(
//                                       children: [
//                                         Expanded(child: Text("Batched Item:")),
//                                         Expanded(
//                                             child: Text(itemImportedLists[index]
//                                                             ['BatchedItem']
//                                                         .toString() ==
//                                                     "1"
//                                                 ? "true"
//                                                 : "false")),
//                                       ],
//                                     ),
//                                     // Row(
//                                     //   children: [
//                                     //     Expanded(child: Text("Item ID :")),
//                                     //     Expanded(child: Text("30300"))
//                                     //   ],
//                                     // ),
//                                   ],
//                                 )),
//                           );
//                         },
//
//                         // itemBuilder: (c, i) => Card(child: Center(child: Text(items[i]))),
//                         // itemExtent: 300.0,
//                         itemCount: itemImportedLists.length,
//                       ),
//                     ),
//                   ))
//           ],
//         ),
//       ),
//     );
//   }
//
//   List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];
//   List<String> item1 = [];
//   RefreshController _refreshController =
//       RefreshController(initialRefresh: false);
//
//   void _onRefresh() async {
//     // monitor network fetch
//     await Future.delayed(Duration(milliseconds: 1000));
//     // if failed,use refreshFailed()
//     _refreshController.refreshCompleted();
//   }
//
//   setvalue() async {
//     itemImportedLists.addAll(await _sqlHelper.getIMPORTDETAILS(
//         itemImportedLists[itemImportedLists.length - 1]['id'], widget.axDocNo));
//
//     print("data list is : ${itemImported.length}");
//     Future.delayed(const Duration(seconds: 2), () {
//       setState(() {
//         isLoading = false;
//       });
//     });
//
//     return;
//     for (var i = itemImportedLists.length - 1;
//         i < itemImported.length - 1;
//         i++) {
//       var u = 0;
//       u++;
//
//       // item1.add(items[i-1]);
//       // print("contains value");
//       // print(!item1.any((element) => element.contains(items[i])));
//       //     if(!item1.any((element) => element.contains(items[i]))){
//       if (u < 4) {
//         print("contains value items : ${itemImported.length.toString()}");
//         print("contains value item1 : ${itemImportedLists.length.toString()}");
//         if (itemImportedLists.length <= itemImported.length) {
//           print(itemImportedLists[i]);
//           // item1.add(items[i]);
//           // item1.add(items[i+1]);
//           // item1.add(items[i+2]);
//
//           itemImportedLists.length <= itemImported.length &&
//                   itemImported[i] != null
//               ? itemImportedLists.add(itemImported[i])
//               : null;
//
//           itemImportedLists.length <= itemImported.length &&
//                   itemImported[i + 1] != null
//               ? itemImportedLists.add(itemImported[i + 1])
//               : null;
//
//           itemImportedLists.length <= itemImported.length &&
//                   itemImported[i + 2] != null
//               ? itemImportedLists.add(itemImported[i + 2])
//               : null;
//
//           itemImportedLists.length <= itemImported.length &&
//                   itemImported[i + 3] != null
//               ? itemImportedLists.add(itemImported[i + 3])
//               : null;
//           itemImportedLists.length <= itemImported.length &&
//                   itemImported[i + 4] != null
//               ? itemImportedLists.add(itemImported[i + 4])
//               : null;
//
//           itemImportedLists.length <= itemImported.length &&
//                   itemImported[i + 5] != null
//               ? itemImportedLists.add(itemImported[i + 5])
//               : null;
//
//           itemImportedLists.length <= itemImported.length &&
//                   itemImported[i + 6] != null
//               ? itemImportedLists.add(itemImported[i + 6])
//               : null;
//
//           itemImportedLists.length <= itemImported.length &&
//                   itemImported[i + 7] != null
//               ? itemImportedLists.add(itemImported[i + 7])
//               : null;
//           itemImportedLists.length <= itemImported.length &&
//                   itemImported[i + 8] != null
//               ? itemImportedLists.add(itemImported[i + 8])
//               : null;
//           itemImportedLists.length <= itemImported.length &&
//                   itemImported[i + 9] != null
//               ? itemImportedLists.add(itemImported[i + 9])
//               : null;
//
//           itemImportedLists.length <= itemImported.length &&
//                   itemImported[i + 10] != null
//               ? itemImportedLists.add(itemImported[i + 10])
//               : null;
//
//           itemImportedLists.length <= itemImported.length &&
//                   itemImported[i + 11] != null
//               ? itemImportedLists.add(itemImported[i + 11])
//               : null;
//           itemImportedLists.length <= itemImported.length &&
//                   itemImported[i + 12] != null
//               ? itemImportedLists.add(itemImported[i + 12])
//               : null;
//           itemImportedLists.length <= itemImported.length &&
//                   itemImported[i + 13] != null
//               ? itemImportedLists.add(itemImported[i + 13])
//               : null;
//
//           itemImportedLists.length <= itemImported.length &&
//                   itemImported[i + 14] != null
//               ? itemImportedLists.add(itemImported[i + 14])
//               : null;
//
//           //   item1.length <=items.length   && items[i+1] !=null ?  item1.add(items[i+1]):null;
//           // item1.length <=items.length   && items[i+2] !=null  ?  item1.add(items[i+2]):null;
//           // item1.length <=items.length   && items[i+3] !=null  ?  item1.add(items[i+3]):null;
//           // // print( items[i+4]);
//           //
//           // item1.length <= items.length   && items[i+3] !=null  ?  item1.add(items[i+4]):null;
//
//           // item1.add(items[i+4]);
//         } else {
//           item1.toSet().toList();
//           setState(() {});
//         }
//
//         return;
//       } else {
//         item1.toSet().toList();
//         setState(() {});
//         return;
//       }
//
//       //     }
//     }
//     item1.toSet().toList();
//     setState(() {});
//   }
//
//   void _onLoading() async {
//     // monitor network fetch
//     await Future.delayed(Duration(milliseconds: 1000));
//     // if failed,use loadFailed(),if no data return,use LoadNodata()
//     print("load 351");
//     // print(item1.length == items.length);
//     // print(items.length.toString());
//     // print(item1.length);
//     setvalue();
//     // print(_refreshController.position);
//
//     if (mounted) setState(() {});
//     // }
//     _refreshController.loadComplete();
//   }
//
// // @override
//   // Widget build(BuildContext context) {
//   //   return Scaffold(
//   //     body: Column(children: [
//   //       Container(
//   //         margin: EdgeInsets.symmetric(horizontal: 10),
//   //         height: 35,
//   //         child: TextFormField(
//   //           validator: (value) =>
//   //           value!.isEmpty ? 'Required *' : null,
//   //           controller: barcodeController,
//   //           decoration: InputDecoration(
//   //               suffixIcon: IconButton(
//   //                 onPressed: (){
//   //
//   //                 }, icon: Icon(Icons.manage_search,
//   //                 size: 20,
//   //               ),
//   //               ),
//   //               isDense: true,
//   //               contentPadding: EdgeInsets.only(
//   //                   left: 15, right: 15, top: 2, bottom: 2),
//   //               hintText: "Bar Code",
//   //               border: OutlineInputBorder(
//   //                 borderRadius: BorderRadius.circular(7.0),
//   //                 // borderSide: Border()
//   //               )),
//   //         ),
//   //       ),
//   //     ],)
//   //   );
//   // }
// }


import 'dart:convert';
import 'dart:developer';

import 'package:dynamicconnectapp/helper/local_db.dart';
import 'package:dynamicconnectapp/home_list/transaction_view_pages/transaction_view_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constant.dart';
import 'package:http/http.dart' as http;

class SearchImportedDetailsPage extends StatefulWidget {
  // SearchImportedDetailsPage();
  SearchImportedDetailsPage(
      {this.axDocNo,
        this.transactionType,
        this.searchKey,
        this.isContinousScan});
  final dynamic axDocNo;
  final dynamic transactionType;
  final dynamic searchKey;
  final dynamic isContinousScan;

  @override
  State<SearchImportedDetailsPage> createState() =>
      _SearchImportedDetailsPageState();
}

class _SearchImportedDetailsPageState extends State<SearchImportedDetailsPage> {
  TextEditingController barcodeController = TextEditingController();
  final SQLHelper _sqlHelper = SQLHelper();

  bool isLoading = true;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {

    getUserData();
    getTransTypes();
    getImportedDetailsInit();
    getToken();
    super.initState();
  }

  var transType = "";

  getTransTypes() {
    print(widget.transactionType);
    if (widget.transactionType == "STOCK COUNT") {
      setState(() {
        transType = "STOCK COUNT";
      });
    }
    if (widget.transactionType == "PO") {
      transType = "PURCHASE ORDER";
      setState(() {});
    }
    if (widget.transactionType == "GRN") {
      transType = "GOODS RECEIVE";
      setState(() {});
    }

    if (widget.transactionType == "RP") {
      transType = "RETURN PICK";
      setState(() {});
    }

    if (widget.transactionType == "RO") {
      transType = "RETURN ORDER";
      setState(() {});
    }

    if (widget.transactionType == "TO") {
      transType = "TRANSFER ORDER";
      setState(() {});
    }

    if (widget.transactionType == "TO-OUT") {
      transType = "TRANSFER OUT";
      setState(() {});
    }

    if (widget.transactionType == "TO-IN") {
      transType = "TRANSFER IN";
      setState(() {});
    }
  }



  dynamic transactionData;
  bool? disabledContinuosScan;

  getImportedDetailsInit() async {
    preferences = await SharedPreferences.getInstance();
    disabledContinuosScan =
    preferences?.getString("enableContinuousScan") == "true" ? true : false;

    transactionData =
    await _sqlHelper.getTRANSHEADER(widget.transactionType == "STOCK COUNT"
        ? "1"
        : widget.transactionType == "PO"
        ? "3"
        : widget.transactionType == "GRN"
        ? "4"
        : widget.transactionType == "RP"
        ? "10"
        : widget.transactionType == "TO-OUT"
        ? "5"
        : widget.transactionType == "TO-IN"
        ? "6"
        : "");
    print(transactionData);
    print("document no 107");

    setState(() {});

    // print(widget.searchKey);
    // // return;
    // itemImportedLists.addAll(await _sqlHelper.getIMPORTDETAILS(
    //     itemImportedLists[itemImportedLists.length -1]['id'],
    //     widget.axDocNo));

    itemImported
        .addAll(
      widget.transactionType == "STOCK COUNT" ||
           widget.transactionType == "ST"?
          await _sqlHelper.getIMPORTDETAILSByCountInitStockCount(widget.axDocNo):
        await _sqlHelper.getIMPORTDETAILSByCountInit(widget.axDocNo));

    setState(() {});

    itemImported.addAll(
        widget.transactionType == "STOCK COUNT" ||
            widget.transactionType == "ST"?
        await _sqlHelper.getIMPORTDETAILSByCountStockCount(
            itemImported[itemImported.length - 1]['id'], widget.axDocNo)
            :
        await _sqlHelper.getIMPORTDETAILSByCount(
        itemImported[itemImported.length - 1]['id'], widget.axDocNo));
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });

    if (itemImported.length <= 15) {
      print("data is less 15");
      itemImportedLists.addAll(itemImported);

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          isLoading = false;
        });
      });
    } else {
      for (var i = 0; i < 15; i++) {
        itemImportedLists.add(itemImported[i]);
      }
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          isLoading = false;
        });
      });
    }
  }
  SharedPreferences ? prefs;
  String ? username;
  String ? companyCode;
  String ? baseUrlString;
  String ? accessUrl;
String ?   tenantId;
  String ?  clientId;
  String ?   clientSecretId ;
  String ?  resource;
  String ?  grantType;
  String ?  pullStockTakeApi;
  String ?  pushStockTakeApi;

  String ?  getDevice ;
  String ?  getStore;

  List<dynamic> transactionDetails =[];

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


  showDialogGotData(BuildContext contextMsg ,String text) {
    // set up the button
    Widget yesButton = TextButton(
      style: APPConstants().btnBackgroundYes,
      child: Text("Ok", style: APPConstants().YesText),
      onPressed: () {
        // saveSettings();
        setState(() {});
        Navigator.pop(contextMsg);
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


  getToken() async {

    getTransTypes();
    setState(() {});


    transactionDetails =
    await _sqlHelper.getTRANSDETAILSINHeader(widget.transactionType == "STOCK COUNT"
        ? "1"
        : widget.transactionType == "PO"
        ? "3"
        : widget.transactionType == "GRN"
        ? "4"
        : widget.transactionType == "RP"
        ? "10"
        : widget.transactionType == "TO-OUT"
        ? "5"
        : widget.transactionType == "TO-IN"
        ? "6"
        : "");


    print(transactionDetails.length);
    print("Line 2094 ");

    // if (transactionDetails.isNotEmpty && transactionData[0]['STATUS'] < 2) {
    //   // isCloseTransactions = true;
    //   setState(() {});
    // } else {
    //   // isCloseTransactions = false;
    //   setState(() {});
    // }

    print("init Api");



    prefs = await SharedPreferences.getInstance();
    print("camera status");
    print(await prefs?.getString("camera"));

    username = await prefs?.getString("username") ??"";



    await prefs?.getString("enableContinuousScan");
    disabledContinuosScan =
    await prefs?.getString("enableContinuousScan") == "true"
        ? true
        : false;

     await prefs!.setBool("lineDeleted", false);
    // showQuantityExceed = await prefs?.getBool("showQuantityExceed") == null ||
    //     await prefs?.getBool("showQuantityExceed") == false
    //     ? false
    //     : true;
    setState(() {});
    print("uom data available 398");
    // if (disabledUOMSelection == "true") {
    //   print("uom data available 400");
    //   getUOM();
    // }
    print("disables");
    print(await prefs?.getString("disableCamera"));
    print(await prefs?.getString("enableUOMSelection").runtimeType);
    print("disables");
    print(await prefs?.getString("enableContinuousScan"));

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

    pushStockTakeApi =await  prefs!.getString("pushStockTakeApi");
    setState((){

    });

    getDevice = await prefs!.getString("getDevice");
    getStore = await prefs!.getString("getStore");

    print("...169");


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

      // getStoreCode();
      // getDevices();
      // getTatmeenDetails();
      // print(token);
    } catch (e) {}
  }

  List<dynamic> transactionDetailsList = [];
  String ? token;

  pushTransactionToPost() async {

    // print(_connectionStatus.runtimeType);

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

        "DOCNO": transactionData[0]['DOCNO'],
        "AXDOCNO":transactionData[0]['AXDOCNO'],
        "STORECODE": activatedStore,
        "TOSTORECODE": "",
        "TRANSTYPE": transactionData[0]['TRANSTYPE'].toString(),
        "STATUS": transactionData[0]['STATUS'].toString(),
        "USERNAME": username,
        "VRLOCATION": transactionData[0]['VRLOCATION']  ?? "0",
        "DESCRIPTION": transactionData[0]['DESRIPTION']  ?? "",
        "CREATEDDATE": transactionData[0]['CREATEDDATE'].toString(),
        "DATAAREAID": companyCode ?? "",
        "DEVICEID": activatedDevice,
        "pushdata": transactionDetailsList
      }
    };

    print("request body ...435 ");
    print(transactionDetailsList.length);
    print(json.encode(body));


    // return;


    // var ur = APIConstants.baseUrl + "pushTransactionTatmeen";
    var ur = "$pushStockTakeApi";
    print(ur);

    print("request body ...435 $ur");

    var js = json.encode(body);
    // return;
    var res;
    var responseJson;

    try {
      res = await http.post(headers: headers, Uri.parse(ur), body: js);

      responseJson = json.decode(res.body);
      setState(() {});
    } catch (e) {
      // Navigator.pop(context);
      showDialogGotData(context,"Network Error : ${e.toString()}");
      return;
    }

    print(res.statusCode);

    print(responseJson);

    if (res.statusCode == 200 || res.statusCode == 201) {
      print("Post closed success");
      print(res.body);


       print(responseJson[0]['Message'].toString().contains("success"));

       print("Msg response");
      if (responseJson[0]['Message'].toString().contains("success"))
      {



        await _sqlHelper.updateStatusStockCount(
            2, transactionData[0]['DOCNO'] ?? "",
            "1", transactionData[0]['AXDOCNO']);

        // setState(() {
        //   // setState(() {
        //   isActivated = false;
        //
        //   isActivateSave = true;
        //   // });
        //
        //   selectStore = null;
        //   selectLocation = null;
        //   isActivateNew = false;
        //   documentNoController?.clear();
        //   descriptionController?.clear();
        //   orderNos = [];
        //   selectJournal ="";
        //   movementJournals = [];
        //   selectOrder = null;
        //   isPostTransactions = false;
        //   isCloseTransactions = false;
        // });




        // ScaffoldMessenger.of(context)
        //     .showSnackBar(
        //   const SnackBar(
        //       backgroundColor:
        //       Colors.red,
        //       content: Text(
        //         'Item Adding Successfully',
        //         textAlign:
        //         TextAlign.center,
        //       )),
        // );
        //
        // Future.delayed(Duration(seconds: 3),(){
        //   ScaffoldMessenger.of(context).clearSnackBars();
        // });


        // WidgetsBinding.instance.addPostFrameCallback((_) async {
        //   showDialogGotRoute(
        //       op:
        Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TransactionViewPage(
                            currentIndex: 1,
                            isImportedSearch: true,
                            pageType: widget
                                .transactionType,
                          )));
    // ,
    //           text: "Transaction Posted ${responseJson[0]['Message'].toString()}fully");
    //     });





      } else {
        showDialogGotData(context,
            responseJson[0]['Message'].toString());
      }
    } else {
      showDialogGotData(
          context,responseJson[0]['Message'].toString());
    }
  }


  getImportedDetails() async
  {
    transactionData =
    await _sqlHelper.getTRANSHEADER(
        widget.transactionType == "STOCK COUNT"
        ? "1"
        : widget.transactionType == "PO"
        ? "3"
        : widget.transactionType == "GRN"
        ? "4"
        : widget.transactionType == "RP"
        ? "10"
        : widget.transactionType == "TO-OUT"
        ? "5"
        : widget.transactionType == "TO-IN"
        ? "6"
        : "");
    print("document no 146");
    print(transactionData);
    setState(() {});

    // print(widget.searchKey);
    // // return;
    itemImported.addAll(
      widget.transactionType== "STOCK COUNT" ||
          widget.transactionType == "ST" ?
          await _sqlHelper.getImportedDetailsBySearchStockCount(
          widget.searchKey, widget.axDocNo)
          :
        await _sqlHelper.getImportedDetailsBySearch(
        widget.searchKey, widget.axDocNo));
    setState(() {});

    if (itemImported.length <= 15) {
      print("data is less 15");
      itemImportedLists.addAll(itemImported);

      setState(() {});
    } else {
      for (var i = 0; i < 15; i++) {
        itemImportedLists.add(itemImported[i]);
      }
      setState(() {});
    }
    if (kDebugMode) {
      print("data list is : ${itemImported.length}");
    }
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  List<dynamic> itemImported = [];
  List<dynamic> itemImportedLists = [];

  setValueLoadImportedDetails(String? key) async {
    print("key");
    print(key);

    itemImported.addAll(
        widget.transactionType== "STOCK COUNT" ||
            widget.transactionType == "ST" ?
        await _sqlHelper.getImportedDetailsBySearchStockCount(
            widget.searchKey, widget.axDocNo)
            :
        await _sqlHelper.getImportedDetailsBySearch(key, widget.axDocNo));

    print(itemImported.length);
    if (itemImported.length <= 15) {
      print("data is less 15");
      itemImportedLists.addAll(itemImported);

      setState(() {});
    } else {
      for (var i = 0; i < 15; i++) {
        itemImportedLists.add(itemImported[i]);
      }
    }
    // return;

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  set() {
    for (var i = 0; i < 5; i++) {
      itemImportedLists.add(itemImported[i]);
    }
    setState(() {});
  }

  dynamic APPGENERALDATASave;
  dynamic activatedStore;
  dynamic activatedDevice;
  SharedPreferences? preferences;

  getUserData() async {
    getTransTypes();

    // password = await prefs?.getString("password");

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

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            TextFormField(
              textInputAction: TextInputAction.go,
              onFieldSubmitted: (value)
              async
              {
                var result =
                widget.transactionType== "STOCK COUNT" ||
                    widget.transactionType == "ST" ?
                await _sqlHelper.getImportedDetailsBySearchStockCount(
                    widget.searchKey, widget.axDocNo)
                    :
                await _sqlHelper.getImportedDetailsBySearch(
                    searchController.text.trim(), widget.axDocNo);

                print(result.length);
                if (result.length > 0) {
                  setState(() {
                    isLoading = true;
                    itemImportedLists = [];
                    itemImported = [];
                  });

                  await setValueLoadImportedDetails(
                      searchController.text.trim());
                  Future.delayed(const Duration(seconds: 2), () {
                    setState(() {
                      isLoading = false;
                    });
                  });
                  return;
                  print("search is found");
                } else {
                  setState(() {
                    isLoading = true;
                    itemImportedLists = [];
                    itemImported = [];
                  });

                  Future.delayed(const Duration(seconds: 3), () {
                    setState(() {
                      isLoading = false;
                    });
                  });
                  print("search is not found");
                }
              },
              maxLines: 1,
              minLines: 1,
              controller: searchController,
              decoration: InputDecoration(
                isDense: true,

                // focusColor: Colors.white,
                //   fillColor: Colors.white,
                fillColor: Colors.white,
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.black26),
                prefixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    if (searchController.text.trim() == "") {
                      setState(() {
                        isLoading = true;
                        itemImportedLists = [];
                        itemImported = [];
                      });
                      await getImportedDetails();

                      Future.delayed(const Duration(seconds: 2), () {
                        setState(() {
                          isLoading = false;
                        });
                      });
                      return;
                    }
                    var result =
                    widget.transactionType== "STOCK COUNT" ||
                        widget.transactionType == "ST" ?
                    await _sqlHelper.getImportedDetailsBySearchStockCount(
                        widget.searchKey, widget.axDocNo)
                        :
                    await _sqlHelper.getImportedDetailsBySearch(
                        searchController.text, widget.axDocNo);

                    print(result.length);
                    if (result.length > 0) {
                      setState(() {
                        isLoading = true;
                        itemImportedLists = [];
                        itemImported = [];
                      });
                      await setValueLoadImportedDetails(searchController.text);
                      Future.delayed(Duration(seconds: 2), () {
                        setState(() {
                          isLoading = false;
                        });
                      });

                      return;
                      print("search is found");
                    } else {
                      setState(() {
                        isLoading = true;
                        itemImportedLists = [];
                        itemImported = [];
                      });

                      Future.delayed(const Duration(seconds: 3), () {
                        setState(() {
                          isLoading = false;
                        });
                      });

                      print("search is not found");
                    }
                  },
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    // await _sqlHelper.getItemMatersBySearch(searchController.text);
                    searchController.clear();
                    print("search");
                  },
                ),
                border: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderSide:
                  const BorderSide(color: Colors.black54, width: 0.1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                  const BorderSide(color: Colors.black54, width: 0.1),
                ),
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,

                // border: OutlineInputBorder(
                //
                //   borderSide: const BorderSide(
                //       color: Colors.white, width: 0.5),
                // ),
                // enabledBorder: OutlineInputBorder(
                //   borderSide: const BorderSide(
                //       color: Colors.white, width: 0.5),
                // ),
                // borderSide: BorderSide(
                //
                //   style: BorderStyle.solid,
                //   width: 0.1
                // ),
                //   borderRadius: BorderRadius.circular(20.0)
              ),
            ),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // SizedBox(height: 60,),

            // SizedBox(height: 20,),
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
                    enablePullDown:
                    itemImported.length != itemImportedLists.length
                        ? true
                        : false,
                    enablePullUp: true,
                    header: WaterDropHeader(),
                    footer: CustomFooter(
                      builder: (BuildContext? context, LoadStatus? mode) {
                        Widget body;
                        // print("last index 272");
                        // print(mode);
                        // print(mode?.index == items.length-1);
                        print(mode == LoadStatus.noMore);
                        if (itemImported.length == itemImportedLists.length) {
                          // print("full loaded");
                          body = Container();
                        } else {}
                        if (mode == LoadStatus.idle) {


                          if (itemImportedLists.length <=
                              itemImported.length) {
                            body = Container()
                            // Text("pull up load")
                                ;
                          } else {
                            body = Container();
                          }
                        } else if (mode == LoadStatus.loading &&
                            itemImportedLists.length != itemImported.length) {
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
                        return InkWell(
                          hoverColor: Colors.red,
                          onTap: () {},
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Color(0xfff5deb4),
                                  // color: Colors.yellow[50],
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(
                                      color: Colors.black12, width: 1.2)
                                // color: Colors.red,
                              ),
                              margin: EdgeInsets.only(
                                  right: 0.0,
                                  bottom: 10.0,
                                  top: 10.0,
                                  left: 0.0),
                              padding: EdgeInsets.only(
                                  left: 10.0, bottom: 15, top: 15),
                              //   height: 300,

                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(

                                    children: [
                                      Expanded(child: Text("Sl No :")),
                                      Expanded(child: Text("${index + 1}")),
                                    ],
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
                                          child: Text(itemImportedLists[index]
                                          ['ITEMID'] ??
                                              "")),
                                      Expanded(
                                          child: IconButton(

                                            hoverColor: Colors.red,

                                            onPressed: () async {


                                              // return;
                                              if (widget.isContinousScan !=
                                                  null &&
                                                  widget.isContinousScan &&
                                                  widget.transactionType ==
                                                      "STOCK COUNT") {

                                                var dt = await _sqlHelper
                                                    .getFindItemExistOrnotTRANSDETAILSStockCount(
                                                    DOCNO: transactionData[0]
                                                    ['DOCNO'],
                                                    ITEMID: itemImportedLists[
                                                    index]['ITEMID'],
                                                    ITEMNAME:
                                                    itemImportedLists[index]
                                                    ['ITEMNAME'],
                                                    BARCODE:
                                                    itemImportedLists[index]
                                                    ['BARCODE'],
                                                    TRANSTYPE: widget
                                                        .transactionType ==
                                                        "STOCK COUNT"
                                                        ? 1
                                                        : widget.transactionType ==
                                                        "PURCHASE ORDER"
                                                        ? 2
                                                        : "",
                                                    UOM: itemImportedLists[
                                                    index]['UOM']);



                                                if (dt.length > 0) {

                                                  if(
                                                  disabledContinuosScan! &&
                                                      itemImportedLists[index][
                                                      'BatchEnabled']
                                                          .toString() ==
                                                          "1" &&
                                                      itemImportedLists[index][
                                                      'BatchedItem']
                                                          .toString() ==
                                                          "0" &&
                                                      widget.transactionType ==
                                                          "STOCK COUNT" ||
                                                      widget.transactionType ==
                                                          "ST"
                                                  )
                                                  {


                                                  }
                                                  else{

                                                    print("The final status is : ${dt[0]['STATUS']}");

                                                    dt[0]['STATUS'] == 1 ?
                                                    await _sqlHelper
                                                        .updateTRANSDETAILSWithQty(
                                                        dt[0]['id'],
                                                        int.parse(
                                                            dt[0]['QTY']) +
                                                            1):
                                                    await _sqlHelper
                                                        .addTRANSDETAILS(

                                                      HRecId: transactionData[0]
                                                      ['RecId'],
                                                      STATUS: 1,
                                                      AXDOCNO: transactionData[0]
                                                      ['AXDOCNO'],
                                                      DOCNO: transactionData[0]
                                                      ['DOCNO'],
                                                      ITEMID: itemImportedLists[index]
                                                      ['ITEMID'],
                                                      ITEMNAME: itemImportedLists[index]
                                                      ['ITEMNAME'],
                                                      TRANSTYPE: widget.transactionType ==
                                                          "STOCK COUNT"
                                                          ? 1
                                                          : widget.transactionType ==
                                                          "PURCHASE ORDER"
                                                          ? 2
                                                          : "",
                                                      DEVICEID:
                                                      activatedDevice,
                                                      QTY: widget.isContinousScan

                                                          ? "1"
                                                          : itemImportedLists[index]
                                                      ['QTY'],
                                                      UOM: itemImportedLists[index]
                                                      ['UOM'],
                                                      BARCODE: itemImportedLists[index]
                                                      ['BARCODE'],
                                                      CREATEDDATE: DateTime.now()
                                                          .toString(),
                                                      INVENTSTATUS: itemImportedLists[index]
                                                      ['INVENTSTATUS'],
                                                      SIZEID: itemImportedLists[index]
                                                      ['SIZEID'],
                                                      COLORID: itemImportedLists[index]
                                                      ['COLORID'],
                                                      CONFIGID:
                                                      itemImportedLists[index]
                                                      ['CONFIGID'],
                                                      STYLESID: itemImportedLists[index]['STYLESID'],
                                                      STORECODE: activatedStore,
                                                      LOCATION: transactionData[0]['VRLOCATION'].toString(),
                                                      BatchEnabled: itemImportedLists[index]['BatchEnabled']
                                                          .toString()=="1"? true:false,
                                                      BatchedItem:itemImportedLists[index]['BatchedItem']
                                                          .toString()=="1"? true:false,


                                                    );

                                                    dt[0]['STATUS'] == 1 ?

                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                          backgroundColor: Colors.red,
                                                          content: Text(
                                                            'Item Updated Successfully',
                                                            textAlign: TextAlign.center,
                                                          )),
                                                    ):
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                          backgroundColor: Colors.red,
                                                          content: Text(
                                                            'Item Adding Successfully',
                                                            textAlign: TextAlign.center,
                                                          )),
                                                    );



                                                  }


                                                } else {

                                                  if(
                                                  disabledContinuosScan! &&
                                                      itemImportedLists[index][
                                                      'BatchEnabled']
                                                          .toString() ==
                                                          "1" &&
                                                      itemImportedLists[index][
                                                      'BatchedItem']
                                                          .toString() ==
                                                          "0" &&
                                                      widget.transactionType ==
                                                          "STOCK COUNT" ||
                                                      widget.transactionType ==
                                                          "ST"
                                                  ){

                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                TransactionViewPage(
                                                                  isImportedSearch:
                                                                  true,
                                                                  currentIndex: 1,
                                                                  pageType: widget
                                                                      .transactionType,
                                                                  transDetails:
                                                                  itemImportedLists[
                                                                  index],
                                                                )));
                                                  }
                                                  else{




                                                    await _sqlHelper
                                                        .addTRANSDETAILS(

                                                      HRecId: transactionData[0]
                                                      ['RecId'],
                                                      STATUS: 1,
                                                      AXDOCNO: transactionData[0]
                                                      ['AXDOCNO'],
                                                      DOCNO: transactionData[0]
                                                      ['DOCNO'],
                                                      ITEMID: itemImportedLists[index]
                                                      ['ITEMID'],
                                                      ITEMNAME: itemImportedLists[index]
                                                      ['ITEMNAME'],
                                                      TRANSTYPE: widget.transactionType ==
                                                          "STOCK COUNT"
                                                          ? 1
                                                          : widget.transactionType ==
                                                          "PURCHASE ORDER"
                                                          ? 2
                                                          : "",
                                                      DEVICEID:
                                                      activatedDevice,
                                                      QTY: widget.isContinousScan

                                                          ? "1"
                                                          : itemImportedLists[index]
                                                      ['QTY'],
                                                      UOM: itemImportedLists[index]
                                                      ['UOM'],
                                                      BARCODE: itemImportedLists[index]
                                                      ['BARCODE'],
                                                      CREATEDDATE: DateTime.now()
                                                          .toString(),
                                                      INVENTSTATUS: itemImportedLists[index]
                                                      ['INVENTSTATUS'],
                                                      SIZEID: itemImportedLists[index]
                                                      ['SIZEID'],
                                                      COLORID: itemImportedLists[index]
                                                      ['COLORID'],
                                                      CONFIGID:
                                                      itemImportedLists[index]
                                                      ['CONFIGID'],
                                                      STYLESID: itemImportedLists[index]['STYLESID'],
                                                      STORECODE: activatedStore,
                                                      LOCATION: transactionData[0]['VRLOCATION'].toString(),
                                                      BatchEnabled: itemImportedLists[index]['BatchEnabled']
                                                          .toString()=="1"? true:false,
                                                      BatchedItem:itemImportedLists[index]['BatchedItem']
                                                          .toString()=="1"? true:false,


                                                    );



                                                    var  d= {
                                                      "HRecId": transactionData[0]
                                                      ['RecId'],
                                                      "STATUS": 1,
                                                      "AXDOCNO": transactionData[0]
                                                      ['AXDOCNO'],
                                                      "DOCNO": transactionData[0]
                                                      ['DOCNO'],
                                                      "ITEMID": itemImportedLists[index]
                                                      ['ITEMID'],
                                                      "ITEMNAME": itemImportedLists[index]
                                                      ['ITEMNAME'],
                                                      "TRANSTYPE": widget.transactionType ==
                                                          "STOCK COUNT"
                                                          ? 1
                                                          : widget.transactionType ==
                                                          "PURCHASE ORDER"
                                                          ? 2
                                                          : "",
                                                      "DEVICEID":
                                                      activatedDevice,
                                                      "QTY": widget.isContinousScan
                                                          ? 1
                                                          : itemImportedLists[index]
                                                      ['QTY'],
                                                      "UOM": itemImportedLists[index]
                                                      ['UOM'],
                                                      "BARCODE": itemImportedLists[index]
                                                      ['BARCODE'],
                                                      "CREATEDDATE": DateTime.now()
                                                          .toString(),
                                                      "INVENTSTATUS": itemImportedLists[index]
                                                      ['INVENTSTATUS'],
                                                      "SIZEID": itemImportedLists[index]
                                                      ['SIZEID'],
                                                      "COLORID": itemImportedLists[index]
                                                      ['COLORID'],
                                                      "CONFIGID":
                                                      itemImportedLists[index]
                                                      ['CONFIGID'],
                                                      'STYLESID': itemImportedLists[index]['STYLESID'],
                                                      "STORECODE": activatedStore,
                                                      "LOCATION": transactionData[0]['VRLOCATION'].toString()
                                                    };


                                                    List<dynamic > pushedStocks= [];
//
                                                    pushedStocks.addAll(await _sqlHelper.getTRANSDETAILSINHeaderByStockCount("1"));
                                                    if( (widget.transactionType ==
                                                        "STOCK COUNT" ||
                                                        widget.transactionType ==
                                                            "ST") &&
                                                        pushedStocks.length ==
                                                            int.parse(APPGENERALDATASave['SetDefaultQtyByOne'].toString())
                                                    ){

                                                      print("Item Are Equal ...");
                                                      // return;
                                                      await  pushTransactionToPost();

                                                      return;
                                                    }
                                                    else{


                                                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                                                        showDialogGotRoute(
                                                            op:    Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        TransactionViewPage(
                                                                          currentIndex: 1,
                                                                          isImportedSearch: true,
                                                                          pageType: widget
                                                                              .transactionType,
                                                                        ))),
                                                            text: "Item Adding Successfully");
                                                      });



                                                      // ScaffoldMessenger.of(context)
                                                      //     .showSnackBar(
                                                      //   const SnackBar(
                                                      //       backgroundColor:
                                                      //       Colors.red,
                                                      //       content: Text(
                                                      //         'Item Adding Successfully',
                                                      //         textAlign:
                                                      //         TextAlign.center,
                                                      //       )),
                                                      // );
                                                      //
                                                      // Future.delayed(Duration(seconds: 2),(){
                                                      //   ScaffoldMessenger.of(context).clearSnackBars();
                                                      // });
                                                    }

                                                   // ;

                                                    print("line 759 .");
                                                    print(d);
                                                    return;


                                                  }

                                                  return;
                                                }



                                                if (disabledContinuosScan! &&
                                                    widget.transactionType ==
                                                        "STOCK COUNT" ||
                                                    widget.transactionType ==
                                                        "ST")
                                                {

                                                }


                                                if (disabledContinuosScan! &&
                                                    itemImportedLists[index][
                                                    'BatchEnabled']
                                                        .toString() ==
                                                        "1" &&
                                                    itemImportedLists[index][
                                                    'BatchedItem']
                                                        .toString() ==
                                                        "0" &&
                                                    widget.transactionType ==
                                                        "STOCK COUNT" ||
                                                    widget.transactionType ==
                                                        "ST") {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              TransactionViewPage(
                                                                isImportedSearch:
                                                                true,
                                                                currentIndex: 1,
                                                                pageType: widget
                                                                    .transactionType,
                                                                transDetails:
                                                                itemImportedLists[
                                                                index],
                                                              )));
                                                } else {

                                                  if (disabledContinuosScan! &&
                                                      widget.transactionType ==
                                                          "STOCK COUNT" ||
                                                      widget.transactionType ==
                                                          "ST") {

                                                    List<dynamic > pushedStocks= [];
//
                                                  pushedStocks.addAll(await _sqlHelper.getTRANSDETAILSINHeaderByStockCount("1"));
                                                  if( (widget.transactionType ==
                                                      "STOCK COUNT" ||
                                                      widget.transactionType ==
                                                          "ST") &&
                                                      pushedStocks.length ==
                                                          int.parse(APPGENERALDATASave['SetDefaultQtyByOne'].toString())
                                                  ){

                                                    print("Item Are Equal ...");
                                                    // return;
                                                  await  pushTransactionToPost();




                                                  return;
                                                  }

                                                  } else {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                TransactionViewPage(
                                                                  isImportedSearch:
                                                                  true,
                                                                  currentIndex: 1,
                                                                  pageType: widget
                                                                      .transactionType,
                                                                  transDetails:
                                                                  itemImportedLists[
                                                                  index],
                                                                )));
                                                  }
                                                }
                                              } else {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            TransactionViewPage(
                                                              isImportedSearch:
                                                              true,
                                                              currentIndex: 1,
                                                              pageType: widget
                                                                  .transactionType,
                                                              transDetails:
                                                              itemImportedLists[
                                                              index],
                                                            )));

                                                // if(     disabledContinuosScan! &&
                                                //     widget
                                                //         .transactionType == "STOCK COUNT" ||
                                                //     widget
                                                //         .transactionType == "ST"){

                                                // }

                                                if (disabledContinuosScan! &&
                                                    widget.transactionType ==
                                                        "STOCK COUNT" ||
                                                    widget.transactionType ==
                                                        "ST") {


                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              TransactionViewPage(
                                                                currentIndex: 1,
                                                                pageType: widget
                                                                    .transactionType,
                                                                isImportedSearch: true
                                                              )));








                                                 
                                                } else {}

                                                //   ?
                                                // :null;
                                              }
                                              return;

                                              await _sqlHelper.addTRANSDETAILS(
                                                  HRecId: transactionData[0]
                                                  ['RecId'],
                                                  STATUS: 0,
                                                  AXDOCNO: transactionData[0]
                                                  ['AXDOCNO'],
                                                  DOCNO: transactionData[0]
                                                  ['DOCNO'],
                                                  ITEMID: itemImportedLists[index]
                                                  ['ITEMID'],
                                                  ITEMNAME: itemImportedLists[index]
                                                  ['ITEMNAME'],
                                                  TRANSTYPE: widget.transactionType ==
                                                      "STOCK COUNT"
                                                      ? 1
                                                      : "",
                                                  DEVICEID: activatedDevice,
                                                  QTY: widget.isContinousScan
                                                      ? 1
                                                      : itemImportedLists[index]
                                                  ['QTY'],
                                                  UOM: itemImportedLists[index]
                                                  ['UOM'],
                                                  BARCODE: itemImportedLists[index]
                                                  ['BARCODE'],
                                                  CREATEDDATE:
                                                  DateTime.now().toString(),
                                                  INVENTSTATUS: itemImportedLists[index]
                                                  ['INVENTSTATUS'],
                                                  SIZEID: itemImportedLists[index]
                                                  ['SIZEID'],
                                                  COLORID: itemImportedLists[index]['COLORID'],
                                                  CONFIGID: itemImportedLists[index]['CONFIGID'],
                                                  STYLESID: itemImportedLists[index]['STYLESID'],
                                                  STORECODE: activatedStore,
                                                  LOCATION: transactionData[0]['VRLOCATION'].toString());

                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          TransactionViewPage(
                                                            currentIndex: 1,
                                                            pageType: widget
                                                                .transactionType,
                                                          )));
                                            },
                                            icon: Icon(
                                              Icons.downloading_outlined,
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
                                      Expanded(child: Text("BARCODE  :")),
                                      Expanded(
                                          child: Text(itemImportedLists[index]
                                          ['BARCODE'] ??
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
                                          child: Text(itemImportedLists[index]
                                          ['ITEMNAME'] ??
                                              ""))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(child: Text("Unit :")),
                                      Expanded(
                                          child: Text(itemImportedLists[index]
                                          ['UOM'] ??
                                              ""))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(child: Text("Style :")),
                                      Expanded(
                                          child: Text(itemImportedLists[index]
                                          ['SIZEID'] ??
                                              ""))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(child: Text("Config :")),
                                      Expanded(
                                          child: Text(itemImportedLists[index]
                                          ['CONFIGID'] ??
                                              ""))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(child: Text("Color :")),
                                      Expanded(
                                          child: Text(itemImportedLists[index]
                                          ['COLORID'] ??
                                              ""))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(child: Text("Size :")),
                                      Expanded(
                                          child: Text(itemImportedLists[index]
                                          ['SIZEID'] ??
                                              ""))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),

                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text("Batched Enabled:")),
                                      Expanded(
                                          child: Text(itemImportedLists[index]
                                          ['BatchEnabled']
                                              .toString() ==
                                              "1"
                                              ? "true"
                                              : "false")),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(child: Text("Batched Item:")),
                                      Expanded(
                                          child: Text(itemImportedLists[index]
                                          ['BatchedItem']
                                              .toString() ==
                                              "1"
                                              ? "true"
                                              : "false")),
                                    ],
                                  ),
                                  // Row(
                                  //   children: [
                                  //     Expanded(child: Text("Item ID :")),
                                  //     Expanded(child: Text("30300"))
                                  //   ],
                                  // ),
                                ],
                              )),
                        );
                      },

                      // itemBuilder: (c, i) => Card(child: Center(child: Text(items[i]))),
                      // itemExtent: 300.0,
                      itemCount: itemImportedLists.length,
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];
  List<String> item1 = [];
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  setvalue() async {
    itemImportedLists.addAll(
      widget.transactionType == "STOCK COUNT" ||
          widget.transactionType == "ST" ?

          await _sqlHelper.getIMPORTDETAILSSTOCKCOUNT(
              itemImportedLists[itemImportedLists.length - 1]['id'], widget.axDocNo):

        await _sqlHelper.getIMPORTDETAILS(
        itemImportedLists[itemImportedLists.length - 1]['id'], widget.axDocNo));

    print("data list is : ${itemImported.length}");
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });

    return;
    for (var i = itemImportedLists.length - 1;
    i < itemImported.length - 1;
    i++) {
      var u = 0;
      u++;

      // item1.add(items[i-1]);
      // print("contains value");
      // print(!item1.any((element) => element.contains(items[i])));
      //     if(!item1.any((element) => element.contains(items[i]))){
      if (u < 4) {
        print("contains value items : ${itemImported.length.toString()}");
        print("contains value item1 : ${itemImportedLists.length.toString()}");
        if (itemImportedLists.length <= itemImported.length) {
          print(itemImportedLists[i]);
          // item1.add(items[i]);
          // item1.add(items[i+1]);
          // item1.add(items[i+2]);

          itemImportedLists.length <= itemImported.length &&
              itemImported[i] != null
              ? itemImportedLists.add(itemImported[i])
              : null;

          itemImportedLists.length <= itemImported.length &&
              itemImported[i + 1] != null
              ? itemImportedLists.add(itemImported[i + 1])
              : null;

          itemImportedLists.length <= itemImported.length &&
              itemImported[i + 2] != null
              ? itemImportedLists.add(itemImported[i + 2])
              : null;

          itemImportedLists.length <= itemImported.length &&
              itemImported[i + 3] != null
              ? itemImportedLists.add(itemImported[i + 3])
              : null;
          itemImportedLists.length <= itemImported.length &&
              itemImported[i + 4] != null
              ? itemImportedLists.add(itemImported[i + 4])
              : null;

          itemImportedLists.length <= itemImported.length &&
              itemImported[i + 5] != null
              ? itemImportedLists.add(itemImported[i + 5])
              : null;

          itemImportedLists.length <= itemImported.length &&
              itemImported[i + 6] != null
              ? itemImportedLists.add(itemImported[i + 6])
              : null;

          itemImportedLists.length <= itemImported.length &&
              itemImported[i + 7] != null
              ? itemImportedLists.add(itemImported[i + 7])
              : null;
          itemImportedLists.length <= itemImported.length &&
              itemImported[i + 8] != null
              ? itemImportedLists.add(itemImported[i + 8])
              : null;
          itemImportedLists.length <= itemImported.length &&
              itemImported[i + 9] != null
              ? itemImportedLists.add(itemImported[i + 9])
              : null;

          itemImportedLists.length <= itemImported.length &&
              itemImported[i + 10] != null
              ? itemImportedLists.add(itemImported[i + 10])
              : null;

          itemImportedLists.length <= itemImported.length &&
              itemImported[i + 11] != null
              ? itemImportedLists.add(itemImported[i + 11])
              : null;
          itemImportedLists.length <= itemImported.length &&
              itemImported[i + 12] != null
              ? itemImportedLists.add(itemImported[i + 12])
              : null;
          itemImportedLists.length <= itemImported.length &&
              itemImported[i + 13] != null
              ? itemImportedLists.add(itemImported[i + 13])
              : null;

          itemImportedLists.length <= itemImported.length &&
              itemImported[i + 14] != null
              ? itemImportedLists.add(itemImported[i + 14])
              : null;

          //   item1.length <=items.length   && items[i+1] !=null ?  item1.add(items[i+1]):null;
          // item1.length <=items.length   && items[i+2] !=null  ?  item1.add(items[i+2]):null;
          // item1.length <=items.length   && items[i+3] !=null  ?  item1.add(items[i+3]):null;
          // // print( items[i+4]);
          //
          // item1.length <= items.length   && items[i+3] !=null  ?  item1.add(items[i+4]):null;

          // item1.add(items[i+4]);
        } else {
          item1.toSet().toList();
          setState(() {});
        }

        return;
      } else {
        item1.toSet().toList();
        setState(() {});
        return;
      }

      //     }
    }
    item1.toSet().toList();
    setState(() {});
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    print("load 351");
    // print(item1.length == items.length);
    // print(items.length.toString());
    // print(item1.length);
    setvalue();
    // print(_refreshController.position);

    if (mounted) setState(() {});
    // }
    _refreshController.loadComplete();
  }

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     body: Column(children: [
//       Container(
//         margin: EdgeInsets.symmetric(horizontal: 10),
//         height: 35,
//         child: TextFormField(
//           validator: (value) =>
//           value!.isEmpty ? 'Required *' : null,
//           controller: barcodeController,
//           decoration: InputDecoration(
//               suffixIcon: IconButton(
//                 onPressed: (){
//
//                 }, icon: Icon(Icons.manage_search,
//                 size: 20,
//               ),
//               ),
//               isDense: true,
//               contentPadding: EdgeInsets.only(
//                   left: 15, right: 15, top: 2, bottom: 2),
//               hintText: "Bar Code",
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(7.0),
//                 // borderSide: Border()
//               )),
//         ),
//       ),
//     ],)
//   );
// }
}
