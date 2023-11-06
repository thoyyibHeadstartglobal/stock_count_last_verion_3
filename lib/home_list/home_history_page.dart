import 'dart:convert';

import 'package:dynamicconnectapp/helper/local_db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants/constant.dart';
import 'home_history_details_page.dart';

class HomeHistoryPage extends StatefulWidget {
  const HomeHistoryPage({Key? key}) : super(key: key);

  @override
  State<HomeHistoryPage> createState() => _HomeHistoryPageState();
}

class _HomeHistoryPageState extends State<HomeHistoryPage> {
final   SQLHelper _sqlHelper = SQLHelper();
  @override
  void initState() {
    getUserData();
    getHistory();

    getToken();
    super.initState();
  }
  List<dynamic> docHistoryList=[];
  getHistory() async {
    setState((){
      docHistoryList=[];
    });
    docHistoryList= await _sqlHelper.getTRANSHEADERHistory();
    setState((){
    });

  }
var token;

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

dynamic transactionData;
dynamic APPGENERALDATASave;
String? activatedStore;
String? activatedDevice;

String? username;

getUserData() async {
  // setState(() {
  //   isActivated = true;
  // });
  prefs = await SharedPreferences.getInstance();
  username = await prefs?.getString("username");
  companyCode = await prefs!.getString("companyCode");

  // password = await prefs?.getString("password");


  APPGENERALDATASave = await _sqlHelper.getLastColumnAPPGENERALDATA();
  setState(() {});

  print(APPGENERALDATASave.isEmpty);

  if (APPGENERALDATASave != [] || APPGENERALDATASave != null) {

    print(activatedStore);
    print("store codes 74");
    setState(() {
      activatedStore = APPGENERALDATASave['STORECODE'] ?? "";
      activatedDevice = APPGENERALDATASave['DEVICEID'] ?? "";
    });
  }

  print(username);
}

getToken() async {
  // getTransTypes();
  setState(() {});


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
  setState(() {

  });
  print( await prefs!.getString("companyCode"));
  print( activatedStore);

  print(updateDevice);




  var url = "${accessUrl.toString()}/oauth2/token" +
      "?"
          "tenant_id=$tenantId&"
          "client_id=$clientId&"
          "client_secret=$clientSecretId"
          "&resource=$resource&"
          "grant_type=$grantType";



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

    var dt = json.decode(res.body);
    setState(() {
      token = dt['access_token'].toString();
    });


  } catch (e) {}
}
List<dynamic> transactionDetailsList = [];

List<dynamic> transactionDetails =[];
pushTransactionToClose(
    {
  String ? transType,
  String ? DOCNO,
  String ? vrLocation,
  String ? AXDOCNO,
  String ? status,
  String ? description,
  String ? createdDate,
  String ? store,
  String ? user,
  String ?deviceId,
  String ? dataAreaId

}) async {
  var tk = 'Bearer ${token.toString()}';
  Map<String, String> headers = {
    "Content-type": "application/json",
    'Authorization': tk
  };


  print("Line 208 .. ${ transType.toString()}");
  transactionData = await _sqlHelper.getTRANSHEADERRepost(
      transType.toString() == "22"
      ? "22"
      : "");

  print(transactionData);

  transactionDetailsList = [];
  setState(() {});

  transactionDetails =
  await  _sqlHelper.getTRANSDETAILSHistory(transType, DOCNO);
  setState(() {});




  transactionDetails.forEach((element) {
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
      "PRODDATE":element['PRODDATE'],
      "BatchEnabled": element['BatchEnabled'] == 1  ? true:false,
      "BatchedItem":  element['BatchedItem'] == 1  ? true:false,
      "LOCATION": "",
      "DEVICEID": element['DEVICEID'],
      "CREATEDDATE": element['CREATEDDATE']
    };
    transactionDetailsList.add(dt);


  });
  print(transactionDetailsList.length);
  print("element transaction list 331 : ${vrLocation.toString()}");
  transactionDetailsList.forEach(print);

  print(activatedStore);
  print(activatedDevice);


  var body = {
    "contract": {


      "JournalName" :
      transType.toString()
          == "22"
          ? transactionData[0]['JournalName']
          :"",
      "DeviceNumSeq":
      transType.toString()
          == "1" ?
      APPGENERALDATASave['STNEXTDOCNO']
          :

      transType

          == "3" ?
      APPGENERALDATASave['PONEXTDOCNO']
          :

      transType

          == "4" ?  APPGENERALDATASave['GRNNEXTDOCNO']
          :
      transType

          == "10"  ?  APPGENERALDATASave['RPNEXTDOCNO']
          :
      transType

          == "5"  ?
      APPGENERALDATASave['TOOUTNEXTDOCNO']

          :

      transType

          == "6"  ?

      APPGENERALDATASave['TOINNEXTDOCNO']

          :
      transType

          == "9" ?

      APPGENERALDATASave['RONEXTDOCNO']

          :

      transType

          == "11"  ?
      APPGENERALDATASave['TONEXTDOCNO']

          :
      transType

          == "22" ?
      APPGENERALDATASave['MJNEXTDOCNO']
          :
      ""
      ,

      // "DeviceNumSeq": int.parse(transType.toString()),
      "DOCNO": DOCNO,
      "AXDOCNO": AXDOCNO,
      "STORECODE": store,
      "TRANSTYPE":transType,
      "STATUS": status,
      "USERNAME": user,
      "VRLOCATION" : vrLocation == ""?"0":vrLocation,
      "DESCRIPTION": description,
      "CREATEDDATE": createdDate,
      "DATAAREAID": dataAreaId,
      "DEVICEID": deviceId,
      "pushdata": transactionDetailsList
    }
  };

  print("repost body req 268...");
  print(json.encode(body));

  // return;
  var ur = "$pushStockTakeApi";
  print(ur);

  var js = json.encode(body);
  var res = await http.post(headers: headers, Uri.parse(ur), body: js);
  print(res.body);
  var responseJson = json.decode(res.body);
  print(responseJson);
  print(res.statusCode);
  print("Post closed success before sent");
  if (res.statusCode == 200 || res.statusCode == 201) {
    print("Post closed success");
    print(res.statusCode);


    print(responseJson[0]['Message']);


      if(responseJson[0]['Message'].toString().contains("already")){

        showDialogGotData(responseJson[0]['Message'].toString());
      }

      else{
        showDialogGotData("Transaction Posted ${responseJson[0]['Message'].toString()}fully");
      }

  }
  else{

    showDialogGotData(responseJson[0]['Message'].toString());
  }

}



