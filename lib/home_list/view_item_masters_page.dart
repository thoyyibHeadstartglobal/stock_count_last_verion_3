import 'dart:convert';

import 'package:dynamicconnectapp/helper/local_db.dart';
import 'package:dynamicconnectapp/home_list/onhand_page.dart';
import 'package:dynamicconnectapp/home_list/price_check_page.dart';
import 'package:dynamicconnectapp/home_list/transaction_view_pages/transaction_view_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class ViewItemsOldPage extends StatefulWidget {
  // const ViewItemsOldPage({Key? key}) : super(key: key);
  ViewItemsOldPage({
    this.isOnHand,
    this.isPriceCheck,
    this.isHomeView,
    this.transactionType,
    this.searchKey,
  });

  final bool ? isOnHand;
  final bool ? isPriceCheck;
  final dynamic isHomeView;
  final dynamic transactionType;
  final dynamic searchKey;


  @override
  State<ViewItemsOldPage> createState() => _ViewItemsOldPageState();
}

class _ViewItemsOldPageState extends State<ViewItemsOldPage> {
 bool isLoading=true;
 ScrollController _scrollController = ScrollController();
 SQLHelper _sqlHelper = SQLHelper();

 List<dynamic> itemMasters= [];
 List<dynamic> itemMastersLists= [];


 @override
 void didChangeDependencies() {
   super.didChangeDependencies();
 }

 @override
  void initState() {
   print("loaded 30 datas");
   print(widget.transactionType);
   // if(widget.isPriceCheck == null){

     getUserData();
     getItemMastersInItData();

   // }
   // else{
   //   getUserData();
   //   getToken();
   //
   //
   // }

    // _scrollController.addListener(() {
    //   print("max position");
    //   print(_scrollController.position);
    //   if (_scrollController.position.atEdge) {
    //     bool isTop = _scrollController.position.pixels == 0;
    //     if (isTop) {
    //
    //       setState((){
    //         isLoading = false;
    //       });
    //       print('At the top');
    //     } else {
    //       print('At the bottom');
    //     }
    //   }
    //   if (_scrollController.position.maxScrollExtent ==
    //       _scrollController.position.pixels) {
    //     if (!isLoading) {
    //       isLoading = !isLoading;
    //       setState((){
    //
    //       });
    //       print(isLoading);
    //
    //       // Perform event when user reach at the end of list (e.g. do Api call)
    //     }
    //     else{
    //       isLoading = false;
    //       setState((){
    //
    //       });
    //     }
    //
    //
    //   }
    //   else{
    //   isLoading = true;
    //   setState((){
    //
    //   });
    //   }
    // });
    super.initState();
  }

 dynamic  priceCheckValue;



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
 SharedPreferences ? prefs;

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


     getItemMastersPriceCheckApiInit();

