import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dynamicconnectapp/constants/constant.dart';
import 'package:dynamicconnectapp/common_pages/home_page.dart';
import 'package:dynamicconnectapp/common_pages/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamicconnectapp/helper/local_db.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:http/http.dart' as http;

class ProjectSettingsEnvironmentPage extends StatefulWidget {
  const ProjectSettingsEnvironmentPage({this.pageTitle,this.isSettings});
  final String? pageTitle;
  final bool ? isSettings;
  @override
  State<StatefulWidget> createState() => _ProjectSettingsEnvironmentPageState();
}

class _ProjectSettingsEnvironmentPageState
    extends State<ProjectSettingsEnvironmentPage> {


  Barcode? result;


  final SQLHelper _sqlHelper = SQLHelper();

  final _formKey = GlobalKey<FormState>();

  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool _switchValue = true;


  SharedPreferences? prefs;


  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }



  showAlertDialogGTINFailed(BuildContext context) {
    // set up the button
    Widget scanButton = TextButton(
      style: APPConstants().btnBackgroundYes,
      child: Text("Ok",
        style: APPConstants().YesText),
      onPressed: () {
        print("Scanning code");
        setState(() {

        });
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      // title: Text(),
      content: Text("Invalid GTIN"),
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

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget scanButton = TextButton(
      child: Text("Scan"),
      onPressed: () {
        print("Scanning code");
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("My title"),
      content: Text("This is my message."),
      actions: [
        scanButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }




  final GlobalKey<TooltipState> tooltipkey = GlobalKey<TooltipState>();

  String? token;
  TextEditingController companyCodeController = new TextEditingController();
  TextEditingController accessUrlController = new TextEditingController();
  TextEditingController tenantIdController = new TextEditingController();
  TextEditingController clientIdController = new TextEditingController();
  TextEditingController clientSecretController = new TextEditingController();
  TextEditingController resourceController = new TextEditingController();
  TextEditingController grantTypeController = new TextEditingController();

  TextEditingController pullStockTakeApiController = new TextEditingController();
  TextEditingController pushStockAPiController = new TextEditingController();

  TextEditingController getStoreController = new TextEditingController();
  TextEditingController deactivateDeviceController = new TextEditingController();
  TextEditingController getDeviceController = new TextEditingController();
  TextEditingController updateDeviceController = new TextEditingController();


  @override
  void initState() {

    if (!mounted) {

    }
    getToken();
    super.initState();
  }






  String ?baseUrlString;
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
  String ? updateDevice;
  String? disableCamera;
  getToken() async {
    print("init Api");

    prefs = await SharedPreferences.getInstance();
    print("camera status");
    print(await prefs?.getString("camera"));
    disableCamera = await prefs?.getString("camera");
    print("...172");
    print( await prefs!
        .getString("baseUrl"));
    var v = await prefs?.getString("camera");
    disableCamera = v.toString() == "true" ? "true" : "false";
    setState(() {});

    companyCode=  await prefs!
        .getString("companyCode");
  baseUrlString=  await prefs!
        .getString("baseUrl");
  accessUrl=  await prefs!
        .getString("accessUrl");
  tenantId=  await prefs!.getString(
        "tenantId");
  clientId=  await prefs!
        .getString("clientId");
   clientSecretId= await prefs!
        .getString("clientSecret");
   resource= await prefs!.getString(
        "resource");
   grantType= await prefs!
        .getString("grantType");
 pullStockTakeApi=   await prefs!
        .getString("pullStockTakeApi");
  pushStockTakeApi=  await prefs!.getString(
        "pushStockTakeApi");



    getDevice= await prefs!
        .getString("getDevice");
    getStore=   await prefs!
        .getString("getStore");
    getDeactivate=  await prefs!.getString(
        "deactivate");

    updateDevice =  await prefs!.getString(
        "updateDevice");
    // print(deviceId);

    baseUrlString = baseUrlString ?? "";

    companyCodeController.text = companyCode ?? " ";
    accessUrlController.text = accessUrl ?? " ";
    tenantIdController.text = tenantId ?? "";
    clientIdController.text = clientId ?? " ";
    clientSecretController.text = clientSecretId ?? " ";
    resourceController.text = resource ?? "";
    grantTypeController.text = grantType ?? "";
    pullStockTakeApiController.text = pullStockTakeApi ?? " ";
    pushStockAPiController.text = pushStockTakeApi ?? " ";


    getDeviceController.text = getDevice ?? "";
    getStoreController.text = getStore ?? " ";
    deactivateDeviceController.text = getDeactivate ?? " ";
    updateDeviceController.text = updateDevice ?? " ";

    if(baseUrlString=="null" || baseUrlString==null){
      baseUrlString = "";
      setState(() {});

    }
    if(companyCode=="null" || companyCode ==null){
      companyCodeController.clear();
      setState(() {});

    }
    if(accessUrl=="null" || accessUrl ==null){
      accessUrlController.clear();
      setState(() {});

    }

    if(tenantId=="null" || tenantId ==null){
      tenantIdController.clear();
      setState(() {});

    }
    if(clientId=="null" || clientId ==null){
      clientIdController.clear();
      setState(() {});

    }
    if(clientSecretId=="null" || clientSecretId ==null){
      clientSecretController.clear();
      setState(() {});

    }
    if(grantType=="null" || grantType ==null){
      grantTypeController.clear();
      setState(() {});

    }
    if(resource=="null" || resource ==null){
      resourceController.clear();
      setState(() {});

    }
    if(pullStockTakeApi=="null" || pullStockTakeApi ==null){
      pullStockTakeApiController.clear();
      setState(() {});

    }
    if(pushStockTakeApi=="null" || pushStockTakeApi ==null){
      pushStockAPiController.clear();
      setState(() {});

    }

    if(getDevice=="null" || getDevice ==null){
      getDeviceController.clear();
      setState(() {});

    }

    if(getStore=="null" || getStore ==null){
      getStoreController.clear();
      setState(() {});

    }
    if(getDeactivate=="null" || getDeactivate ==null){
      deactivateDeviceController.clear();
      setState(() {});

    }
    if(updateDevice=="null" || updateDevice ==null){
      updateDeviceController.clear();
      setState(() {});

    }

    // if(baseUrlString == "" || accessUrl==""){
    //   Navigator.push(context,
    //   MaterialPageRoute(builder:(context)=>UserHomePage()));
    //   return;
    // }



  }


  @override
  Widget build(BuildContext context) {
    print(result?.format);

    print(result?.code);
    print("load");
    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: Text("APP SETTINGS"),
      // ),
      body: ListView(
        // mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                Visibility(
                  visible: disableCamera == null || disableCamera == "false",
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      IgnorePointer(
                        // ignoring: !_focusNodeDocumentNo.hasFocus &&
                        //         documentnoController.text == ""
                        //     ? true
                        //     : false,
                        ignoring: false,
                        child: GestureDetector(
                          onTap: () async {
                            await controller?.resumeCamera();
                            await controller?.toggleFlash();
                          },
                          child: Container(
                              height: 300,
                              child: _buildQrView(
                                  context,
                                  MediaQuery.of(context).orientation ==
                                          Orientation.portrait
                                      ? true
                                      : false)),
                        ),
                      ),
                      Container(
                        height: 30,
                        color: Colors.black.withOpacity(0.4),
                        child: Center(
                          child: Text(
                            "Place the blue line over the QR code ",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.orangeAccent
                          ),
                          child: Text("SCAN",
                          style: TextStyle(
                            color: Colors.white
                          ),),
                          onPressed: () {
                                  controller?.resumeCamera();
                                  controller?.toggleFlash();
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 10,
                ),
                Container(
                  // height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: TextFormField(
                      validator: (value) =>
                      value!.isEmpty ? 'Required *' : null,
                      controller: companyCodeController,
                      decoration: InputDecoration(
                        label: Text("Company Code"),
                          floatingLabelBehavior:companyCodeController.text !=""?
                          FloatingLabelBehavior.always:
                          FloatingLabelBehavior.never,
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                              left: 15, right: 15, top: 7, bottom: 7),
                          hintText: "COMPANY  CODE",
                          hintStyle: TextStyle(
                              color: Colors.black26

                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),

                Container(
                  // height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child:
                  TextFormField(
                    // readOnly: true,
                    validator: (value) =>
                    value!.isEmpty ? 'Required *' : null,
                    controller: accessUrlController,
                    decoration: InputDecoration(

                        label: Text("ACCESS URL"),
                        floatingLabelBehavior:accessUrlController.text !=""?
                        FloatingLabelBehavior.always:
                        FloatingLabelBehavior.never,
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            left: 15, right: 15, top: 7, bottom: 7),
                        hintText: "ACCESS URL",
                        hintStyle: TextStyle(
                            color: Colors.black26

                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0))),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),

                Container(
                  // height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: TextFormField(
                      validator: (value) =>
                      value!.isEmpty ? 'Required *' : null,
                      controller: tenantIdController,

                      decoration: InputDecoration(
                          label: Text("Tenant Id"),
                          floatingLabelBehavior:tenantIdController.text !=""?
                          FloatingLabelBehavior.always:
                          FloatingLabelBehavior.never,
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                              left: 15, right: 15, top: 7, bottom: 7),
                          hintText: "Tenant Id",
                          hintStyle: TextStyle(
                              color: Colors.black26

                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  // height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: TextFormField(
                      controller: clientIdController,
                      validator: (value) =>
                      value!.isEmpty ? 'Required *' : null,
                      decoration: InputDecoration(
                          label: Text("Client Id"),
                          floatingLabelBehavior:
                          clientIdController.text !=""?
                          FloatingLabelBehavior.always:
                          FloatingLabelBehavior.never,
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                              left: 15, right: 15, top: 7, bottom: 7),
                          hintText: "Client Id",
                          hintStyle: TextStyle(
                              color: Colors.black26

                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  // height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: TextFormField(
                      obscureText: true,
                      obscuringCharacter: '*',
                      controller: clientSecretController,
                      validator: (value) =>
                      value!.isEmpty ? 'Required *' : null,
                      decoration: InputDecoration(
                        // labelStyle: TextStyle(
                        //
                        // ),
                          label: Text("Client Secret"),
                          floatingLabelBehavior:clientSecretController.text !=""?
                          FloatingLabelBehavior.always:
                          FloatingLabelBehavior.never,
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                              left: 15, right: 15, top: 7, bottom: 7),
                          hintText: "Client Secret",
                          hintStyle: TextStyle(
                              color: Colors.black26
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  // height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: TextFormField(
                      controller: resourceController,
                      validator: (value) =>
                      value!.isEmpty ? 'Required *' : null,
                      decoration: InputDecoration(
                          label: Text("Resource"),
                          floatingLabelBehavior:resourceController.text !=""?
                          FloatingLabelBehavior.always:
                          FloatingLabelBehavior.never,
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                              left: 15, right: 15, top: 7, bottom: 7),
                          hintText: "Resource",
                          hintStyle: TextStyle(
                              color: Colors.black26

                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  // height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: TextFormField(
                      controller: grantTypeController,
                      validator: (value) =>
                      value!.isEmpty ? 'Required *' : null,
                      decoration: InputDecoration(
                          label: Text("Grant Type"),
                          floatingLabelBehavior:grantTypeController.text !=""?
                          FloatingLabelBehavior.always:
                          FloatingLabelBehavior.never,
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                              left: 15, right: 15, top: 7, bottom: 7),
                          hintText: "Grant Type",
                          hintStyle: TextStyle(
                              color: Colors.black26

                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  // height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: TextFormField(
                      controller: pullStockTakeApiController,
                      validator: (value) =>
                      value!.isEmpty ? 'Required *' : null,
                      decoration: InputDecoration(
                          label: Text("Pull Stock Take API "),
                          floatingLabelBehavior:pullStockTakeApiController.text !=""?
                          FloatingLabelBehavior.always:
                          FloatingLabelBehavior.never,
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                              left: 15, right: 15, top: 7, bottom: 7),
                          hintText: "Pull Stock Take API ",
                          hintStyle: TextStyle(
                              color: Colors.black26

                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                    ),
                  ),
                ),

                SizedBox(
                  height: 10,
                ),
                Container(
                  // height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: TextFormField(
                      controller: pushStockAPiController,
                      validator: (value) =>
                      value!.isEmpty ? 'Required *' : null,
                      decoration: InputDecoration(
                          label: Text("Push Stock Take API "),
                          floatingLabelBehavior:pushStockAPiController.text !=""?
                          FloatingLabelBehavior.always:
                          FloatingLabelBehavior.never,
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                              left: 15, right: 15, top: 7, bottom: 7),
                          hintText: "Push Stock Take API ",
                          hintStyle: TextStyle(
                              color: Colors.black26

                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  // height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: TextFormField(
                      controller: getDeviceController,
                      validator: (value) =>
                      value!.isEmpty ? 'Required *' : null,
                      decoration: InputDecoration(
                          label: Text("Get Device "),
                          floatingLabelBehavior:getDeviceController.text !=""?
                          FloatingLabelBehavior.always:
                          FloatingLabelBehavior.never,
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                              left: 15, right: 15, top: 7, bottom: 7),
                          hintText: "Get Device",
                          hintStyle: TextStyle(
                              color: Colors.black26

                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  // height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: TextFormField(
                      controller: getStoreController,
                      validator: (value) =>
                      value!.isEmpty ? 'Required *' : null,
                      decoration: InputDecoration(
                          label: Text("Get Store"),
                          floatingLabelBehavior:getStoreController.text !=""?
                          FloatingLabelBehavior.always:
                          FloatingLabelBehavior.never,
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                              left: 15, right: 15, top: 7, bottom: 7),
                          hintText: "Get Store",
                          hintStyle: TextStyle(
                              color: Colors.black26

                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  // height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: TextFormField(
                      controller: deactivateDeviceController,
                      validator: (value) =>
                      value!.isEmpty ? 'Required *' : null,
                      decoration: InputDecoration(
                          label: Text("Deactivate Device"),
                          floatingLabelBehavior:deactivateDeviceController.text !=""?
                          FloatingLabelBehavior.always:
                          FloatingLabelBehavior.never,
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                              left: 15, right: 15, top: 7, bottom: 7),
                          hintText: "Deactivate Device",
                          hintStyle: TextStyle(
                              color: Colors.black26

                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),


                Container(
                  // height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: TextFormField(
                      controller: updateDeviceController,
                      validator: (value) =>
                      value!.isEmpty ? 'Required *' : null,
                      decoration: InputDecoration(
                          label: Text("Update Device"),
                          floatingLabelBehavior:updateDeviceController.text !=""?
                          FloatingLabelBehavior.always:
                          FloatingLabelBehavior.never,
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                              left: 15, right: 15, top: 7, bottom: 7),
                          hintText: "Update Device",
                          hintStyle: TextStyle(
                              color: Colors.black26

                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: SizedBox(
                      // width: 200.0,
                      // height: 30.0,
                      child: TextButton(
                        style: TextButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () async {
                                  if(!_formKey.currentState!.validate()){
                                    return;
                                  }

                                  await prefs!
                                      .setString("companyCode",companyCodeController.text);
                                    await prefs!
                                    .setString("baseUrl",baseUrlString!);
                              await prefs!
                              .setString("accessUrl", accessUrlController.text);
                          await prefs!.setString(
                          "tenantId", tenantIdController.text);
                          await prefs!
                              .setString("clientId", clientIdController.text);
                          await prefs!
                              .setString("clientSecret", clientSecretController.text);
                          await prefs!.setString(
                          "resource", resourceController.text);
                          await prefs!
                              .setString("grantType", grantTypeController.text);
                          await prefs!
                              .setString("pullStockTakeApi", pullStockTakeApiController.text);
                          await prefs!.setString(
                          "pushStockTakeApi", pushStockAPiController.text);

                                  await prefs!
                                      .setString("getDevice", getDeviceController.text);
                                  await prefs!
                                      .setString("getStore", getStoreController.text);
                                  await prefs!.setString(
                                      "deactivate", deactivateDeviceController.text);

                                  await prefs!.setString(
                                      "updateDevice", updateDeviceController.text);

                          setState((){

                          });

                                  if(widget.isSettings != true){

                                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                                      await showDialogGotData(op: Navigator.push(context, MaterialPageRoute(
                                          builder: (context)=>LoginPage())),
                                          text: "API Credentials Updated successfully");

                                    });

                                  }
                                  else{
                                    // await  showDialogGotData(
                                    //     "API Credentials Updated successfully");
                                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                                      await showDialogGotData(op: Navigator.push(context, MaterialPageRoute(
                                          builder: (context)=>LandingHomePage())),
                                          text: "API Credentials Updated successfully");

                                    });

                                  }
                        },
                        child: const Text('SAVE',
                            style: TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Visibility(
                    visible:
                    widget.isSettings !=null &&
                        widget.isSettings!,
                    child: Expanded(
                        child: SizedBox(
                          // width: 200.0,
                          // height: 30.0,
                          child: TextButton(
                            style: TextButton.styleFrom(backgroundColor: Colors.orangeAccent),
                            onPressed: () async {

                              Navigator.pop(context);

                            },
                            child: const Text('BACK',
                                style: TextStyle(fontSize: 20, color: Colors.white)),
                          ),
                        )),
                  )
                ],
              ),
            ),
    SizedBox( height:20)

              ],
            ),
          ),
        ],
      ),
    );
  }





  Widget _buildQrView(BuildContext context, bool isPortail) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea;
    if (isPortail) {
      scanArea = (MediaQuery.of(context).size.width < 400 ||
              MediaQuery.of(context).size.height < 400)
          ? 300.0
          : 600.0;
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
          borderColor: Colors.blue,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  Future<void> _onQRViewCreated(QRViewController controller) async {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {

      setState(() {
        result = scanData;
        print("scan result : 953");

          print("elmnt");

        final lst = result!.code?.split("'");
        print(lst);
        print(lst![0].toString());
        //
        // print(lst[1].toString());
        // print(lst[2].toString());
        // print(lst[3].toString());
        // print(lst[4].toString());
        // print(lst[5].toString());
        // print(lst[6].toString());
        // print(lst[7].toString());
        // print(lst[8].toString());
        //
        print(lst[9].toString());
        print(lst[10].toString());
        print(lst[11].toString());
        print(lst[12].toString());
        print(lst[13].toString());

        print("scan result : 980");
        companyCodeController.text= "";
        accessUrlController.text = lst[0].trim().toString();
        tenantIdController.text = lst[1].trim().toString();
        clientIdController.text = lst[2].trim().toString();
        clientSecretController.text = lst[3].trim().toString();
        resourceController.text = lst[4].trim().toString();
        grantTypeController.text = lst[5].trim().toString();
        pullStockTakeApiController.text = "${lst[6].trim().toString()}${lst[7].trim().toString()}";
        baseUrlString =lst[6].trim().toString();
        pushStockAPiController.text = "${lst[6].trim().toString()}${lst[8].trim().toString()}";

        getStoreController.text = "${lst[6].trim().toString()}${lst[9].trim().toString()}";
        getDeviceController.text = "${lst[6].trim().toString()}${lst[10].trim().toString()}";
        updateDeviceController.text  = "${lst[6].trim().toString()}${lst[11].trim().toString()}";
        deactivateDeviceController.text = "${lst[6].trim().toString()}${lst[12].trim().toString()}";
        // print(lst[12].trim().toString());


      });

      showDialogGotData(text: "Config data loaded, Click on save button to update configurations");
      controller.pauseCamera();



    });



  }


  showDialogGotData({String ? text,dynamic op}){

      // set up the button
      Widget scanButton = TextButton(
        style: APPConstants().btnBackgroundYes,
        child: Text("Ok",
          style:
          APPConstants().YesText
          ),
        onPressed: () {
          print("Scanning code");
          setState(() {

          });
          Navigator.pop(context);
          op;
        },
      );

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("DynamicsConnect"),
        content: Text("$text",),
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
    controller?.dispose();
    super.dispose();


  }
}