showDialogGotData(String text) {
  // set up the button
  Widget yesButton = TextButton(
    style: APPConstants().btnBackgroundYes,
    child: Text("Ok",
      style: APPConstants().YesText),
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

showDialogPost(String text,int ind) {
  // set up the button
  Widget yesButton = TextButton(
   style: APPConstants().btnBackgroundYes,
    child: Text("Yes",
      style: APPConstants().YesText,),
    onPressed: () async {
      pushTransactionToClose(
          transType : docHistoryList[ind]['TRANSTYPE'],
          DOCNO : docHistoryList[ind]['DOCNO'],
        vrLocation : docHistoryList[ind]['VRLOCATION'],
          AXDOCNO : docHistoryList[ind]['AXDOCNO'],
          status : docHistoryList[ind]['STATUS'].toString(),
          description :docHistoryList[ind]['DESCRIPTION'],
         createdDate :docHistoryList[ind]['CREATEDDATE'],
        store : docHistoryList[ind]['STORECODE'],
          dataAreaId : docHistoryList[ind]['DATAAREAID'],
          deviceId:docHistoryList[ind]['DEVICEID'],
          user:docHistoryList[ind]['USERNAME'],

      );

      Navigator.pop(context);

      setState(() {
        // docHistoryList.remove(docHistoryList[ind]);
      });

    },
  );

  Widget noButton = TextButton(
    style: APPConstants().btnBackgroundNo,
    child: Text("No",
    style: APPConstants().noText),
    onPressed: () {
      print("Scanning code");
      setState(() {

      });
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("DynamicsConnect"),
    content: Text(
      "$text",
    ),
    actions: [
      noButton,
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


showDialogdelete(String text,int ind) {
  // set up the button
  Widget yesButton = TextButton(
    style: APPConstants().btnBackgroundYes,
    child: Text("Yes",
      style: APPConstants().YesText,),
    onPressed: () async {
      await _sqlHelper.deleteTRANSHEADERHistory(docHistoryList[ind]['DOCNO']);
      print("yes");

      print(ind);
      print(docHistoryList[ind]);
      Navigator.pop(context);
       getHistory();
      setState(() {
        // docHistoryList.remove(docHistoryList[ind]);
      });

    },
  );

  Widget noButton = TextButton(
    style: APPConstants().btnBackgroundNo,
    child: Text("No",
      style: APPConstants().noText,),
    onPressed: () {
      print("Scanning code");
      setState(() {

      });
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("DynamicsConnect"),
    content: Text(
      "$text",
    ),
    actions: [
      noButton,
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

int selectedIndex=-1;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          elevation: 0,
          backgroundColor: Colors.red,
          // backgroundColor:  Color(0xfff4e7e6),
          //    backgroundColor:  Color(0xffed648e),

        ),
        body: Column(

          children: [
            Expanded(
              child: ListView.builder(
                itemCount: docHistoryList.length,
                  itemBuilder: (context ,int index){
                  return  InkWell(
                    onTap: (){


                      setState((){
                        selectedIndex= index;
                      });
                    },
                    child: Tooltip(
                      decoration:BoxDecoration(
                        color: Colors.red,
                      ),
                      message: "DOC NO : ${docHistoryList[index]['DOCNO']??""}",

                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin:EdgeInsets.symmetric(vertical: 0,horizontal: 0),
                        color: selectedIndex == index
                            ? Colors.red[200]
                            :null,
                        child: Column(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  // color: Colors.grey,
                                    color: Color(0xfff5deb4),
                                    borderRadius: BorderRadius.circular(15.0),
                                    border: Border.all(
                                        color: Colors.black12,
                                        width: 1.2
                                    )
                                  // color: Colors.red,
                                ),
                                margin: EdgeInsets.only(right:15.0 ,bottom: 5.0,top:5.0 ,left: 15.0),
                                padding: EdgeInsets.only(left: 10.0,bottom: 10,top: 10,right: 5),
                                //   height: 300,

                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Expanded(child: Text("DOCUMENT NO :")),
                                        Expanded(child: Text(docHistoryList[index]['DOCNO']??"")),

                                      ],
                                    ),
                                    SizedBox(height: 10,),
                                    Row(
                                      children: [

                                        Expanded(child: Text("ERP DOCNO :")),
                                        Expanded(child: Text(docHistoryList[index]['AXDOCNO']??"")),


                                      ],
                                    ),
                                    SizedBox(height: 10,),
                                    Row(
                                      children: [
                                        Expanded(child: Text("TRANSTYPE :")),
                                        Expanded(child: Text(docHistoryList[index]['TRANSTYPE']??""))
                                      ],
                                    ),
                                    SizedBox(height: 10,),
                                    Row(
                                      children: [
                                        Expanded(child: Text("Store Code :")),
                                        Expanded(child: Text(docHistoryList[index]['STORECODE']??""))
                                      ],
                                    ),

                                    SizedBox(height: 10,),
                                    Row(
                                      children: [
                                        Expanded(child: Text("Date :")),
                                        Expanded(child: Text(docHistoryList[index]['CREATEDDATE']??""))
                                      ],
                                    ),



                                    SizedBox(height: 10,),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween
                                      ,
                                      children: [

                                       Expanded(
                                         flex:2,
                                           child: Container()),
                                       Expanded(child: TextButton(
                                           onPressed: () async {

                                                if(docHistoryList[index]['DOCNO'] == null ||
                                                    docHistoryList[index]['DOCNO'] == ""){
                                                  return;
                                                }
                                                showDialogdelete("Are You Sure To Remove DOCNO : ${
                                                    docHistoryList[index]['DOCNO']
                                                }",index);

                                           },
                                           child: Text("REMOVE",style: TextStyle(
                                             fontSize: 11
                                           ),))),
                                      Expanded(child:
                                      TextButton(
                                          onPressed: () {
                                            showDialogPost("Are You Sure To Re-Post : ${
                                                docHistoryList[index]['DOCNO']
                                            }",index);
                                          },
                                          child:
                                          Text("RE-POST",
                                              style:
                                              TextStyle(
                                              fontSize: 11
                                          )))),
                                      Expanded(child: IconButton(
                                        focusColor: Colors.black,
                                        icon: Icon(Icons.remove_red_eye_outlined),
                                        onPressed: () {

                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                          HomeHistoryDetailsPage(
                                            indexData : docHistoryList[index] ,
                                          )
                                          ));
                                        },
                                      )),
                                    ],)


                                  ],
                                )),
                          ],
                        ),
                      ),
                    ),
                  );


                  //   Column(
                  //
                  //   children: [
                  //     Text("Document No : ${docHistoryList[index]['DOCNO']??""}"),
                  //     Text("ERP DOC No : ${docHistoryList[index]['AXDOCNO'] ??""}"),
                  //     Text("TRANS TYPE : ${docHistoryList[index]['TRANSTYPE'] ??""}"),
                  //     Text("STORE : ${docHistoryList[index]['STORECODE'] ??""}"),
                  //     Text("Date : ${docHistoryList[index]['CREATEDDATE'] ??""}")
                  //   ],
                  // );
                  }),
            )

          ],
        ),
      ),
    );
  }
}