     // getStoreCode();
     // getDevices();
     // getTatmeenDetails();
     print(token);
   } catch (e) {}
 }
 int ?lastRecId=0;


 getItemMastersPriceCheckApiInit() async {

   var tk = 'Bearer ${token.toString()}';
   Map<String, String> headers = {
     "Content-type": "application/json",
     'Authorization': tk
   };
  var body = {
   "transType": 2, // 1- Counting                 2- Item master
   //     3- Open Purchase order lines 4- Invoiced Purchase lines
   "transactionId": "" , // Counting journal number , empty string for Item master , Purchase order number
   "items":0, // all items STOCK COUNT  : items =0 , from journal items=1
   "topCount": 1000,
   "lastRecid": lastRecId,
   "dataAreaId": "$companyCode",
   "storeCode": activatedStore
   };



   // body = {
   // "transType": transType, // 1- Counting                 2- Item master
   // //     3- Open Purchase order lines 4- Invoiced Purchase lines
   // "transactionId": transType == 2 ? "":
   // transactionNumberController.text, // Counting journal number , empty string for Item master , Purchase order number
   // "items":transType == 1 ? items:
   // 0, // all items STOCK COUNT  : items =0 , from journal items=1
   // "topCount": 1000,
   // "lastRecid": lastRecId,
   // "dataAreaId": "$companyCode",
   // "storeCode": APPGENERALDATASave['STORECODE']
   // };



   print(body);
    print("269 ...");
   // return;
   var ur = "$pullStockTakeApi";
   print(ur);
   var js = json.encode(body);
   var res = await http.post(headers: headers, Uri.parse(ur), body: js);
   print("res.statusCode");
   print(res.statusCode);
   var responseJson = json.decode(res.body);
   print(responseJson);

   if (responseJson[0]['Importdata'] == null ||
   responseJson[0]['Importdata'].length == 0) {
   // Navigator.pop(context);
   // showDialogGotData("Data is Empty");
     setState((){


       isLoading =false;


     });
   return;
   }
   // importedList.addAll(responseJson[0]['Importdata']);
   List<dynamic> listDt = [];


     setState((){

       lastRecId = responseJson[0]['LastRecId'];
       listDt = responseJson[0]['Importdata'];
         isLoading =false;
         itemMastersLists.addAll(listDt);

     });
   if(lastRecId ==0){
     return;
   }

   itemMastersLists.forEach((element) {

     print(element);
   });
   // return;
   // for(var i=0;i<15;i++){
   //   itemMastersLists.add(itemMasters[i]);
   // }
   setState((){
     isLoading=false;
   });


 }


 getApiPriceCheck() async {
   var tk = 'Bearer ${token.toString()}';
   Map<String, String> headers = {
     "Content-type": "application/json",
     'Authorization': tk
   };
   // var body = {
   //   "dataAreaId": "$companyCode" // 1 - to get only counting journal lines
   // };
   var body = {
     "transType": 8,
     // 1 - Counting
     //  2 - Item master   ,
     //   3 - Open Purchase order lines
     //    4 - Invoiced Purchase lines
     //     8 - on hand
     //     7- price check
     "transactionId": searchController
         .text, // Counting journal number , empty string for Item master , Purchase order number
     "items": 0, //all items STOCK COUNT  : items =0 , from journal items=1
     "topCount": 1000,
     "lastRecid": lastRecId,
     "dataAreaId": "$companyCode",
     "storeCode": "$activatedDevice"
   };
   // var ur = APIConstants.baseUrl + "pushTransactionTatmeen";
   var ur = "$pullStockTakeApi";
   print(ur);
   var js = json.encode(body);
   var res = await http.post(headers: headers, Uri.parse(ur), body: js);
   var responseJson = json.decode(res.body);
   print(responseJson);

   if (res.statusCode == 200 || res.statusCode == 201) {
     // Importdata: [{$id: 2, AXDOCNO: , OrderAccount: , OrderAccountName: , FROMSTORECODE: ,
     //   TOSTORECODE: , ItemId: 33300003, ItemName: 21ST CENT FOLICACID TAB 100S,
     //   ITEMBARCODE: 33300003A0045257, DATAAREAID: 1000, WAREHOUSE: , CONFIGID: , COLORID: ,
     //   SIZEID: , STYLEID: , INVENTSTATUS: , QTY: 0.0, UNIT: PACK, TRANSTYPE: 8, ItemAmount: 29.0, GTIN: ,
     //   GTINUnit: , GTINOrderQTY: 0.0, GTINReceiveQTY: 0.0, HeaderOnly: 0, Description: }]

     priceCheckValue = responseJson[0]['Importdata'][0];
     setState(() {
       // stores = responseJson[0]['Stores'];
     });
     print("got it device");
     // print(selectDevice);
     // print(selectStore);
     // print("got it device");

     //
     // stores.forEach((element) {
     //   print(element);
     // });
   }
 }

  setValueLoadItemMaster(String ? key) async {
   print("key");
   print(key);

   itemMasters = await  _sqlHelper.getItemMatersBySearch(key);

   print(itemMasters.length);
   // return;

   print(itemMasters[0]);

   try{
     for(var i=0;i<15;i++){
       print(itemMasters[i]);
       itemMastersLists.add(itemMasters[i]);
     }
     setState((){
       isLoading=false;
     });
   }
   catch(e){
     setState((){
       isLoading=false;
     });
   }






    // itemMasters = await _sqlHelper.getItemMatersBySearch
    //   (key!);
    //       if(itemMasters .length<=0){
    //         // setState((){
    //         //   isLoading= true;
    //         //   itemMastersLists =[];
    //         //   itemMasters =[];
    //         // });
    //         itemMasters = await _sqlHelper.getItemMatersBySearch
    //           (key);
    //         print(await _sqlHelper.getItemMatersBySearch
    //           (key));
    //         itemMasters.forEach((element) {
    //
    //           print(element);
    //         });
    //         for(var i=0;i<15;i++){
    //           print(itemMasters[i]);
    //           itemMastersLists.add(itemMasters[i]);
    //         }
    //       }
    //    else{
    //         print("itemMasters.length");
    //         print(itemMasters.length);
    //         // for(var i=0;i<15;i++){
    //         //   itemMastersLists.add(itemMasters[i]);
    //         // }
    //       }



  }




 // setValueLoadItemMasterPriceCheck(String ? key) async {
 //   print("key");
 //   print(key);
 //
 //   itemMasters = await  getItemMastersApiData(key);
 //
 //   print(itemMasters.length);
 //   // return;
 //   for(var i=0;i<15;i++){
 //     itemMastersLists.add(itemMasters[i]);
 //   }
 //   setState((){
 //     isLoading=false;
 //   });
 //
 //
 //
 //
 //   // itemMasters = await _sqlHelper.getItemMatersBySearch
 //   //   (key!);
 //   //       if(itemMasters .length<=0){
 //   //         // setState((){
 //   //         //   isLoading= true;
 //   //         //   itemMastersLists =[];
 //   //         //   itemMasters =[];
 //   //         // });
 //   //         itemMasters = await _sqlHelper.getItemMatersBySearch
 //   //           (key);
 //   //         print(await _sqlHelper.getItemMatersBySearch
 //   //           (key));
 //   //         itemMasters.forEach((element) {
 //   //
 //   //           print(element);
 //   //         });
 //   //         for(var i=0;i<15;i++){
 //   //           print(itemMasters[i]);
 //   //           itemMastersLists.add(itemMasters[i]);
 //   //         }
 //   //       }
 //   //    else{
 //   //         print("itemMasters.length");
 //   //         print(itemMasters.length);
 //   //         // for(var i=0;i<15;i++){
 //   //         //   itemMastersLists.add(itemMasters[i]);
 //   //         // }
 //   //       }
 //
 //
 //
 // }

 var transType="";

 getTransTypes(){
   print(widget.transactionType);
   if(widget.transactionType == "ST"){
     setState((){
       transType=  "STOCK COUNT";
     });
   }
   if(widget.transactionType == "PO" ){
     transType= "PURCHASE ORDER";
     setState((){

     });
   }
   if(widget.transactionType == "GRN" ){
     transType= "GOODS RECEIVE";
     setState((){

     });
   }

   if(widget.transactionType ==  "RP" ){
     transType= "RETURN PICK";
     setState((){

     });
   }

   if(widget.transactionType == "RO" ){
     transType= "RETURN ORDER";
     setState((){

     });
   }


   if(widget.transactionType   == "MJ" ){
     transType= "MOVEMENT JOURNAL";
     setState((){

     });
   }

   if(widget.transactionType   == "TO" ){
     transType= "TRANSFER ORDER";
     setState((){

     });
   }


   if(widget.transactionType   == "TO-OUT"){
     transType= "TRANSFER OUT";
     setState((){

     });
   }


   if(widget.transactionType   == "TO-IN"){
     transType= "TRANSFER IN";
     setState((){

     });
   }
 }

 dynamic APPGENERALDATASave;
 dynamic  activatedStore ;
 dynamic activatedDevice;
 getUserData() async {


   getTransTypes();

   // password = await prefs?.getString("password");

   APPGENERALDATASave = await _sqlHelper.getLastColumnAPPGENERALDATA();
   setState((){
   });
   print("69 ... line");
   print(APPGENERALDATASave.isEmpty);
   print("71 ... line");
   if(APPGENERALDATASave !=[] ||  APPGENERALDATASave != null){

     print("store codes 72");
     print(activatedStore);
     print("store codes 74");
     setState((){
       activatedStore = APPGENERALDATASave['STORECODE']??"";
       activatedDevice = APPGENERALDATASave['DEVICEID']??"";

     });
   }


 }

 // getItemMastersApiData(String ? key) async {
 //   if(widget.isPriceCheck != null){
 //   // FGVZSDGDGVBSGVFSD
 //  // int  index =  itemMastersLists.indexWhere
 //  //   ((element) => element['ItemName'] == key ||
 //  //      element['ItemName'] == key?.toUpperCase() ||
 //  //      element['ItemName'] == key?.toLowerCase() || element['ItemId'] == key);
 //  var results;
 //  if (key =="") {
 //    setState((){
 //      isLoading= true;
 //      itemMastersLists =[];
 //      itemMasters =[];
 //    });
 //   await getItemMastersPriceCheckApiInit();
 //    setState((){
 //      isLoading= false;
 //    });
 //
 //  } else {
 //    results = itemMastersLists.where((element) =>
 //    element['ItemName'].toLowerCase().contains(key?.toLowerCase()) ||
 //        element['ItemName'].contains(key) ||
 //        element['ItemName'].toLowerCase().contains(key?.toLowerCase()) ||
 //        element['ItemId'].contains(key)).toList();
 //    setState(() {
 //
 //    });
 //  }
 //
 //  print(results.length);
 //  if(results.length >0){
 //
 //    setState((){
 //      isLoading= true;
 //      itemMastersLists =[];
 //      itemMasters =[];
 //    });
 //
 //    itemMastersLists.addAll(results.reversed.toList());
 //    // await setValueLoadItemMasterPriceCheck(searchController.text);
 //    setState((){
 //      isLoading=false;
 //    });
 //    return;
 //    print("search is found");
 //  }
 //  else{
 //    setState((){
 //      isLoading= true;
 //      itemMastersLists =[];
 //      itemMasters =[];
 //    });
 //
 //    Future.delayed(const Duration(seconds: 3), () {
 //
 //          getItemMastersPriceCheckApiInit();
 //
 //      setState((){
 //        isLoading= false;
 //      });
 //
 //    });
 //    print("search is not found");
 //  }
 //
 //    FocusManager.instance.primaryFocus?.unfocus();
 //  }
 //
 //
 // }
 //
 // getItemMastersByPriceCheck() async {
 //
 //
 //
 //   itemMasters= await   _sqlHelper.getItemMaters();
 //   // return;
 //   for(var i=0;i<15;i++){
 //     itemMastersLists.add(itemMasters[i]);
 //   }
 //   setState((){
 //     isLoading=false;
 //   });
 // }


  dynamic transactionData;
  getItemMastersInItData() async {

    print("data initial 687");

    if( widget.transactionType == "PO"){
      transactionData = await _sqlHelper.getTRANSHEADER(
          widget.transactionType == "PO" ? "3": "");
    }
    itemMasters.addAll(await   _sqlHelper.getItemMatersByCount());

   if( itemMasters.isEmpty ){
     setState((){
       isLoading=false;
     });  return;
   }

    // return;
     for(var i=0;i<15;i++){
       itemMastersLists.add(itemMasters[i]);
     }
    setState((){
      isLoading=false;
    });

  }

  set(){
    for(var i=0;i<5;i++){
      itemMastersLists.add(itemMasters[i]);
    }
    setState((){

    });

  }

  TextEditingController searchController =TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            title: Column(
              children: [
                SizedBox(height: 15,),
                TextFormField(
                  onFieldSubmitted:(value)
                  async {
                    var result = await _sqlHelper.getItemMatersBySearch(
                        searchController.text.trim());

                    print(result.length);
                    if (result.length > 0) {


                      setState(() {
                        isLoading = true;
                        itemMastersLists = [];
                        itemMasters = [];
                      });
                      await setValueLoadItemMaster(searchController.text.trim());
                      setState(() {
                        isLoading = false;
                      });
                      return;
                      print("search is found");
                    }
                    else {
                      setState(() {
                        isLoading = true;
                        itemMastersLists = [];
                        itemMasters = [];
                      });

                      Future.delayed(const Duration(seconds: 1), () {
                        setState(() {
                          isLoading = false;
                        });
                      });
                      print("search is not found");
                    }
                  },

                  // onChanged: (value) async {
                  //   var result = await _sqlHelper.getItemMatersBySearch(searchController.text.trim());
                  //
                  //   print(result.length);
                  //   if(result.length >0){
                  //     print("728 ...search");
                  //     setState((){
                  //       isLoading= true;
                  //       itemMastersLists =[];
                  //       itemMasters =[];
                  //     });
                  //     await setValueLoadItemMaster(searchController.text.trim()
                  //     );
                  //     setState((){
                  //       isLoading=false;
                  //     });
                  //     return;
                  //     print("search is found");
                  //   }
                  //   else{
                  //
                  //     setState((){
                  //       isLoading= true;
                  //       itemMastersLists =[];
                  //       itemMasters =[];
                  //     });
                  //
                  //     Future.delayed(Duration(seconds: 1), () {
                  //
                  //       setState((){
                  //         isLoading= false;
                  //       });
                  //
                  //     });
                  //     print("search is not found");
                  //   }
                  //
                  // },
                  maxLines: 1,
                  minLines: 1,
                  controller: searchController,
                  decoration: InputDecoration(
                    isDense: true,

                    // focusColor: Colors.white,
                    //   fillColor: Colors.white,
                    fillColor: Colors.white,
                    hintText: "Search",
                    hintStyle: TextStyle(
                        color: Colors.black26

                    ),
                    prefixIcon: IconButton(
                      icon: Icon(Icons.search),

                      onPressed: () async {
                              // if(widget.isPriceCheck != null){
                              //   if(searchController.text.trim() == ""){
                              //
                              //     setState((){
                              //       isLoading= true;
                              //       itemMastersLists =[];
                              //       itemMasters =[];
                              //     });
                              //     await  getItemMastersPriceCheckApiInit();
                              //
                              //     setState((){
                              //       isLoading= false;
                              //     });
                              //     return;
                              //   }
                              //
                              //   // getApiPriceCheck();
                              //   getItemMastersApiData(searchController.text);
                              //
                              //
                              //   return;
                              // }
                        if(searchController.text.trim() == ""){


                          setState((){
                            isLoading= true;
                            itemMastersLists =[];
                            itemMasters =[];
                          });
                        await  getItemMastersInItData();
                          setState((){
                            isLoading= false;
                          });
                          return;
                        }
                      var result = await _sqlHelper.getItemMatersBySearch(searchController.text);

                      print(result.length);
                      if(result.length >0){
                        print("854 ...search");
                        setState((){
                          isLoading= true;
                          itemMastersLists =[];
                          itemMasters =[];
                        });
                        await setValueLoadItemMaster(searchController.text);
                        setState((){
                          isLoading=false;
                        });
                        return;
                        print("search is found");
                      }
                      else{
                        setState((){
                          isLoading= true;
                          itemMastersLists =[];
                          itemMasters =[];
                        });

                        Future.delayed( Duration(seconds: 1), () {



                          setState((){
                            isLoading= false;
                          });

                        });
                        print("search is not found");
                      }

                      },
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.close,color: Colors.red,),
                      onPressed: () async {
                        // await _sqlHelper.getItemMatersBySearch(searchController.text);
                        searchController.clear();
                        print("search");
                      },
                    ),
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(

                      borderSide: const BorderSide(
                          color: Colors.black54, width: 0.1),
                    ),
                    enabledBorder:
                    OutlineInputBorder(

                      borderSide: const BorderSide(
                          color: Colors.black54, width: 0.1),
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
                SizedBox(height: 15,),
              ],
            ),
          ),

      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // SizedBox(height: 60,),

            // SizedBox(height: 20,),
            isLoading? Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child:  Column(
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
            ):

            Expanded(child: Container(
              height: MediaQuery.of(context).size.height ,
              child: SmartRefresher(
                // scrollController: _scrollController,
                enablePullDown:  itemMasters.length != itemMastersLists .length ? true:false,
                enablePullUp:  true,
                header: WaterDropHeader(),
                footer: CustomFooter(
                  builder: (BuildContext ? context,LoadStatus ? mode){
                    Widget body ;
                    // print("last index 272");
                    // print(mode);
                    // print(mode?.index == items.length-1);
                    // print(mode == LoadStatus.noMore);
                    if( itemMasters.length == itemMastersLists .length){
                      // print("full loaded");
                      body = Container();
                    }
                    else{

                    }
                    if(mode==LoadStatus.idle){
                      // print(LoadStatus.idle);
                      // print("ideal condition");
                      // print(itemMasters.length == itemMastersLists .length);
                      // print("ideal condition");
                      if(itemMastersLists.length <=itemMasters.length){

                        body = Container()
                        // Text("pull up load")
                            ;
                      }
                      else{
                        body =
                            Container()
                        ;
                      }

                    }
                    else if(mode==LoadStatus.loading && itemMastersLists.length !=itemMasters.length){
                      body =
                          CupertinoActivityIndicator(
                            radius: 20,
                          );
                    }
                    else if(mode == LoadStatus.failed){
                      body = Text("Load Failed!Click retry!");
                    }
                    else if(mode == LoadStatus.canLoading){
                      body = Text("release to load more");
                    }
                    else{
                      body = Container();
                      // Text("No more Data");
                    }
                    return Container(
                      height: 55.0,
                      child: Center(child:body),
                    );
                  },
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: ListView.builder(
                  itemBuilder: (context,int index){
                    return  Tooltip(
                      decoration:BoxDecoration(

                        color: Colors.red,
                      ),
                      message: "\nITEM ID :${itemMastersLists[index]['ItemId'] ??""}"
                          "\nITEM Name : ${itemMastersLists[index]['ItemName']}\n",

                      child: Container(
                          decoration: BoxDecoration(
                              color: Color(0xfff5deb4),
                              // color: Colors.yellow[50],
                              borderRadius: BorderRadius.circular(15.0),
                              border: Border.all(
                                  color: Colors.black12,
                                  width: 1.2
                              )
                            // color: Colors.red,
                          ),
                          margin: EdgeInsets.only(right:0.0 ,bottom: 10.0,top:10.0 ,left: 0.0),
                          padding: EdgeInsets.only(left: 10.0,bottom: 15,top: 15),
                          //   height: 300,

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  // {id: 2, ITEMBARCODE: 3330000307227, ItemId: 33300003,
                                  //   ItemName: 21ST CENT FOLICACID TAB 100S,
                                  //   DATAAREAID: 1000, WAREHOUSE: ,
                                  //   CONFIGID: , COLORID: , SIZEID: , STYLEID: ,
                                  //   INVENTSTATUS: , QTY: 0.0, UNIT: PACK, ItemAmount: 0.0}

                                  Expanded(child: Text("Item ID : ")),
                                  Expanded(child: Text(itemMastersLists[index]['ItemId']??"")),
                                  // Expanded(child: Text(itemMastersLists[index].toString())),
                                  Visibility(
                                    visible: !widget.isHomeView,
                                    child: Expanded(child: IconButton(
                                      hoverColor: Colors.green,
                                      onPressed:  () async {
                                        // print(itemImportedLists[index].toString());
                                        print("Line 1093");
                                        print(widget.transactionType);
                                        // print(transType);
                                        // print(widget.isContinousScan);

                                        // return;
                                        if(!widget.isHomeView && widget.isPriceCheck != null){

                                          Navigator.push(context, MaterialPageRoute(
                                            builder: (context)=>PriceCheckPage(
                                              isItemMasters: true,
                                              itemDetails:itemMastersLists[index],
                                            )));

                                          return;
                                        }
                                        if(!widget.isHomeView && widget.isOnHand != null){

                                          Navigator.push(context, MaterialPageRoute(
                                              builder: (context)=>OnHandPage(
                                                isItemMasters: true,
                                                itemDetails:itemMastersLists[index],
                                              )));

                                          return;
                                        }

                                        if(widget.transactionType=="PO"){

                                          var dt = await  _sqlHelper.getFindItemExistOrnotTRANSDETAILS(

                                              DOCNO : transactionData[0]['DOCNO'],
                                              ITEMID : itemMastersLists[index]['ITEMID'],
                                              ITEMNAME :itemMastersLists[index]['ITEMNAME'],
                                              BARCODE : itemMastersLists[index]['BARCODE'],
                                              TRANSTYPE :widget.transactionType == "PURCHASE ORDER" ? 3 :"",
                                              UOM :itemMastersLists[index]['UOM']
                                          );

                                          print(dt.length);

                                          if(dt.length >0){
                                            await  _sqlHelper.updateTRANSDETAILSWithQty(dt[0]['id'], int.parse(dt[0]['QTY'])+1);
                                          }
                                          else{
                                            await _sqlHelper.addTRANSDETAILS(
                                                HRecId :  transactionData[0]['RecId']  ,
                                                STATUS: 0,
                                                AXDOCNO: transactionData[0]['AXDOCNO'],
                                                DOCNO :  transactionData[0]['DOCNO'] ,
                                                ITEMID :itemMastersLists[index]['ITEMID'] ,
                                                ITEMNAME : itemMastersLists[index]['ITEMNAME'],
                                                TRANSTYPE : widget.transactionType == "STOCK COUNT" ? 1 :"" ,
                                                DEVICEID :activatedDevice ,
                                                QTY : 1,
                                                UOM  : itemMastersLists[index]['UOM'],
                                                BARCODE :itemMastersLists[index]['BARCODE'],
                                                CREATEDDATE : DateTime.now().toString() ,
                                                INVENTSTATUS : itemMastersLists[index]['INVENTSTATUS'],
                                                SIZEID : itemMastersLists[index]['SIZEID'],
                                                COLORID :  itemMastersLists[index]['COLORID'],
                                                CONFIGID :  itemMastersLists[index]['CONFIGID'],
                                                STYLESID :  itemMastersLists[index]['STYLESID'],
                                                STORECODE :  activatedStore,
                                                LOCATION :  transactionData[0]['VRLOCATION'].toString()
                                            );

                                          }


                                          Navigator.push(context, MaterialPageRoute(
                                              builder: (context)=>TransactionViewPage(
                                                isImportedSearch: true,
                                                currentIndex: 1,
                                                pageType: widget.transactionType,
                                                transDetails:itemMastersLists[index],
                                              )));

                                          // Navigator.push(context, MaterialPageRoute(
                                          //     builder: (context)=>TransactionViewPage(
                                          //       currentIndex: 1,
                                          //       pageType: widget.transactionType,
                                          //     )));
                                        }
                                        else{


                                          print("Line mj 1177 : ${widget.transactionType.toString()}");

                                          // return;
                                          Navigator.push(context, MaterialPageRoute(
                                              builder: (context)=>TransactionViewPage(
                                                isImportedSearch: true,
                                                currentIndex: 1,
                                                pageType: widget.transactionType,
                                                transDetails:itemMastersLists[index],
                                              )));
                                        }



                                      },
                                      icon: Icon(
                                        Icons.downloading_outlined,color: Colors.redAccent,size: 45,),
                                    )),
                                  )
                                ],
                              ),
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  Expanded(child: Text("BARCODE  :")),
                                  Expanded(child: Text(itemMastersLists[index]['ITEMBARCODE']??""))
                                ],
                              ),
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  Expanded(child: Text("Item Name :")),
                                  Expanded(child: Text(itemMastersLists[index]['ItemName']??""))
                                ],
                              ),
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  Expanded(child: Text("Unit :")),
                                  Expanded(child: Text(itemMastersLists[index]['UNIT']??""))
                                ],
                              ),
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  Expanded(child: Text("Style :")),
                                  Expanded(child: Text(itemMastersLists[index]['STYLEID']??""))
                                ],
                              ),
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  Expanded(child: Text("Config :")),
                                  Expanded(child: Text(itemMastersLists[index]['CONFIGID']??""))
                                ],
                              ),
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  Expanded(child: Text("Color :")),
                                  Expanded(child: Text(itemMastersLists[index]['COLOR']??""))
                                ],
                              ),
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  Expanded(child: Text("Size :")),
                                  Expanded(child: Text(itemMastersLists[index]['SIZEID']??""))
                                ],
                              ),
                              SizedBox(height: 10,),

                              Row(
                                children: [
                                  Expanded(child: Text("Batch Enbled : ")),
                                  Expanded(child: Text(itemMastersLists[index]['BatchEnabled'].toString()== "0"? "false" : "true" )),
                                ],
                              ),
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  Expanded(child: Text("Batched Item : ")),
                                  Expanded(child: Text(itemMastersLists[index]['BatchedItem'].toString()== "0"? "false" : "true" )),
                                ],
                              )
                            ],
                          )),
                    );
                  },

                  // itemBuilder: (c, i) => Card(child: Center(child: Text(items[i]))),
                  // itemExtent: 300.0,
                  itemCount: itemMastersLists.length,
                ),
              ),
            ))
          ],
        ),
      )
      ,
    );
  }



 List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8","9", "10"];
 List<String> item1 = [];
 RefreshController _refreshController =
 RefreshController(initialRefresh: false);

 void _onRefresh() async{
   // monitor network fetch
   await Future.delayed(Duration(milliseconds: 1000));
   // if failed,use refreshFailed()
   _refreshController.refreshCompleted();
 }

 setvalueItemMastersApi(){
   for(var i= itemMastersLists.length-1; i < itemMasters.length -1;i++ ){
     var u =0;
     u++;


     if(u<4){
       print("contains value items : ${itemMasters.length.toString()}");
       print("contains value item1 : ${itemMastersLists.length.toString()}");
       if(itemMastersLists.length <=itemMasters.length){
         print(itemMastersLists[i]);
         // item1.add(items[i]);
         // item1.add(items[i+1]);
         // item1.add(items[i+2]);

         itemMastersLists.length <=itemMasters.length  && itemMasters[i] !=null ?  itemMastersLists.add(itemMasters[i]):null;


         itemMastersLists.length <=itemMasters.length  && itemMasters[i+1] !=null ?  itemMastersLists.add(itemMasters[i+1]):null;

         itemMastersLists.length <=itemMasters.length  && itemMasters[i+2] !=null ?  itemMastersLists.add(itemMasters[i+2] ):null;

         itemMastersLists.length <=itemMasters.length  && itemMasters[i+3] !=null ?  itemMastersLists.add(itemMasters[i+3] ):null;

         itemMastersLists.length <=itemMasters.length  && itemMasters[i+4] !=null ?  itemMastersLists.add(itemMasters[i+4] ):null;


         itemMastersLists.length <=itemMasters.length  && itemMasters[i+5] !=null ?  itemMastersLists.add(itemMasters[i+5]):null;


         itemMastersLists.length <=itemMasters.length  && itemMasters[i+6] !=null ?  itemMastersLists.add(itemMasters[i+6]):null;

         itemMastersLists.length <=itemMasters.length  && itemMasters[i+7] !=null ?  itemMastersLists.add(itemMasters[i+7] ):null;

         itemMastersLists.length <=itemMasters.length  && itemMasters[i+8] !=null ?  itemMastersLists.add(itemMasters[i+8] ):null;

         itemMastersLists.length <=itemMasters.length  && itemMasters[i+9] !=null ?  itemMastersLists.add(itemMasters[i+9] ):null;


         itemMastersLists.length <=itemMasters.length  && itemMasters[i+10] !=null ?  itemMastersLists.add(itemMasters[i+10]):null;


         itemMastersLists.length <=itemMasters.length  && itemMasters[i+11] !=null ?  itemMastersLists.add(itemMasters[i+11]):null;

         itemMastersLists.length <=itemMasters.length  && itemMasters[i+12] !=null ?  itemMastersLists.add(itemMasters[i+12] ):null;

         itemMastersLists.length <=itemMasters.length  && itemMasters[i+13] !=null ?  itemMastersLists.add(itemMasters[i+13] ):null;

         itemMastersLists.length <=itemMasters.length  && itemMasters[i+14] !=null ?  itemMastersLists.add(itemMasters[i+14] ):null;


       }
       else{

       }



       return;
     }
     else{

       return;
     }


     //     }
   }

   setState((){

   });


 }


  setvalue() async {
    itemMasters.addAll(await   _sqlHelper.getItemMaters(itemMastersLists[itemMastersLists.length-1]['id']));

    itemMastersLists.addAll(await   _sqlHelper.getItemMaters(itemMastersLists[itemMastersLists.length-1]['id']));

    //  List<dynamic> ? masterList;
    //  masterList!.addAll(await   _sqlHelper.getItemMaters(itemMastersLists[itemMastersLists.length-1]['id']));
    //
    // itemMastersLists = masterList.toSet().toList();


    setState((){
    isLoading=false;
    });
   return ;
   for(var i= itemMastersLists.length-1; i < itemMasters.length -1;i++ ){
     var u =0;
     u++;

     // item1.add(items[i-1]);
 // print("contains value");
 // print(!item1.any((element) => element.contains(items[i])));
 //     if(!item1.any((element) => element.contains(items[i]))){
     if(u<4){
       print("contains value items : ${itemMasters.length.toString()}");
       print("contains value item1 : ${itemMastersLists.length.toString()}");
       if(itemMastersLists.length <=itemMasters.length){
         print(itemMastersLists[i]);
         // item1.add(items[i]);
         // item1.add(items[i+1]);
         // item1.add(items[i+2]);

         itemMastersLists.length <=itemMasters.length  && itemMasters[i] !=null ?  itemMastersLists.add(itemMasters[i]):null;


         itemMastersLists.length <=itemMasters.length  && itemMasters[i+1] !=null ?  itemMastersLists.add(itemMasters[i+1]):null;

         itemMastersLists.length <=itemMasters.length  && itemMasters[i+2] !=null ?  itemMastersLists.add(itemMasters[i+2] ):null;

         itemMastersLists.length <=itemMasters.length  && itemMasters[i+3] !=null ?  itemMastersLists.add(itemMasters[i+3] ):null;

         itemMastersLists.length <=itemMasters.length  && itemMasters[i+4] !=null ?  itemMastersLists.add(itemMasters[i+4] ):null;


         itemMastersLists.length <=itemMasters.length  && itemMasters[i+5] !=null ?  itemMastersLists.add(itemMasters[i+5]):null;


         itemMastersLists.length <=itemMasters.length  && itemMasters[i+6] !=null ?  itemMastersLists.add(itemMasters[i+6]):null;

         itemMastersLists.length <=itemMasters.length  && itemMasters[i+7] !=null ?  itemMastersLists.add(itemMasters[i+7] ):null;

         itemMastersLists.length <=itemMasters.length  && itemMasters[i+8] !=null ?  itemMastersLists.add(itemMasters[i+8] ):null;

         itemMastersLists.length <=itemMasters.length  && itemMasters[i+9] !=null ?  itemMastersLists.add(itemMasters[i+9] ):null;


         itemMastersLists.length <=itemMasters.length  && itemMasters[i+10] !=null ?  itemMastersLists.add(itemMasters[i+10]):null;


         itemMastersLists.length <=itemMasters.length  && itemMasters[i+11] !=null ?  itemMastersLists.add(itemMasters[i+11]):null;

         itemMastersLists.length <=itemMasters.length  && itemMasters[i+12] !=null ?  itemMastersLists.add(itemMasters[i+12] ):null;

         itemMastersLists.length <=itemMasters.length  && itemMasters[i+13] !=null ?  itemMastersLists.add(itemMasters[i+13] ):null;

         itemMastersLists.length <=itemMasters.length  && itemMasters[i+14] !=null ?  itemMastersLists.add(itemMasters[i+14] ):null;

         //   item1.length <=items.length   && items[i+1] !=null ?  item1.add(items[i+1]):null;
         // item1.length <=items.length   && items[i+2] !=null  ?  item1.add(items[i+2]):null;
         // item1.length <=items.length   && items[i+3] !=null  ?  item1.add(items[i+3]):null;
         // // print( items[i+4]);
         //
         // item1.length <= items.length   && items[i+3] !=null  ?  item1.add(items[i+4]):null;


         // item1.add(items[i+4]);
       }
       else{
         item1.toSet().toList();
         setState((){

         });
       }



       return;
     }
     else{
       item1.toSet().toList();
       setState((){

       });
       return;
     }


       //     }
   }
   item1.toSet().toList();
   setState((){

   });



 }

 void _onLoading() async{
   // monitor network fetch

   await Future.delayed(Duration(milliseconds: 1000));
   // if failed,use loadFailed(),if no data return,use LoadNodata()
   print("load 351");
   // print(item1.length == items.length);
   // print(items.length.toString());
   // print(item1.length);

   // if(widget.isPriceCheck !=null){
   //   setvalueItemMastersApi();
   // }
   // else{

     setvalue();
   // }

   // print(_refreshController.position);


     // if(mounted)
     //   setState(() {
     //
     //   });
   // }
   _refreshController.loadComplete();
 }



}
