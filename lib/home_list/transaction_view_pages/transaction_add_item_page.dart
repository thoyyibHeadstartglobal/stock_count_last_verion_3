import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dynamicconnectapp/helper/local_db.dart';
import 'package:dynamicconnectapp/home_list/search_imported_details.dart';
import 'package:dynamicconnectapp/home_list/view_item_masters_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/constant.dart';

class TranscationAddItemPage extends StatefulWidget {
  TranscationAddItemPage(
      {this.type, this.isImportedSearch, this.transDetails, this.touchTab});
  final bool? touchTab;
  final bool? isImportedSearch;
  final dynamic transDetails;
  final dynamic type;
  @override
  State<TranscationAddItemPage> createState() => _TranscationAddItemPageState();
}

class _TranscationAddItemPageState extends State<TranscationAddItemPage> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  bool? isBatchEnabled = false;
  bool? BatchedItem = false;

  bool? showQuantityExceed ;

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

  final SQLHelper _sqlHelper = SQLHelper();
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
  bool? showDimension;

  var token;
  Barcode? result;
  TextEditingController barcodeController = TextEditingController();
  TextEditingController itemIdController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController uomController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController configController = TextEditingController();
  TextEditingController styleController = TextEditingController();
  TextEditingController remainedQuantityController = TextEditingController();

   String? selectOUM ;
  final _focusNodeBarcode = FocusNode();

  final _focusNodeQty = FocusNode();
  Widget _buildQrView(BuildContext context, bool isPortail) {
    // controller?.resumeCamera();
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

  var baseUrl;
  List<dynamic> barcodeScanData = [];

  showAlertDialog(BuildContext context, String text) {
    // set up the button
    Widget scanButton = TextButton(
      child: Text("Error Message"),
      onPressed: () {
        print("Scanning code");
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      // title: Text("My title"),
      content: Text("The error is: $text"),
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

  Future<dynamic> _selectMgfDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedMGFDate ?? DateTime.now(),
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(1988),
        lastDate: DateTime(2101));

    // if(selectedFromDate ==null ){
    //
    //   showAlertDialog(
    //       context, "Select the From Date At First");
    //   return;
    // }

    if (picked != null) {
      print(picked);
      print("line 168 is...");
      print(selectedMGFDate);
      // productionDateController.text = selectedMGFDate
      //     .toString();
      //
      // setState((){
      //
      //
      // });
      //

      if (selectedEXPDate != null) {
        if (picked.day == selectedEXPDate!.day &&
            picked.month == selectedEXPDate!.month &&
            picked.year == selectedEXPDate!.year) {
          print("${DateTime.now().day}... ${picked.day} line 293");

          showAlertDialog(context,
              "Select the Expired Date Before  Manufaturer Date line 294");

          return;
        }
      }

      // if(  selectedMGFDate == null)
      //   {
      //
      //     setState(()
      //     {
      //         selectedMGFDate= DateTime.now();
      //     });
      //   }

      if (selectedEXPDate != null) {
        if (picked.isAfter(selectedMGFDate!) && selectedEXPDate != null) {
          print("${DateTime.now().day}... ${picked.day}");

          showAlertDialog(
              context, "Select the Expired Date Before  Manufaturer Date");
          return;
        }

        // if (picked.day > selectedEXPDate!.day
        //     &&   selectedEXPDate != null
        // )
        // {
        //
        //   print("${DateTime.now().day}... ${picked.day}");
        //
        //   showAlertDialog(context, "Select the Expired Date Before  Manufaturer Date");
        //   return;
        // }
        // //
        // if (picked.month > selectedEXPDate!.month
        //     &&   selectedEXPDate !=null)
        // {
        //
        //   print("${DateTime.now().month}... ${picked.month}");
        //
        //   showAlertDialog(context, "Select the Expired Date Before  Manufaturer Date month");
        //   return;
        // }
        // //
        // //
        // if (picked.year > selectedEXPDate!.year
        //     &&   selectedEXPDate !=null)
        // {
        //
        //
        //   print("${DateTime.now().year}... ${picked.year}");
        //
        //   showAlertDialog(context, "Select the Expired Date Before  Manufaturer Date");
        //   return;
        // }
      } else {}
    }

    // if (picked != null) {
    //   print("Selected Date : ${selectedToDate.toString()}");
    //
    //   if(selectedToDate ==null ){
    //
    //     setState((){
    //       selectedToDate = DateTime.now();
    //     });
    //   }
    //   if (picked.day < DateTime.now().day || picked.day > selectedToDate!.day) {
    //     showAlertDialog(
    //         context, "Select the From Date Equal or before To Date");
    //     return;
    //   }
    // }
    setState(() {
      // isFirstLoadFromDate = false;
      selectedMGFDate = picked;
      productionDateController.text = DateFormat.yMd().format(selectedMGFDate!);
    });

    // print();
  }

  Future<dynamic> _selectExpDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedEXPDate ?? DateTime.now(),
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(1988),
        lastDate: DateTime(2101));

    print(picked);
    print("Line 314");

    print(picked!.isBefore(selectedMGFDate!)); //true
    print(picked.isAfter(selectedMGFDate!));
    print("Line 314");

    if (selectedMGFDate == null) {
      showAlertDialog(context, "Select the Manufaturer Date At First");
      return;
    }
    // print(picked.day);
    if (picked != null) {
      if (picked.isBefore(selectedMGFDate!) || picked == selectedMGFDate) {
        print("${DateTime.now().day}... ${picked.day} line 293");

        showAlertDialog(
            context, "Select the Expired Date Before  Manufaturer Date");

        return;
      }

      // if (
      // picked.year < selectedMGFDate!.year
      //
      // &&
      //     picked.month < selectedMGFDate!.month
      //
      //
      //         &&
      //     picked.day < selectedMGFDate!.day
      // )
      // {
      //
      //   print( picked.year < selectedMGFDate!.year
      //       &&
      //       picked.month < selectedMGFDate!.month
      //       &&
      //       picked.day < selectedMGFDate!.day);
      //   print("${DateTime.now().day}... ${picked.day} line 302");
      //
      //   showAlertDialog(context, "Select the Expired Date After  Manufaturer Date Day");
      //   return;
      // }

      // if (picked.month < selectedMGFDate!.month)
      // {
      //
      //
      //   print("${DateTime.now().day}... ${picked.day}");
      //
      //   showAlertDialog(context, "Select the Expired Date After  Manufaturer Date");
      //   return;
      // }
      //
      //
      // if (picked.year < selectedMGFDate!.year)
      // {
      //
      //
      //   print("${DateTime.now().day}... ${picked.day}");
      //
      //   showAlertDialog(context, "Select the Expired Date After  Manufaturer Date year");
      //   return;
      // }

    }

    // if (picked != null) {
    //   print("Selected Date : ${selectedToDate.toString()}");
    //
    //   if(selectedToDate ==null ){
    //
    //     setState((){
    //       selectedToDate = DateTime.now();
    //     });
    //   }
    //   if (picked.day < DateTime.now().day || picked.day > selectedToDate!.day) {
    //     showAlertDialog(
    //         context, "Select the From Date Equal or before To Date");
    //     return;
    //   }
    // }

    setState(() {
      // isFirstLoadFromDate = false;

      selectedEXPDate = picked;
      expDateController.text = DateFormat.yMd().format(selectedEXPDate!);
    });
  }


  getBarcodeWithscan() async {


    print("scanned 374");
    print(transactionData.length);
    if(transactionData.length <=0 ){

      await  showDialogGotData("No Header ,You should add Transcation Header  "
          "");

      setState(() {
        importedSearch = false;
      });
      await controller ?.resumeCamera();
      setState((){

         barcodeController.text= "";
      });
      return;
    }
    if (widget.type == "ST" ||
        widget.type == "GRN" ||
        widget.type == "RP" ||
        widget.type == "TO-OUT" ||
        widget.type == "TO-IN") {
      barcodeScanData = await _sqlHelper.getImportedDetailsBySearchScanBarcode(
          barcodeController.text, transactionData[0]['AXDOCNO']);

      print("line 418");

      barcodeScanData.forEach((element) {
        print(element);
      });
      setState(() {});
      print(barcodeScanData);
      if (barcodeScanData.isEmpty) {
        showDialogGotData("Barcode item Not Exist");
        return;
      }

      var enabledCheck = await _sqlHelper.getImportedDetailsBySearchScanBarcode(
          barcodeController.text, transactionData[0]['AXDOCNO'].toString());

      // var enabledCheck= await _sqlHelper.
      // getITEMMASTERBySearchScanBarcode(barcodeScanData[0]['BARCODE']??"");
 var dts = {
   "DOCNO": transactionData[0]['DOCNO'],
   "ITEMID": barcodeScanData[0]['ITEMID'],
   "ITEMNAME": barcodeScanData[0]['ITEMNAME'],
   "BARCODE": barcodeScanData[0]['ITEMBARCODE'],
   'TRANSTYPE': transType == "STOCK COUNT"
       ? 1
       : widget.type == "GRN"
       ? 4
       : widget.type == "RP"
       ? 10
       : widget.type == "TO-OUT"
       ? 5
       : widget.type == "TO-IN"
       ? 6
       : "",
   "UOM": barcodeScanData[0]['UOM'] ?? ""
 };

 print(dts);



    var  dtTotal =await _sqlHelper.calculateTotal(


    DOCNO: transactionData[0]['DOCNO'],
    ITEMID: barcodeScanData[0]['ITEMID'],
    ITEMNAME: barcodeScanData[0]['ITEMNAME'],
    BARCODE: barcodeScanData[0]['BARCODE'],
    TRANSTYPE:transType == "STOCK COUNT"
    ? 1
        : widget.type == "GRN"
    ? 4
        : widget.type == "RP"
    ? 10
        : widget.type == "TO-OUT"
    ? 5
        : widget.type == "TO-IN"
    ? 6
        : "",
    UOM: barcodeScanData[0]['UOM'] ?? ""

    );

   print("Calculated total : ${dtTotal}");

      var dt ;
     dt = await _sqlHelper.getFindItemExistOrnotTRANSDETAILS(
          DOCNO: transactionData[0]['DOCNO'],
          ITEMID: barcodeScanData[0]['ITEMID'],
          ITEMNAME: barcodeScanData[0]['ITEMNAME'],
          BARCODE: barcodeScanData[0]['BARCODE'],
          TRANSTYPE:transType == "STOCK COUNT"
              ? 1
              : widget.type == "GRN"
              ? 4
              : widget.type == "RP"
              ? 10
              : widget.type == "TO-OUT"
              ? 5
              : widget.type == "TO-IN"
              ? 6
              : "",
          UOM: barcodeScanData[0]['UOM'] ?? "" );
      print(enabledCheck);
      print("widget type : 207");
      print(dts);
      print("widget type : 207");

        setState(() {
        itemIdController.text = barcodeScanData[0]['ITEMID'] ?? "";
        descriptionController.text = barcodeScanData[0]['ITEMNAME'] ?? "";
        disabledUOMSelection == "true"
            ? selectOUM = barcodeScanData[0]['UOM'] ?? ""

            : uomController.text = barcodeScanData[0]['UOM'] ?? "";
        sizeController.text = barcodeScanData[0]['SIZE'] == null
            ? ""
            : barcodeScanData[0]['SIZE']?.toString() ?? "";
        colorController.text = barcodeScanData[0]['COLORID']?.toString() ?? "";
        styleController.text = barcodeScanData[0]['STYLESID']?.toString() ?? "";
        configController.text =
            barcodeScanData[0]['CONFIGID']?.toString() ?? "";






        // print(barcodeScanData[0]['QTY'] ??"" );
        // print(barcodeScanData[0]['QTY'].runtimeType ??"");
        // print(dt[0]['QTY'].runtimeType ??"");
        // print(dt[0]['QTY'] ??"");
        //
        // print(barcodeScanData[0]['QTY'].runtimeType??"");
        // print(dt[0]['QTY'].runtimeType??"");

      double receivedqty=  double.parse(barcodeScanData[0]['QTY'].toString());
     double pulledqty = dt.length >0 ?
     double.parse( dtTotal[0]['Total'].toString()):
     0.0;
     double totalqty=
         receivedqty - pulledqty;







     print("Old qty : ${dtTotal[0]['Total'].toString()}");
     print("Total qty : 506 ${totalqty}");

        remainedQuantityController.text =
        (dt.length < 0 ?

        barcodeScanData[0]['QTY']?.toString()
         :

        totalqty .toString())!;
        isBatchEnabled =
            enabledCheck[0]['BatchEnabled'].toString() == "1" ? true : false;
        BatchedItem =
            enabledCheck[0]['BatchedItem'].toString() == "1" ? true : false;
      });





    var continousScan = disabledContinuosScan == "true"
          ? true
          : false;

     print("Continous scan line 549.. ${continousScan} ...${transType}");

     print("Batch Values : ${isBatchEnabled}"
         "${BatchedItem}");

      if (continousScan &&
          transType == "STOCK COUNT")
      {

        var dt = await _sqlHelper
            .getFindItemExistOrnotTRANSDETAILS(
           DOCNO: transactionData[0]['DOCNO'],
            ITEMID:  barcodeScanData[0]['ITEMID'],
            ITEMNAME:
            barcodeScanData[0]
            ['ITEMNAME'],
            BARCODE:
            barcodeScanData[0]
            ['BARCODE'],
            TRANSTYPE: transType ==
                "STOCK COUNT"
                ? 1
                : widget.type ==
                "PO"
                ? 2
                : "",
            UOM:
            barcodeScanData[0]['UOM']);

        print("exist check line .. ${dt.length}");


        if (dt.length > 0) {

          if(continousScan &&
              (barcodeScanData[0][
              'BatchEnabled']
                  .toString() ==
                  "1" &&
                  barcodeScanData[0][
                  'BatchedItem']
                      .toString() ==
                      "0")&&
              (transType ==
                  "STOCK COUNT" ||
                  widget.type ==
                      "ST")
          )
          {


          }
          else{



            await _sqlHelper
                .updateTRANSDETAILSWithQty(
                dt[0]['id'],
                int.parse(
                    dt[0]['QTY']) +
                    1);


        await    ScaffoldMessenger.of(context)
                .showSnackBar(
              const SnackBar(
                  backgroundColor:
                  Colors.red,
                  content: Text(
                    'Item Adding Successfully',
                    textAlign:
                    TextAlign.center,
                  )),
            );


            setState(()


            {

              barcodeController.text="";
              itemIdController.text =  "";
              descriptionController.text =  "";

              sizeController.text ="";
              colorController.text =  "";
              styleController.text =  "";
              configController.text =
                   "";

              // isBatchEnabled = false;
              // BatchedItem = false;

              batchNoController.text = "";

              expDateController.text = "";
              productionDateController.text = "";

              selectedEXPDate = null;
              uomController.text="";
              selectedMGFDate= null;
              selectOUM=null;

              remainedQuantityController.text = "";

              qtyController.text =  "";





            });

            FocusScope.of(context)
                .requestFocus(_focusNodeBarcode);
          }
          FocusScope.of(context)
              .requestFocus(_focusNodeBarcode);

        }
        else {
              print("line 662");
              print(continousScan &&
                  (barcodeScanData[0][
                  'BatchEnabled']
                      .toString() ==
                      "1" &&
                      barcodeScanData[0][
                      'BatchedItem']
                          .toString() ==
                          "0")&&
                  (transType ==
                      "STOCK COUNT" ||
                      widget.type ==
                          "ST")
              );

          if(
          continousScan &&
              (barcodeScanData[0][
              'BatchEnabled']
                  .toString() ==
                  "1" &&
              barcodeScanData[0][
              'BatchedItem']
                  .toString() ==
                  "0") &&
              (transType ==
                  "STOCK COUNT" ||
              widget.type ==
                  "ST")
          )
          {


            print(
                continousScan &&
                    barcodeScanData[0][
                    'BatchEnabled']
                        .toString() ==
                        "1" &&
                    barcodeScanData[0][
                    'BatchedItem']
                        .toString() ==
                        "0" &&
                    transType ==
                        "STOCK COUNT" ||
                    widget.type ==
                        "ST"
            );

            print( barcodeScanData[0][
            'BatchedItem']
                .toString() ==
                "0");
            print("line 679 : ${!_focusNodeBarcode.hasFocus}"
                "${!_focusNodeQty.hasFocus}");

            if(!_focusNodeBarcode.hasFocus){


              // Focus.of(context).unfocus();

              // Focus.of(context).notifyListeners();
              Focus.of(context).requestFocus(_focusNodeQty);
            }


          }
          else{



            print("Line 744 ");
// return;

            await _sqlHelper
                .addTRANSDETAILS(
                HRecId: transactionData[0]
                ['RecId'],
                STATUS: 0,
                AXDOCNO: transactionData[0]
                ['AXDOCNO'],
                DOCNO: transactionData[0]
                ['DOCNO'],
                ITEMID:  itemIdController.text,
                ITEMNAME: descriptionController.text,
                TRANSTYPE: transType ==
                    "STOCK COUNT"
                    ? 1
                    : widget.type ==
                    "PO"
                    ? 2
                    : "",
                DEVICEID:
                activatedDevice,
                QTY: 1,
                UOM: disabledUOMSelection == "true"
                    ?  selectOUM
                    : uomController.text,
                BARCODE: barcodeController.text,
                CREATEDDATE: DateTime.now()
                    .toString(),
                INVENTSTATUS:  barcodeScanData[0]
                ['INVENTSTATUS'],
                SIZEID: sizeController.text ,
                COLORID: colorController.text ,
                CONFIGID:configController.text ,
                STYLESID: styleController.text,
                STORECODE: activatedStore,
                LOCATION: transactionData[0]['VRLOCATION'].toString(),

              BatchEnabled: isBatchEnabled,
              BatchedItem: BatchedItem

            );

            // print("Batch Values : ${isBatchEnabled}"
            //     "${BatchedItem}");

            ScaffoldMessenger.of(context)
                .showSnackBar(
              const SnackBar(
                  backgroundColor:
                  Colors.red,
                  content: Text(
                    'Item Adding Successfully',
                    textAlign:
                    TextAlign.center,
                  )),
            );



            setState(()

            {

              selectOUM=null;
              barcodeController.text ="";
              itemIdController.text =  "";
              descriptionController.text =  "";

              sizeController.text ="";
              colorController.text =  "";
              styleController.text =  "";
              configController.text =
              "";



              // isBatchEnabled = false;
              // BatchedItem = false;

              batchNoController.text = "";

              expDateController.text = "";
              productionDateController.text = "";

              selectOUM=null;
              selectedEXPDate = null;
              uomController.text="";
              selectedMGFDate= null;

              remainedQuantityController.text = "";

              qtyController.text =  "";



            });
            FocusScope.of(context)
                .requestFocus(_focusNodeBarcode);
          }

              Focus.of(context).requestFocus(_focusNodeBarcode);


          return;
        }

        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) =>
        //             TransactionViewPage(
        //               currentIndex: 1,
        //               pageType: widget
        //                   .transactionType,
        //             )));

        if (continousScan &&
            transType ==
                "STOCK COUNT" ||
            widget.type ==
                "ST") {
          print("BATCH Check line 718");

          print( barcodeScanData[0]
          ['BatchEnabled']
              .runtimeType);

          print( barcodeScanData[0]
          ['BatchedItem']);
        }


        if (continousScan &&
            barcodeScanData[0][
            'BatchEnabled']
                .toString() ==
                "1" &&
            barcodeScanData[0][
            'BatchedItem']
                .toString() ==
                "0" &&
           transType ==
                "STOCK COUNT" ||
            widget.type ==
                "ST") {


          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) =>
          //             TransactionViewPage(
          //               isImportedSearch:
          //               true,
          //               currentIndex: 1,
          //               pageType: widget
          //                   .transactionType,
          //               transDetails:
          //               itemImportedLists[
          //               index],
          //             )));
        }
        else
        {

          if (continousScan &&
             transType ==
                  "STOCK COUNT" ||
              widget.type ==
                  "ST") {
            print("Line 921");




            await _sqlHelper
                .addTRANSDETAILS(
                HRecId: transactionData[0]
                ['RecId'],
                STATUS: 0,
                AXDOCNO: transactionData[0]
                ['AXDOCNO'],
                DOCNO: transactionData[0]
                ['DOCNO'],
                ITEMID:  itemIdController.text,
                ITEMNAME:descriptionController.text,
                TRANSTYPE: transType ==
                    "STOCK COUNT"
                    ? 1
                    : widget.type ==
                    "PO"
                    ? 2
                    : "",
                DEVICEID:
                activatedDevice,
                QTY: 1,
                UOM:disabledUOMSelection == "true"
            ?  selectOUM
                : uomController.text,
                BARCODE:  barcodeController.text.trim(),
                CREATEDDATE: DateTime.now()
                    .toString(),
                INVENTSTATUS:  barcodeScanData[0]
                ['INVENTSTATUS'],
                SIZEID: sizeController.text ,
                COLORID: colorController.text ,
                CONFIGID:configController.text ,
                STYLESID: styleController.text ,
                STORECODE: activatedStore,
                LOCATION: transactionData[0]['VRLOCATION'].toString(),
            BatchEnabled: isBatchEnabled,
            BatchedItem: BatchedItem);



          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
                backgroundColor:
                Colors.red,
                content: Text(
                  'Item Adding Successfully',
                  textAlign:
                  TextAlign.center,
                )),
          );




          setState(()

          {

            barcodeController.text = "";
            itemIdController.text =  "";
            descriptionController.text =  "";

            sizeController.text ="";
            colorController.text =  "";
            styleController.text =  "";
            configController.text =
            "";

            // isBatchEnabled = false;
            // BatchedItem = false;

            batchNoController.text = "";

            expDateController.text = "";
            productionDateController.text = "";

            selectedEXPDate = null;
            selectedMGFDate= null;

            remainedQuantityController.text = "";

            qtyController.text =  "";

            selectOUM=null;
            uomController.text ="";




          });
            FocusScope.of(context)
                .requestFocus(_focusNodeBarcode);

          } else {

          }
        }
      }



      FocusScope.of(context).focusedChild?.unfocus();
      FocusScope.of(context).nextFocus();
      FocusManager.instance.primaryFocus!.requestFocus(_focusNodeBarcode);
      Focus.of(context).requestFocus(_focusNodeBarcode);


      if(barcodeController.text.trim() !=""){

        FocusScope.of(context).requestFocus(_focusNodeQty);
        print(barcodeScanData);
        // FocusManager.instance.primaryFocus?.unfocus();
        //
        //  Focus.of(context).requestFocus(_focusNodeBarcode);
        // FocusScope.of(context).focusedChild?.unfocus();
        //
        // Focus.of(context).requestFocus(_focusNodeBarcode);
      }
      else{
        FocusScope.of(context).requestFocus(_focusNodeBarcode);
        print(barcodeScanData);
      }

      print(enabledCheck[0]);
      print("print line 391...${enabledCheck[0]['BatchEnabled'].toString()}");
      print("print line 392...${enabledCheck[0]['BatchedItem'].toString()}");
    }

    if (widget.type == "PO" || widget.type == "RO" || widget.type == "TO") {
      barcodeScanData = await _sqlHelper
          .getITEMMASTERBySearchScanBarcode(barcodeController.text);
      setState(() {
        barcodeController.text = barcodeScanData[0]['ITEMBARCODE'];
        itemIdController.text = barcodeScanData[0]['ItemId'] ?? "";
        descriptionController.text = barcodeScanData[0]['ItemName'] ?? "";
        // uomController.text= barcodeScanData[0]['UNIT'];
        disabledUOMSelection == "true"
            ? selectOUM = barcodeScanData[0]['UNIT'] ?? ""
            : uomController.text = barcodeScanData[0]['UNIT'] ?? "";
        sizeController.text = barcodeScanData[0]['SIZEID'] == null
            ? ""

            : barcodeScanData[0]['SIZEID']?.toString() ?? "";
        colorController.text = barcodeScanData[0]['COLORID'] ?? "";
        styleController.text = barcodeScanData[0]['STYLEID'] ?? "";
        configController.text = barcodeScanData[0]['CONFIGID'] ?? "";
        remainedQuantityController.text =
            barcodeScanData[0]['QTY']?.toString() ?? "";

        // itemIdController.text = barcodeScanData[0]['ITEMiD']??"";
        // descriptionController.text = barcodeScanData[0]['ITEMNAME']??"";
        // uomController.text = barcodeScanData[0]['UOM']??"";
        // sizeController.text = barcodeScanData[0]['SIZE'] ==null ? "": barcodeScanData[0]['SIZE'].toString()??"" ;
        // colorController.text = barcodeScanData[0]['COLORID'].toString()??"";
        // styleController.text = barcodeScanData[0]['STYLEID'].toString()??"";
        // configController.text = barcodeScanData[0]['CONFIGID'].toString()??"";
      });
    }


    if(barcodeController.text.trim() !=""){

      FocusScope.of(context).requestFocus(_focusNodeQty);
      print(barcodeScanData);
      // FocusManager.instance.primaryFocus?.unfocus();
      //
      //  Focus.of(context).requestFocus(_focusNodeBarcode);
      // FocusScope.of(context).focusedChild?.unfocus();
      //
      // Focus.of(context).requestFocus(_focusNodeBarcode);
    }
    else{
      FocusScope.of(context).requestFocus(_focusNodeBarcode);
      print(barcodeScanData);
    }





  }

  Future<void> _onQRViewCreated(QRViewController controller) async {

    // controller.scannedDataStream.
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData)  {


      itemIdController.clear();
      barcodeController.clear();
      descriptionController.clear();
      uomController.clear();
      sizeController.clear();
      colorController.clear();
      styleController.clear();
      configController.clear();
      qtyController.clear();
      remainedQuantityController.clear();


      setState(() {
        result = scanData;
        print("scan result : 953");

        barcodeController.text = result!.code.toString();

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

      getBarcodeWithscan();

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

  lastDisposeValues() {}

  @override
  void dispose() {
    _focusNodeBarcode.dispose();
    _focusNodeQty.dispose();
    controller?.dispose();

    itemIdController.clear();
    barcodeController.clear();
    descriptionController.clear();
    uomController.clear();
    sizeController.clear();
    colorController.clear();
    styleController.clear();
    configController.clear();
    qtyController.clear();
    expDateController.clear();
    productionDateController.clear();
    batchNoController.clear();
    remainedQuantityController.clear();
    // setState((){
    //
    // });
    // lastDisposeValues();

    super.dispose();
  }

  var transType = "";

  getTransTypes() {
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
  dynamic APPGENERALDATASave;
  String? activatedStore;
  String? activatedDevice;
  String? remainedQty;
  bool? importedSearch;

  TextEditingController expDateController = TextEditingController();
  TextEditingController batchNoController = TextEditingController();
  TextEditingController productionDateController = TextEditingController();

  DateTime? selectedEXPDate = null;
  DateTime? selectedMGFDate = null;

  DateTime nowDate = DateTime.now();
 bool ? lineDeleted = false;

  getTransactionDetails() async {



  widget.isImportedSearch != null
        && widget.isImportedSearch! ?

      setState(() {
      importedSearch = true;

      }):
      setState(() {
        importedSearch =false;

      });

    await controller?.resumeCamera();
    // await controller?.toggleFlash();
    print("line 642 ...");
    if (widget.touchTab != null && widget.touchTab!) {
      setState(() {
        itemIdController.text = "";
        barcodeController.text = "";
        descriptionController.text = "";
        uomController.text = "";
        sizeController.text = "";
        colorController.text = "";
        styleController.text = "";
        configController.text = "";
        qtyController.text = "";
        expDateController.text = "";
        productionDateController.clear();
        batchNoController.text = "";
        remainedQuantityController.text = "";
      });
    }


    print("route location ...274");

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
                            : widget.type == 'TO-OUT'
                                ? "5"
                                : widget.type == 'TO-IN'
                                    ? "6"
                                    : "");

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
    print("data 257 at above");
    print(barcodeScanData.isNotEmpty);
  print(widget.transDetails);
    print(importedSearch);

    if(lineDeleted !=null && lineDeleted!)
    {

      FocusScope.of(context).requestFocus(_focusNodeBarcode);

      itemIdController.clear();
      barcodeController.clear();
      descriptionController.clear();
      uomController.clear();
      sizeController.clear();
      colorController.clear();
      styleController.clear();
      configController.clear();
      qtyController.clear();
      expDateController.clear();
      productionDateController.clear();
      batchNoController.clear();
      selectedEXPDate = null;
      selectedMGFDate = null;

      remainedQuantityController.clear();



      setState((){

      });

   await prefs!.setBool("lineDeleted", false);

      return;
    }



    if (importedSearch != null && importedSearch! ) {
      print("data 257 at below");
      print(widget.transDetails);

      // if condition in
      // Purchase order -PO
      // Transfer order -TO
      // Return order - RO

      if (widget.type == "PO" || widget.type == "RO" || widget.type == "TO") {
        setState(() {
          barcodeController.text = widget.transDetails['ITEMBARCODE'];
          itemIdController.text = widget.transDetails['ItemId'] ?? "";
          descriptionController.text = widget.transDetails['ItemName'] ?? "";
          // uomController.text= widget.transDetails['UNIT'];
          disabledUOMSelection == "true"
              ? selectOUM = widget.transDetails['UNIT'] ?? ""
              : uomController.text = widget.transDetails['UNIT'] ?? "";
          sizeController.text = widget.transDetails['SIZEID'] ?? "";
          colorController.text = widget.transDetails['COLORID'] ?? "";
          styleController.text = widget.transDetails['STYLEID'] ?? "";
          configController.text = widget.transDetails['CONFIGID'] ?? "";
          remainedQuantityController.text =
              barcodeScanData[0]['QTY']?.toString() ?? "";
          // isBatchEnabled = barcodeScanData[0]['BatchEnabled'] ??false;
        });
        // {id: 8, ITEMBARCODE: 3330430011213, ItemId: 33304300,
        // ItemName: EGO QV KIDS BAR 100GM, DATAAREAID: 1000, WAREHOUSE: ,
        // CONFIGID: , COLORID: , SIZEID: , STYLEID: , INVENTSTATUS: , QTY: 0.0,
        // UNIT: PCS, ItemAmount: 0.0}
      }

      // else conditon
      // ST -stock count
      // GRN -goods receive
      //others
      else {
        // var   enabledCheck= await _sqlHelper.
        //   getITEMMASTERBySearchScanBarcode(widget.transDetails['BARCODE']);


        var dts = {
          "DOCNO": transactionData[0]['DOCNO'],
          "ITEMID": widget.transDetails['ITEMID'],
          "ITEMNAME": widget.transDetails['ITEMNAME'],
          "BARCODE": widget.transDetails['BARCODE'],
          "TRANSTYPE":transType == "STOCK COUNT"
              ? 1
              : widget.type == "GRN"
              ? 4
              : widget.type == "RP"
              ? 10
              : widget.type == "TO-OUT"
              ? 5
              : widget.type == "TO-IN"
              ? 6
              : "",
          "UOM": widget.transDetails['UOM'] ?? ""
        };

        print(dts);
        print("imported search line 808");
        print(widget.transDetails['QTY']);
        print(transactionData[0]['DOCNO']);


        var  dtTotal =await _sqlHelper.calculateTotal(


            DOCNO: transactionData[0]['DOCNO'],
            ITEMID: widget.transDetails['ITEMID'],
            ITEMNAME: widget.transDetails['ITEMNAME'],
            BARCODE: widget.transDetails['BARCODE'],
            TRANSTYPE:transType == "STOCK COUNT"
                ? 1
                : widget.type == "GRN"
                ? 4
                : widget.type == "RP"
                ? 10
                : widget.type == "TO-OUT"
                ? 5
                : widget.type == "TO-IN"
                ? 6
                : "",
            UOM: widget.transDetails['UOM'] ?? ""


        );

        print("Calculated total : ${dtTotal}");

        var dtq ;
        dtq = await _sqlHelper.getFindItemExistOrnotTRANSDETAILS(

            DOCNO: transactionData[0]['DOCNO'],
            ITEMID: widget.transDetails['ITEMID'],
            ITEMNAME: widget.transDetails['ITEMNAME'],
            BARCODE: widget.transDetails['BARCODE'],
            TRANSTYPE:transType == "STOCK COUNT"
                ? 1
                : widget.type == "GRN"
                ? 4
                : widget.type == "RP"
                ? 10
                : widget.type == "TO-OUT"
                ? 5
                : widget.type == "TO-IN"
                ? 6
                : "",
            UOM: widget.transDetails['UOM'] ?? "" );


        var enabledCheck =
            await _sqlHelper.getImportedDetailsBySearchScanBarcode(
                widget.transDetails['BARCODE'],
                widget.transDetails['AXDOCNO'].toString());


        // print();
        print("widget type : 840");
        print(dtq);
        print(widget.type);
        setState(() {


          double receivedqty=  double.parse(
              widget.transDetails['QTY'].toString());
          double pulledqty = dtq.length >0 ?
          double.parse( dtTotal[0]['Total'].toString()):
          0.0;
          double totalqty=
              receivedqty - pulledqty;


          print(receivedqty);
          print(pulledqty);
          print("Total qty : ${totalqty.toString()}");
          print(dtq.length);


          remainedQuantityController.text =
          (dtq.length < 0 ?

          widget.transDetails['QTY']?.toString()
              :
          totalqty.toString())!;

          barcodeController.text = widget.transDetails['BARCODE'];
          itemIdController.text = widget.transDetails['ITEMID'] ?? "";
          descriptionController.text = widget.transDetails['ITEMNAME']??"";
          // uomController.text= widget.transDetails['UOM'];
          disabledUOMSelection == "true"
              ? selectOUM = widget.transDetails['UOM'] ?? ""
              : uomController.text = widget.transDetails['UOM'] ?? "";
          sizeController.text = widget.transDetails['SIZEID'] ?? "";
          colorController.text = widget.transDetails['COLORID'] ?? "";
          styleController.text = widget.transDetails['STYLESID'] ?? "";
          configController.text = widget.transDetails['CONFIGID'] ?? "";


          isBatchEnabled =
              enabledCheck[0]['BatchEnabled'].toString() == "1" ? true : false;
          BatchedItem =
              enabledCheck[0]['BatchedItem'].toString() == "1" ? true : false;
          print("remaining qty ...337 : ${remainedQuantityController.text}");

          // qtyController.text= "1";

          //  {id: 212, AXDOCNO: INVJ011839, STORECODE: AJM0028,
          //  BARCODE: 3330002802249, TRANSTYPE: 1,
          // ITEMID: 33300028, ITEMNAME: EGO QV LIP BALM 15GM,
          // UOM: PCS, QTY: 0.0,
          // DEVICEID: Device2, CONFIGID: , SIZEID: ,
          // COLORID: , STYLESID: , INVENTSTATUS: Available}


        });

        print(enabledCheck[0]);
        print("print line 391...${enabledCheck[0]['BatchEnabled'].toString()}");
        print("print line 392...${enabledCheck[0]['BatchedItem'].toString()}");
      }




      FocusScope.of(context).requestFocus(_focusNodeQty);
    }


  if(barcodeController.text.trim() ==""){
    FocusScope.of(context).nextFocus();
    FocusManager.instance.primaryFocus!.requestFocus(_focusNodeBarcode);
    Focus.of(context).requestFocus(_focusNodeBarcode);
  }

  }

  getToken() async {
    getTransTypes();
    setState(() {});

    print("init Api");

    print(controller?.hasPermissions);

    prefs = await SharedPreferences.getInstance();
    print("camera status");
    print(await prefs?.getString("camera"));
    disableCamera = await prefs?.getString("camera");

    var v = await prefs?.getString("disableCamera");
    disableCamera = v.toString() == "true" ? "true" : "false";

    // await prefs?.getString("disableCamera");
    // disabledCamera = prefs?.getString("disableCamera") == "true" ? true : false;
    disabledUOMSelection =
        await prefs?.getString("enableUOMSelection") ?? "false";
    print("disables app generals 401 : ${disabledUOMSelection}");
    await prefs?.getString("enableUOMSelection");
    // disabledUOMSelection =
    //    await prefs?.getString("enableUOMSelection") == "true" ? "true" : "false";
    await prefs?.getString("enableContinuousScan");
    disabledContinuosScan =
        await prefs?.getString("enableContinuousScan") == "true"
            ? "true"
            : "false";
    showDimension = await prefs?.getBool("showDimensions")
        ==null
        ||
        await prefs?.getBool("showDimensions")
            == false ?false:
    true;

   showQuantityExceed =
   await  prefs?.getBool("showQuantityExceed")==null
       ||
   await  prefs?.getBool("showQuantityExceed")== false ?false:
   true;
    setState(() {});
    print("uom data available 398");
    if (disabledUOMSelection == "true") {
      print("uom data available 400");
      getUOM();
    }
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
    pushStockTakeApi = await prefs!.getString("pushStockTakeApi");

    getDevice = await prefs!.getString("getDevice");
    getStore = await prefs!.getString("getStore");
    getDeactivate = await prefs!.getString("deactivate");
    updateDevice = await prefs!.getString("updateDevice");

    lineDeleted = await prefs!.getBool("lineDeleted")?? false;
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

  bool? isFocus = true;

  List<dynamic> uomList = [];
  getUOM() async {
    print(await _sqlHelper.getUOMMessures());
    uomList.addAll(await _sqlHelper.getUOMMessures());


    setState(() {});
  }

  @override
  void initState() {
    getTransactionDetails();
    print("uom data available 493 : ${disabledUOMSelection}");

    getToken();

    _focusNodeBarcode.addListener(() async {

      // if(barcodeController.text.trim() != ""){
      //   // Focus.of(context).unfocus();
      //   Focus.of(context).requestFocus(_focusNodeBarcode);
      //   setState((){
      //   });
      //
      //
      // }
      // else{
      //   // Focus.of(context).unfocus();
      //   Focus.of(context).requestFocus(_focusNodeQty);
      //   setState((){
      //
      //
      //   });
      // }
      if (!_focusNodeBarcode.hasFocus) {
        // setState((){
        //   isFocus=false;
        // });
        print("Has focus: ${_focusNodeQty.hasFocus}");
        print("Has focus situation : ${_focusNodeBarcode.hasFocus}");
        print("has boolean : ${isFocus.toString()}");
      } else {

        print("Has focus: ${_focusNodeQty.hasFocus}");
        print("Has focus situation : ${_focusNodeBarcode.hasFocus}");
        print("has boolean : ${isFocus.toString()}");
        // setState((){
        //   isFocus=true;
        // });
      }

      if (_focusNodeBarcode.hasFocus && !isFocus!) {
        // itemIdController.clear();
        // barcodeController.clear();
        // descriptionController.clear();
        // uomController.clear();
        // sizeController.clear();
        // colorController.clear();
        // styleController.clear();
        // configController.clear();
        // qtyController.clear();
        // remainedQuantityController.clear();

      }
    });

    _focusNodeQty.addListener(() {
      //



      // if(barcodeController.text.trim() != ""){
      //   // Focus.of(context).unfocus();
      //   Focus.of(context).requestFocus(_focusNodeBarcode);
      //   setState((){
      //   });
      //
      //
      // }
      // else{
      //   // Focus.of(context).unfocus();
      //   Focus.of(context).requestFocus(_focusNodeQty);
      //   setState((){
      //
      //
      //   });
      // }


      if (!_focusNodeQty.hasFocus) {
        // FocusScope.of(context).requestFocus(_focusNodeBarcode);

        // itemIdController.clear();
        // barcodeController.clear();
        // descriptionController.clear();
        // uomController.clear();
        // sizeController.clear();
        // colorController.clear();
        // styleController.clear();
        // configController.clear();
        // qtyController.clear();
        // remainedQuantityController.clear();
        // setState((){
        //
        // });
      }
    });
    super.initState();
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

  showDialogCheckQuantity(String text) {
    // print("old qty ...1044 ${oldqty}");
    print("Line 1045  quantity ordering .. "
        "${double.parse(qtyController.text).toString()}");

    print("Line 1047 quantity available .. "
        "${double.parse(remainedQuantityController.text).toString()}");

    print(double.parse(qtyController.text) >
        double.parse(remainedQuantityController.text));


    Widget okButton = TextButton(
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

    AlertDialog alert = AlertDialog(
          title: Text("DynamicsConnect"),
          content: Text(
            "Quantity Exceed"

          ),

          actions: [okButton],
        );

    //
    //
    //
    // ----commented lines -----// old qunaity exceed

    // // set up the button
    // Widget yesButton = TextButton(
    //   style: APPConstants().btnBackgroundYes,
    //   child: Text("Yes", style: APPConstants().YesText),
    //   onPressed: () async {
    //     // var selectedExpDateFormatted =
    //     // DateFormat("yyyy-MM-ddTHH:mm:ss")
    //     //     .format(selectedEXPDate!);
    //     //
    //     // var selectedmgfDateFormatted =
    //     //
    //     // DateFormat("yyyy-MM-ddTHH:mm:ss")
    //     //     .format(selectedMGFDate!);
    //     if (importedSearch != null && importedSearch!) {
    //       print("Data from imported Search 1062");
    //       print(widget.transDetails);
    //       print(transactionData);
    //       print(transType);
    //       //
    //       // return;
    //
    //       var dt = await _sqlHelper.getFindItemExistOrnotTRANSDETAILS(
    //           DOCNO: transactionData[0]['DOCNO'],
    //           ITEMID: widget.transDetails['ITEMID'],
    //           ITEMNAME: widget.transDetails['ITEMNAME'],
    //           BARCODE: widget.transDetails['BARCODE'],
    //           TRANSTYPE: transType == "STOCK COUNT"
    //               ? 1
    //               : widget.type == "GRN"
    //                   ? 4
    //                   : widget.type == "RP"
    //                       ? 10
    //                       : "",
    //           UOM: widget.transDetails['UOM']);
    //
    //       print("Line 1081");
    //       dt.forEach(print);
    //       print(dt.length);
    //
    //       if (dt.length > 0) {
    //         if (isBatchEnabled! &&
    //                 !BatchedItem! &&
    //                 dt[0]['BATCHNO'] != batchNoController.text.trim() &&
    //                 widget.type == "GRN" ||
    //             widget.type == "ST") {
    //           await _sqlHelper.addTRANSDETAILS(
    //               HRecId: transactionData[0]['RecId'],
    //               STATUS: 1,
    //               AXDOCNO: transactionData[0]['AXDOCNO'],
    //               DOCNO: transactionData[0]['DOCNO'],
    //               ITEMID: widget.transDetails['ITEMID'],
    //               ITEMNAME: widget.transDetails['ITEMNAME'],
    //               TRANSTYPE: transType == "STOCK COUNT"
    //                   ? 1
    //                   : widget.type == "GRN"
    //                       ? 4
    //                       : widget.type == "RP"
    //                           ? 10
    //                           : "",
    //               DEVICEID: activatedDevice,
    //               QTY: int.parse(qtyController.text),
    //               UOM: widget.transDetails['UOM'],
    //               BARCODE: widget.transDetails['BARCODE'],
    //               CREATEDDATE: DateTime.now().toString(),
    //               INVENTSTATUS: widget.transDetails['INVENTSTATUS'],
    //               SIZEID: widget.transDetails['SIZEID'],
    //               COLORID: widget.transDetails['COLORID'],
    //               CONFIGID: widget.transDetails['CONFIGID'],
    //               STYLESID: widget.transDetails['STYLESID'],
    //               STORECODE: activatedStore,
    //               LOCATION: transactionData[0]['VRLOCATION'].toString(),
    //               BATCHNO: batchNoController.text.trim(),
    //               EXPDATE: selectedEXPDate.toString(),
    //               // selectedExpDateFormatted.toString(),
    //               PRODDATE: selectedMGFDate.toString(),
    //               // selectedmgfDateFormatted.toString(),
    //               BatchEnabled: isBatchEnabled,
    //               BatchedItem: BatchedItem);
    //
    //           productionDateController.clear();
    //           expDateController.clear();
    //           batchNoController.clear();
    //           selectedMGFDate = null;
    //           selectedEXPDate = null;
    //
    //           // await   controller?.resumeCamera();
    //
    //           setState(() {});
    //         } else {
    //           await _sqlHelper.updateTRANSDETAILSWithQty(dt[0]['id'],
    //               int.parse(dt[0]['QTY']) + int.parse(qtyController.text));
    //           productionDateController.clear();
    //           expDateController.clear();
    //           batchNoController.clear();
    //           selectedMGFDate = null;
    //           selectedEXPDate = null;
    //           // await  controller?.resumeCamera();
    //
    //           setState(() {});
    //         }
    //       } else {
    //         await _sqlHelper.addTRANSDETAILS(
    //             HRecId: transactionData[0]['RecId'],
    //             STATUS: 1,
    //             AXDOCNO: transactionData[0]['AXDOCNO'],
    //             DOCNO: transactionData[0]['DOCNO'],
    //             ITEMID: widget.transDetails['ITEMID'],
    //             ITEMNAME: widget.transDetails['ITEMNAME'],
    //             TRANSTYPE: transType == "STOCK COUNT"
    //                 ? 1
    //                 : widget.type == "GRN"
    //                     ? 4
    //                     : widget.type == "RP"
    //                         ? 10
    //                         : "",
    //             DEVICEID: activatedDevice,
    //             QTY: int.parse(qtyController.text),
    //             UOM: widget.transDetails['UOM'],
    //             BARCODE: widget.transDetails['BARCODE'],
    //             CREATEDDATE: DateTime.now().toString(),
    //             INVENTSTATUS: widget.transDetails['INVENTSTATUS'],
    //             SIZEID: widget.transDetails['SIZEID'],
    //             COLORID: widget.transDetails['COLORID'],
    //             CONFIGID: widget.transDetails['CONFIGID'],
    //             STYLESID: widget.transDetails['STYLESID'],
    //             STORECODE: activatedStore,
    //             LOCATION: transactionData[0]['VRLOCATION'].toString(),
    //             BATCHNO: batchNoController.text.trim(),
    //             EXPDATE: selectedEXPDate.toString(),
    //             // selectedExpDateFormatted.toString(),
    //             PRODDATE: selectedMGFDate.toString(),
    //             // selectedmgfDateFormatted.toString(),
    //             BatchEnabled: isBatchEnabled,
    //             BatchedItem: BatchedItem);
    //       }
    //
    //       itemIdController.clear();
    //       barcodeController.clear();
    //       descriptionController.clear();
    //       uomController.clear();
    //       sizeController.clear();
    //       colorController.clear();
    //       styleController.clear();
    //       configController.clear();
    //       qtyController.clear();
    //       remainedQuantityController.clear();
    //       productionDateController.clear();
    //       expDateController.clear();
    //       batchNoController.clear();
    //       selectedMGFDate = null;
    //       selectedEXPDate = null;
    //
    //       // await    controller?.resumeCamera();
    //
    //       setState(() {});
    //
    //       setState(() {
    //         isFocus = false;
    //         importedSearch = false;
    //       });
    //       FocusScope.of(context).unfocus();
    //       // Navigator.push(context, MaterialPageRoute(
    //       //     builder: (context)=>TransactionViewPage(
    //       //       currentIndex: 1,
    //       //       pageType: widget.transactionType,
    //       //     )));
    //     } else {
    //       print("Data from imported Search 674");
    //       print(widget.transDetails);
    //       print(transactionData);
    //       print(transType);
    //       // return;
    //       var dt = await _sqlHelper.getFindItemExistOrnotTRANSDETAILS(
    //           DOCNO: transactionData[0]['DOCNO'],
    //           ITEMID: itemIdController.text,
    //           ITEMNAME: descriptionController.text,
    //           BARCODE: barcodeController.text,
    //           TRANSTYPE: transType == "STOCK COUNT"
    //               ? 1
    //               : widget.type == "GRN"
    //                   ? 4
    //                   : transType == "RETURN PICK"
    //                       ? 10
    //                       : "",
    //           UOM: disabledUOMSelection == "true"
    //               ? selectOUM
    //               : uomController.text);
    //
    //       print("Line 1174");
    //       dt.forEach(print);
    //       print(dt.length);
    //
    //       if (dt.length > 0) {
    //         if (isBatchEnabled! &&
    //                 !BatchedItem! &&
    //                 dt[0]['BATCHNO'] != batchNoController.text.trim() &&
    //                 widget.type == "GRN" ||
    //             widget.type == "ST") {
    //           await _sqlHelper.addTRANSDETAILS(
    //               HRecId: transactionData[0]['RecId'],
    //               STATUS: 1,
    //               AXDOCNO: transactionData[0]['AXDOCNO'],
    //               DOCNO: transactionData[0]['DOCNO'],
    //               ITEMID: widget.transDetails['ITEMID'],
    //               ITEMNAME: widget.transDetails['ITEMNAME'],
    //               TRANSTYPE: transType == "STOCK COUNT"
    //                   ? 1
    //                   : widget.type == "GRN"
    //                       ? 4
    //                       : widget.type == "RP"
    //                           ? 10
    //                           : "",
    //               DEVICEID: activatedDevice,
    //               QTY: int.parse(qtyController.text),
    //               UOM: widget.transDetails['UOM'],
    //               BARCODE: widget.transDetails['BARCODE'],
    //               CREATEDDATE: DateTime.now().toString(),
    //               INVENTSTATUS: widget.transDetails['INVENTSTATUS'],
    //               SIZEID: widget.transDetails['SIZEID'],
    //               COLORID: widget.transDetails['COLORID'],
    //               CONFIGID: widget.transDetails['CONFIGID'],
    //               STYLESID: widget.transDetails['STYLESID'],
    //               STORECODE: activatedStore,
    //               LOCATION: transactionData[0]['VRLOCATION'].toString(),
    //               BATCHNO: batchNoController.text.trim(),
    //               EXPDATE: selectedEXPDate.toString(),
    //               // selectedExpDateFormatted.toString(),
    //               PRODDATE: selectedMGFDate.toString(),
    //               // selectedmgfDateFormatted.toString(),
    //               BatchEnabled: isBatchEnabled,
    //               BatchedItem: BatchedItem);
    //         } else {
    //
    //           await _sqlHelper.updateTRANSDETAILSWithQty(dt[0]['id'],
    //               int.parse(dt[0]['QTY']) + int.parse(qtyController.text));
    //           productionDateController.clear();
    //           expDateController.clear();
    //           batchNoController.clear();
    //           selectedMGFDate = null;
    //           selectedEXPDate = null;
    //
    //           // await   controller?.resumeCamera();
    //
    //           setState(() {});
    //         }
    //       } else {
    //         //     {id: 530, AXDOCNO: PO00038510, STORECODE: AJM0028, BARCODE: 3330001509217,
    //         // TRANSTYPE: 10, ITEMID: 33300015, ITEMNAME: NIVEA DEO SPY FRESH NATURAL,
    //         // UOM: PCS, QTY: 500.0, DEVICEID: Device2, CONFIGID: ,
    //         // SIZEID: , COLORID: , STYLESID: , INVENTSTATUS: Available}
    //         // I/flutter (22764): [{RecId: 34, DOCNO: RP-Device2-0003, AXDOCNO: PO00038510,
    //         // STORECODE: AJM0028, TOSTORECODE: , TRANSTYPE: 10, STATUS: 1, USERNAME: Admin,
    //         // DESCRIPTION: post rp, CREATEDDATE: 2023-01-19 15:27:03.363675, DATAAREAID: 1000,
    //         // DEVICEID: Device2, TYPEDESCR: RP, VRLOCATION: }]
    //         await _sqlHelper.addTRANSDETAILS(
    //             HRecId: transactionData[0]['RecId'],
    //             STATUS: 1,
    //             AXDOCNO: transactionData[0]['AXDOCNO'],
    //             DOCNO: transactionData[0]['DOCNO'],
    //             ITEMID: itemIdController.text,
    //             ITEMNAME: descriptionController.text,
    //             TRANSTYPE: transType == "STOCK COUNT"
    //                 ? 1
    //                 : widget.type == "GRN"
    //                     ? 4
    //                     : widget.type == "RP"
    //                         ? 10
    //                         : "",
    //             DEVICEID: activatedDevice,
    //             QTY: int.parse(qtyController.text),
    //             UOM: disabledUOMSelection == "true"
    //                 ? selectOUM
    //                 : uomController.text,
    //             BARCODE: barcodeController.text,
    //             CREATEDDATE: DateTime.now().toString(),
    //             // print(widget.transDetails);
    //             // print(transactionData);
    //             INVENTSTATUS: widget.transDetails['INVENTSTATUS'],
    //             SIZEID: widget.transDetails['SIZEID'],
    //             COLORID: widget.transDetails['COLORID'],
    //             CONFIGID: widget.transDetails['CONFIGID'],
    //             STYLESID: widget.transDetails['STYLESID'],
    //             STORECODE: activatedStore,
    //             LOCATION: transactionData[0]['VRLOCATION'].toString(),
    //             BATCHNO: batchNoController.text.trim(),
    //             EXPDATE: selectedEXPDate.toString(),
    //             // selectedExpDateFormatted.toString(),
    //             PRODDATE: selectedMGFDate.toString(),
    //             // selectedmgfDateFormatted.toString(),
    //             BatchEnabled: isBatchEnabled,
    //             BatchedItem: BatchedItem);
    //       }
    //
    //       itemIdController.clear();
    //       barcodeController.clear();
    //       descriptionController.clear();
    //       uomController.clear();
    //       sizeController.clear();
    //       colorController.clear();
    //       styleController.clear();
    //       configController.clear();
    //       qtyController.clear();
    //       remainedQuantityController.clear();
    //       productionDateController.clear();
    //       expDateController.clear();
    //       batchNoController.clear();
    //       selectedMGFDate = null;
    //       selectedEXPDate = null;
    //
    //       // await   controller?.resumeCamera();
    //
    //       setState(() {
    //         isFocus = false;
    //       });
    //
    //       FocusScope.of(context).unfocus();
    //     }
    //     setState(() {});
    //     Navigator.pop(context);
    //   },
    // );
    //
    // Widget noButton = TextButton(
    //   style: APPConstants().btnBackgroundNo,
    //   child: Text(
    //     "No",
    //     style: APPConstants().noText,
    //   ),
    //   onPressed: () {
    //     print("Scanning code");
    //     setState(() {});
    //     Navigator.pop(context);
    //   },
    // );
    //
    // // set up the AlertDialog
    // AlertDialog alert = AlertDialog(
    //   title: Text("DynamicsConnect"),
    //   content: Text(
    //     "$text",
    //   ),
    //   actions: [noButton, yesButton],
    // );


    // ----commented lines -----// old qunaity exceed
    //
    //
    //







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
    print("995...");

    print( isBatchEnabled);
    print(BatchedItem!);


    print("998...");
    return Scaffold(
        // appBar: null,
        body:
            // MediaQuery.of(context).orientation == Orientation.landscape
            //     ?

            ListView(
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 10),
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: Text(
                      "${transType}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          decorationColor: Colors.red,
                          decorationThickness: 2.5,
                          // decoration: TextDecoration.underline,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown),
                    ),
                  )),
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: transactionData == null || transactionData.length == 0
                  ? Container()
                  : Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border:
                              Border.all(color: Colors.red[100]!, width: 3)),
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "DOCUMENT NO :${transactionData[0]['DOCNO'] ?? ""}",
                        textAlign:
                        transactionData[0]['DOCNO'].toString().length > 25 ?
                        TextAlign.left :
                        TextAlign.center,
                        overflow: TextOverflow.visible,

                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey),
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
                margin:  EdgeInsets.symmetric(horizontal: 10),
                height: 35,
                child: TextFormField(
                  onTap: () async {


                    itemIdController.clear();
                    barcodeController.clear();
                    descriptionController.clear();
                    uomController.clear();
                    sizeController.clear();
                    colorController.clear();
                    styleController.clear();
                    configController.clear();
                    qtyController.clear();
                    remainedQuantityController.clear();
                    expDateController.clear();
                    batchNoController.clear();
                    productionDateController.clear();

                    selectOUM=null;

                    selectedEXPDate = null;
                    selectedMGFDate = null;
                    setState((){

                    });

                    await  controller?.resumeCamera();

                    setState(() {});

                    print("Has focus: ${_focusNodeQty.hasFocus} 2325");
                    print(
                        "Has focus situation : ${_focusNodeBarcode.hasFocus}");
                    print("has boolean : ${isFocus.toString()}");
                    if (_focusNodeBarcode.hasFocus) {
                      setState(() {
                        isFocus = false;
                      });
                    }
                    print(_focusNodeBarcode.hasFocus && !isFocus!);
                    if (_focusNodeBarcode.hasFocus && !isFocus!) {
                      itemIdController.clear();
                      barcodeController.clear();
                      descriptionController.clear();
                      uomController.clear();
                      sizeController.clear();
                      colorController.clear();
                      styleController.clear();
                      configController.clear();
                      qtyController.clear();
                      remainedQuantityController.clear();
                      expDateController.clear();
                      batchNoController.clear();
                      productionDateController.clear();

                      selectedEXPDate = null;
                      selectedMGFDate = null;

                      // await  controller?.resumeCamera();

                      setState(() {});
                    }
                  },
                  textInputAction: TextInputAction.go,
                  onFieldSubmitted: (value) {
                    // if(widget.type =="GRN"){

                    getBarcodeWithscan();

                    // }
                  },
                  focusNode: _focusNodeBarcode,
                  validator: (value) => value!.isEmpty ? 'Required *' : null,
                  controller: barcodeController,
                  decoration: InputDecoration(
                      focusedBorder: APPConstants().focusInputBorder,
                      enabledBorder: APPConstants().enableInputBorder,
                      suffixIcon: IconButton(
                        onPressed: () async {
                          print("SERCH BTN...896");
                          print(widget.type);
                          print(transactionData);
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
                                                      : widget.type == 'TO-OUT'
                                                          ? "5"
                                                          : widget.type ==
                                                                  'TO-IN'
                                                              ? "6"
                                                              : "");
                          print(transactionData);
                          // return;
                          if (transactionData[0]['STATUS'] > 1) {
                            showDialogGotData(
                                "Cannot add item,Document Status is'Closed'");
                            return;
                          }
                          // return;

                          if (widget.type == "ST") {
                            if (disabledContinuosScan == "true") {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SearchImportedDetailsPage(
                                            axDocNo: transactionData[0]
                                                ['AXDOCNO'],
                                            isContinousScan:
                                                disabledContinuosScan == "true"
                                                    ? true
                                                    : false,
                                            searchKey: barcodeController.text,
                                            transactionType: transType,
                                          )));
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SearchImportedDetailsPage(
                                            axDocNo: transactionData[0]
                                                ['AXDOCNO'],
                                            isContinousScan:
                                                disabledContinuosScan == "true"
                                                    ? true
                                                    : false,
                                            searchKey: barcodeController.text,
                                            transactionType: transType,
                                          )));
                              // showD
                              //   Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchtransactionDetailsPage(
                              //     searchKey: barcodeController.text,
                              //     transactionType: transType,
                              //   )));
                            }
                          }

                          if (widget.type == "PO" ||
                              widget.type == "RO" ||
                              widget.type == "TO") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewItemsOldPage(
                                          isHomeView: false,
                                          searchKey: barcodeController.text,
                                          transactionType: transType,
                                        ))).whenComplete(() {
                              // getTransactionDetails();
                              // getToken();
                              // itemIdController.clear();
                              // barcodeController.clear();
                              // descriptionController.clear();
                              // uomController.clear();
                              // sizeController.clear();
                              // colorController.clear();
                              // styleController.clear();
                              // configController.clear();
                              // qtyController.clear();
                              // remainedQuantityController.clear();
                              // setState((){
                              // });
                            });
                          }

                          if (widget.type == "GRN" ||
                              widget.type == "RP" ||
                              widget.type == "TO-OUT" ||
                              widget.type == "TO-IN") {
                            print("goto page...");
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SearchImportedDetailsPage(
                                          axDocNo: transactionData[0]
                                              ['AXDOCNO'],
                                          searchKey: barcodeController.text,
                                          transactionType: transType,
                                        )));
                          }

                         await controller?.resumeCamera();
                        },
                        icon: Icon(
                          Icons.manage_search,
                          size: 20,
                        ),
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.only(
                          left: 15, right: 15, top: 2, bottom: 2),
                      hintText: "BarCode",
                      hintStyle: TextStyle(color: Colors.black26),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7.0),
                        // borderSide: Border()
                      )),
                ),
              ),
            ),
          ],
        ),
        Visibility(
            visible: disableCamera == null || disableCamera == "false",
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

                  onLongPress: ()async{
                    // await controller?.pauseCamera();
                  },


                 onDoubleTap:() async {

                   // if(disabledContinuosScan != null
                   //     && disabledContinuosScan ==false){

                     // await controller?.pauseCamera();

                   // }
                   // else{
                   //
                   // await controller?.resumeCamera();
                   // await controller?.toggleFlash();
                   // }

                 },

                  onTap: () async {


                      await controller?.resumeCamera();
                      // await controller?.toggleFlash();
                      await controller?.pauseCamera();

                      // await controller?.toggleFlash();



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
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                // height: 35,
                child: TextFormField(
                  readOnly: true,
                  validator: (value) => value!.isEmpty ? 'Required *' : null,
                  controller: itemIdController,
                  decoration: InputDecoration(
                      focusedBorder: APPConstants().focusInputBorder,
                      enabledBorder: APPConstants().enableInputBorder,
                      isDense: true,
                      contentPadding: EdgeInsets.only(
                          left: 15, right: 15, top: 5, bottom: 5),
                      hintText: "Item ID",
                      hintStyle: TextStyle(color: Colors.black26),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7.0),
                        // borderSide: Border()
                      )),
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
              child: TextFormField(
                readOnly: true,
                validator: (value) => value!.isEmpty ? 'Required *' : null,
                minLines: 1,
                maxLines: 6,
                controller: descriptionController,
                decoration: InputDecoration(
                    focusedBorder: APPConstants().focusInputBorder,
                    enabledBorder: APPConstants().enableInputBorder,
                    // suffixIcon: IconButton(
                    //   onPressed: (){
                    //
                    //   }, icon: Icon(Icons.search_outlined),
                    // ),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                    hintText: "Description",
                    hintStyle: TextStyle(color: Colors.black26),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7.0),
                      // borderSide: Border()
                    )),
              ),
            )),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Visibility(
              visible: disabledUOMSelection != "true",
              child: Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  // height: 35,
                  child: TextFormField(
                    readOnly: true,
                    validator: (value) => value!.isEmpty ? 'Required *' : null,
                    controller: uomController,
                    decoration: InputDecoration(
                        focusedBorder: APPConstants().focusInputBorder,
                        enabledBorder: APPConstants().enableInputBorder,
                        // suffixIcon: IconButton(
                        //   onPressed: (){
                        //
                        //   }, icon: Icon(Icons.search_outlined),
                        // ),
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            left: 15, right: 15, top: 5, bottom: 5),
                        hintText: "UOM",
                        hintStyle: TextStyle(color: Colors.black26),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          // borderSide: Border()
                        )),
                  ),
                ),
              ),
            ),
            Visibility(
                visible: disabledUOMSelection == "true",
                child: Expanded(
                  child: Container(
                    height: 30,
                    // color:  Colors.black12,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: new Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.white,
                        // backgroundColor: Colors.black26,
                        // cardColor: Colors.black12
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2(
                          dropdownMaxHeight: 250,
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
                          buttonHeight: 300,

                          hint: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'UOM Select ...',
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

                          items: uomList
                              .map((item) => DropdownMenuItem<String>(
                                    value: item['UNITNAME']?.toString(),
                                    child: Text(
                                      item['UNITNAME'] ?? "",
                                      style: TextStyle(
                                        // fontSize: 14,
                                        // fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          value: selectOUM,
                          onChanged: (value) {
                            setState(() {
                              selectOUM = value as String;
                            });
                          },
                          icon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 13.0),
                            child: Icon(
                              Icons.arrow_forward_ios_outlined,
                            ),
                          ),
                          iconSize: 12,

                          buttonDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: Colors.black38, width: 0.8),
                            // color: isActivated != null && isActivated!
                            //     ? Colors.black12:
                            // Colors.white,
                          ),

                          buttonElevation: 0,

                          dropdownDecoration: BoxDecoration(
                            border: Border.all(
                              // style: BorderStyle.none,
                              width: 0.8,
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
                  // Expanded(
                  //     child: Container(
                  //       height: 35,
                  //
                  //       margin: EdgeInsets.symmetric(horizontal: 10),
                  //       child: Center(
                  //         child: Row(
                  //           children: [
                  //             SizedBox(
                  //               width: 10,
                  //             ),
                  //             Text(
                  //               selectOUM ?? "Select UOM",
                  //               style: TextStyle(
                  //                  color: Colors.black26
                  //                       ,
                  //                   fontSize: 15),
                  //             ),
                  //             Spacer(),
                  //             Icon(
                  //               Icons.arrow_forward_ios_rounded,
                  //               size: 14,
                  //             ),
                  //             SizedBox(
                  //               width: 10,
                  //             )
                  //           ],
                  //         ),
                  //       ),
                  //       decoration: BoxDecoration(
                  //           color:
                  //           // isActivated != null && isActivated!
                  //           //     ? Colors.black12:
                  //           Colors.white,
                  //           border:
                  //           Border.all(color: Colors.black, width: 0.7),
                  //           borderRadius: BorderRadius.circular(10.0)),
                  //     )),
                ))
          ],
        ),
        Visibility(
          visible: showDimension ?? false,
          child: SizedBox(
            height: 10,
          ),
        ),
        Visibility(
          visible: showDimension ?? false,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  // height: 35,
                  child: TextFormField(
                    readOnly: true,
                    validator: (value) => value!.isEmpty ? 'Required *' : null,
                    controller: styleController,
                    decoration: InputDecoration(
                        focusedBorder: APPConstants().focusInputBorder,
                        enabledBorder: APPConstants().enableInputBorder,
                        // suffixIcon: IconButton(
                        //   onPressed: (){
                        //
                        //   }, icon: Icon(Icons.search_outlined),
                        // ),
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            left: 15, right: 15, top: 5, bottom: 5),
                        hintText: "STYLE",
                        hintStyle: TextStyle(color: Colors.black26),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          // borderSide: Border()
                        )),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  // height: 35,
                  child: TextFormField(
                    readOnly: true,
                    validator: (value) => value!.isEmpty ? 'Required *' : null,
                    controller: configController,
                    decoration: InputDecoration(
                        focusedBorder: APPConstants().focusInputBorder,
                        enabledBorder: APPConstants().enableInputBorder,
                        // suffixIcon: IconButton(
                        //   onPressed: (){
                        //
                        //   }, icon: Icon(Icons.search_outlined),
                        // ),
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            left: 15, right: 15, top: 5, bottom: 5),
                        hintText: "CONFIG",
                        hintStyle: TextStyle(color: Colors.black26),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          // borderSide: Border()
                        )),
                  ),
                ),
              )
            ],
          ),
        ),
        Visibility(
          visible: showDimension ?? false,
          child: SizedBox(
            height: 10,
          ),
        ),
        Visibility(
          visible: showDimension ?? false,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  // height: 35,
                  child: TextFormField(
                    readOnly: true,
                    validator: (value) => value!.isEmpty ? 'Required *' : null,
                    controller: sizeController,
                    decoration: InputDecoration(
                        focusedBorder: APPConstants().focusInputBorder,
                        enabledBorder: APPConstants().enableInputBorder,
                        // suffixIcon: IconButton(
                        //   onPressed: (){
                        //
                        //   }, icon: Icon(Icons.search_outlined),
                        // ),
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            left: 15, right: 15, top: 5, bottom: 5),
                        hintText: "SIZE",
                        hintStyle: TextStyle(color: Colors.black26),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          // borderSide: Border()
                        )),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  // height: 35,
                  child: TextFormField(
                    readOnly: true,
                    validator: (value) => value!.isEmpty ? 'Required *' : null,
                    controller: colorController,
                    decoration: InputDecoration(
                        focusedBorder: APPConstants().focusInputBorder,
                        enabledBorder: APPConstants().enableInputBorder,
                        // suffixIcon: IconButton(
                        //   onPressed: (){
                        //
                        //   }, icon: Icon(Icons.search_outlined),
                        // ),
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            left: 15, right: 15, top: 5, bottom: 5),
                        hintText: "COLOUR",
                        hintStyle: TextStyle(color: Colors.black26),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          // borderSide: Border()
                        )),
                  ),
                ),
              )
            ],
          ),
        ),

        Visibility(
            visible: (isBatchEnabled! && !BatchedItem!) &&
                (widget.type == "GRN" || widget.type == "ST"),
            child: SizedBox(
              height: 10,
            )),
        Visibility(
          visible: (isBatchEnabled! && !BatchedItem!) &&
              (widget.type == "GRN" || widget.type == "ST"),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    _selectMgfDate(context);
                  },
                  child: Container(
                      height: 30,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      // padding: EdgeInsets.symmetric(vertical: 5),
                      // width: MediaQuery.of(context).size.width / 2.7,
                      // height: MediaQuery.of(context).size.height  /25,
                      // margin: EdgeInsets.only(top: 30),
                      // alignment: Alignment.center,

                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 0.5
                              // enabledBorder: APPConstants().enableInputBorder,
                              ),
                          // color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                              flex: 1,
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        _selectMgfDate(context);
                                      },
                                      icon: Icon(
                                        color: Colors.black,
                                        Icons.edit_calendar_outlined,
                                      ))
                                ],
                              )),
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 2, child: Text("Manufaturer Date :")),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        print(
                                            "Date Value : ${value.toString()}");
                                        return value.isEmpty
                                            ? 'Required *'
                                            : null;
                                      }
                                    },
                                    style: TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                    enabled: false,
                                    keyboardType: TextInputType.text,
                                    controller: productionDateController,
                                    onSaved: (String? val) {
                                      productionDateController.text = val!;
                                    },
                                    decoration: InputDecoration(
                                        // errorText: ,
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none),
                                        // disabledBorder:
                                        // UnderlineInputBorder(borderSide: BorderSide.none),
                                        contentPadding:
                                            EdgeInsets.only(top: 0.0)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                ),
              ),
            ],
          ),
        ),

        // DateInputTextField(),
        Visibility(
            visible: (isBatchEnabled! && !BatchedItem!) &&
                (widget.type == "GRN" || widget.type == "ST"),
            child: SizedBox(
              height: 10,
            )),
        Visibility(
          visible: (isBatchEnabled! && !BatchedItem!) &&
              (widget.type == "GRN" || widget.type == "ST"),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    _selectExpDate(context);
                  },
                  child: Container(
                      height: 30,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      // padding: EdgeInsets.symmetric(vertical: 5),
                      // width: MediaQuery.of(context).size.width / 2.7,
                      // height: MediaQuery.of(context).size.height  /25,
                      // margin: EdgeInsets.only(top: 30),
                      // alignment: Alignment.center,

                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 0.5
                              // enabledBorder: APPConstants().enableInputBorder,
                              ),
                          // color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                              flex: 1,
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        _selectExpDate(context);
                                      },
                                      icon: Icon(
                                        color: Colors.black,
                                        Icons.edit_calendar_outlined,
                                      ))
                                ],
                              )),
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: Text("Expiry Date :")),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        print(
                                            "Date Value : ${value.toString()}");
                                        return value.isEmpty
                                            ? 'Required *'
                                            : null;
                                      }
                                    },
                                    style: TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                    enabled: false,
                                    keyboardType: TextInputType.text,
                                    controller: expDateController,
                                    onSaved: (String? val) {
                                      expDateController.text = val!;
                                    },
                                    decoration: InputDecoration(
                                        // errorText: ,
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none),
                                        // disabledBorder:
                                        // UnderlineInputBorder(borderSide: BorderSide.none),
                                        contentPadding:
                                            EdgeInsets.only(top: 0.0)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                ),
              ),
            ],
          ),
        ),

        // Expanded(
        //   flex: 4,
        //   child: Row(
        //     children: [
        //       Expanded(flex: 2, child: Text("To Date :")),
        //       Expanded(
        //         flex: 2,
        //         child: TextFormField(
        //           validator: (value) {
        //             if (value!.isEmpty) {
        //               print(
        //                   "Date Value : ${value.toString()}");
        //               return value.isEmpty
        //                   ? 'Required *'
        //                   : null;
        //             }
        //           },
        //           style: TextStyle(fontSize: 16),
        //           textAlign: TextAlign.center,
        //           enabled: false,
        //           keyboardType: TextInputType.text,
        //           controller: toDateController,
        //           onSaved: (String? val) {
        //             _setToDate = val;
        //           },
        //           decoration: InputDecoration(
        //             // errorText: ,
        //               border: OutlineInputBorder(
        //                   borderSide: BorderSide.none),
        //               // disabledBorder:
        //               // UnderlineInputBorder(borderSide: BorderSide.none),
        //               contentPadding:
        //               EdgeInsets.only(top: 0.0)),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        Visibility(
            visible: (isBatchEnabled! && !BatchedItem!) &&
                (widget.type == "GRN" || widget.type == "ST"),
            child: SizedBox(
              height: 10,
            )),
        //    Text("${isBatchEnabled.toString()}...."),
        // Text("${BatchedItem.toString()}...."),
        Visibility(
          visible: (isBatchEnabled! && !BatchedItem!) &&
              (widget.type == "GRN" || widget.type == "ST"),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  // height: 35,
                  child: TextFormField(
                    // readOnly: true,
                    validator: (value) => value!.isEmpty ? 'Required *' : null,
                    controller: batchNoController,
                    decoration: InputDecoration(
                        focusedBorder: APPConstants().focusInputBorder,
                        enabledBorder: APPConstants().enableInputBorder,
                        // suffixIcon: IconButton(
                        //   onPressed: (){
                        //
                        //   }, icon: Icon(Icons.search_outlined),
                        // ),
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            left: 15, right: 15, top: 5, bottom: 5),
                        hintText: "BATCH NO",
                        hintStyle: TextStyle(color: Colors.black26),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          // borderSide: Border()
                        )),
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),

// Visibility(
//     visible: (enabledCheck[0]['BatchEnabled'].toString()=="1") &&
//         (widget.type == "GRN" || widget.type == "ST"),
//   child:   Row(
//
//     children: [Text("Enabled : ${enabledCheck[0]['BatchEnabled'].)}")],
//
//   ),
// ),
        SizedBox(
          height: 50,
        ),

        Visibility(
          visible: remainedQty != null
          // && double.parse(remainedQty!) > 0.0

          ,
          child: Row(
            children: [
              Expanded(flex: 2, child: Container()),
              Expanded(
                child: Visibility(
                  visible: remainedQty != null
                  // && double.parse(remainedQty!) > 0.0
                  ,
                  child: Text(
                    "Rem QTY",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Expanded(flex: 1, child: Container()),
            ],
          ),
        ),

        Visibility(
          visible: widget.type == "TO-IN" ||
              widget.type == "TO-OUT" ||
              widget.type == "GRN" && remainedQuantityController.text != ""
          // &&
          // double.parse(remainedQuantityController.text) > 0.0
          ,
          child: Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Expanded(flex: 1, child: Text("Remined -Qty")),
              Expanded(
                flex: 2,
                child: TextFormField(
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Required *' : null,
                  controller: remainedQuantityController,
                  decoration: InputDecoration(
                      // suffixIcon: IconButton(
                      //   onPressed: (){
                      //
                      //   }, icon: Icon(Icons.search_outlined),
                      // ),

                      isDense: true,
                      contentPadding: EdgeInsets.only(
                          left: 15, right: 15, top: 5, bottom: 5),
                      // hintText: remainedQty.toString()??"",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7.0),
                        // borderSide: Border()
                      )),
                ),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
        Visibility(
            visible: widget.type == "TO-IN" ||
                widget.type == "TO-OUT" ||
                widget.type == "GRN" && remainedQuantityController.text != ""
            // &&
            // double.parse(remainedQuantityController.text) > 0.0
            ,
            child: SizedBox(
              height: 10,
            )),
        Row(
          children: [
            Expanded(
                child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      textInputAction: TextInputAction.go,
                      onFieldSubmitted: (String? qtyControllers) async {
                        print("input submit 1613");
                        var selectedmgfDateFormatted =
                            DateFormat("yyyy-MM-ddTHH:mm:ss")
                                .format(selectedMGFDate!);
                        var selectedExpDateFormatted =
                            DateFormat("yyyy-MM-ddTHH:mm:ss")
                                .format(selectedEXPDate!);
                        if (transactionData[0]['STATUS'] > 1) {
                          showDialogGotData(
                              "Cannot add item,Document Status is'Closed'");
                          return;
                        }

                        if (barcodeController.text == "") {
                          showDialogGotData("Scan Barcode");
                          return;
                        }
                        if (qtyController.text.trim() == "0" ||
                            qtyController.text.trim() == "") {
                          showDialogGotData("Enter your Quantity");
                          return;
                        }
                        if (disabledUOMSelection == "true" &&
                            selectOUM == null) {
                          showDialogGotData("Select UOM Unit");
                          return;
                        }
                        setState(() {
                          isFocus = false;
                        });

                        if (widget.type == "ST" ||
                            widget.type == "GRN" ||
                            widget.type == "RP" ||
                            widget.type == "TO-OUT" ||
                            widget.type == "TO-IN") {
                          if (importedSearch != null &&
                              importedSearch!) {
                            print("Data from imported Search");
                            print(widget.transDetails);
                            print(transType);
                            // return;
                            var dt = await _sqlHelper
                                .getFindItemExistOrnotTRANSDETAILS(
                                    DOCNO: transactionData[0]['DOCNO'],
                                    ITEMID: widget.transDetails['ITEMID'],
                                    ITEMNAME: widget.transDetails['ITEMNAME'],
                                    BARCODE: widget.transDetails['BARCODE'],
                                    TRANSTYPE: transType == "STOCK COUNT"
                                        ? 1
                                        : widget.type == "GRN"
                                            ? 4
                                            : widget.type == "RP"
                                                ? 10
                                                : widget.type == "TO-OUT"
                                                    ? 5
                                                    : widget.type == "TO-IN"
                                                        ? 6
                                                        : "",
                                    UOM: widget.transDetails['UOM']);

                            dt.forEach(print);
                            print("Line 2432");
                            print(dt.length);

                            if (dt.length > 0) {

                              if (
                                  // double.parse(remainedQuantityController.text) != 0.0
                                  //     &&
                                  double.parse(qtyController.text) >
                                              double.parse(
                                                  remainedQuantityController
                                                      .text) &&
                                          widget.type == "GRN" ||
                                      widget.type == "RP" ||
                                      widget.type == "TO-OUT" ||
                                      widget.type == "TO-IN") {
                                setState(() {
                                  isFocus = false;
                                });
                                showDialogCheckQuantity(
                                  "QTY Exceeded the limit. DO you want to proceed ?",
                                );
                              } else {
                                if (isBatchEnabled! &&
                                        !BatchedItem! &&
                                        dt[0]['BATCHNO'] !=
                                            batchNoController.text.trim() &&
                                        widget.type == "GRN" ||
                                    widget.type == "ST") {

                                  var enabledCheck = await _sqlHelper.getImportedDetailsBySearchScanBarcode(
                                      barcodeController.text, transactionData[0]['AXDOCNO'].toString());

                                    print("Line 3450");

                                    // return;

                                  await _sqlHelper.addTRANSDETAILS(
                                      HRecId: transactionData[0]['RecId'],
                                      STATUS: 1,
                                      AXDOCNO: transactionData[0]['AXDOCNO'],
                                      DOCNO: transactionData[0]['DOCNO'],
                                      ITEMID: itemIdController.text,
                                      ITEMNAME: descriptionController.text,
                                      TRANSTYPE: transType == "STOCK COUNT"
                                          ? 1
                                          : widget.type == "GRN"
                                              ? 4
                                              : widget.type == "RP"
                                                  ? 10
                                                  : "",
                                      DEVICEID: activatedDevice,
                                      QTY: int.parse(qtyController.text),
                                      UOM:disabledUOMSelection == "true"
                                          ?  selectOUM
                                          : uomController.text ,
                                      BARCODE: barcodeController.text ,
                                      CREATEDDATE: DateTime.now().toString(),
                                      INVENTSTATUS:
                                          widget.transDetails['INVENTSTATUS'],
                                      SIZEID: sizeController.text ,
                                      COLORID: colorController.text ,
                                      CONFIGID:configController.text ,
                                      STYLESID: styleController.text ,
                                      STORECODE: activatedStore,
                                      LOCATION: transactionData[0]['VRLOCATION']
                                          .toString(),
                                      BATCHNO: batchNoController.text.trim(),
                                      EXPDATE: selectedEXPDate.toString(),
                                      // selectedExpDateFormatted.toString(),
                                      PRODDATE: selectedMGFDate.toString(),
                                      // selectedmgfDateFormatted.toString(),
                                      BatchEnabled: isBatchEnabled,
                                      BatchedItem: BatchedItem
                                  );
                                } else {
                                  await _sqlHelper.updateTRANSDETAILSWithQty(
                                      dt[0]['id'],
                                      int.parse(dt[0]['QTY']) +
                                          int.parse(qtyController.text));
                                }

                                itemIdController.clear();
                                barcodeController.clear();
                                descriptionController.clear();
                                uomController.clear();
                                sizeController.clear();
                                colorController.clear();
                                styleController.clear();
                                configController.clear();
                                qtyController.clear();
                                remainedQuantityController.clear();

                                setState(() {
                                  isFocus = false;
                                });
                                FocusScope.of(context).unfocus();
                              }
                            } else {
                              if (
                                  // double.parse(remainedQuantityController.text) != 0.0
                                  //     &&
                                  double.parse(qtyController.text) >
                                              double.parse(
                                                  remainedQuantityController
                                                      .text) &&
                                          widget.type == "GRN" ||
                                      widget.type == "RP" ||
                                      widget.type == "TO-OUT" ||
                                      widget.type == "TO-IN"
                                  //     widget.type != "TO-OUT" &&
                                  // widget.type != "TO-IN"
                                  ) {
                                setState(() {
                                  isFocus = false;
                                });
                                showDialogCheckQuantity(
                                    "QTY Exceeded the limit. DO you want to proceed ?");
                              } else {

                                print("Line 3531");

                                // return;

                                await _sqlHelper.addTRANSDETAILS(
                                    HRecId: transactionData[0]['RecId'],
                                    STATUS: 1,
                                    AXDOCNO: transactionData[0]['AXDOCNO'],
                                    DOCNO: transactionData[0]['DOCNO'],
                                    ITEMID: itemIdController.text,
                                    ITEMNAME: descriptionController.text,
                                    TRANSTYPE: transType == "STOCK COUNT"
                                        ? 1
                                        : widget.type == "GRN"
                                            ? 4
                                            : widget.type == "RP"
                                                ? 10
                                                : widget.type == "TO-OUT"
                                                    ? 5
                                                    : widget.type == "TO-IN"
                                                        ? 6
                                                        : "",
                                    DEVICEID: activatedDevice,
                                    QTY: int.parse(qtyController.text),
                                    UOM: disabledUOMSelection == "true"
                                        ?  selectOUM
                                        : uomController.text  ,
                                    BARCODE: barcodeController.text.trim() ,
                                    CREATEDDATE: DateTime.now().toString(),
                                    INVENTSTATUS:
                                        widget.transDetails['INVENTSTATUS'],
                                    SIZEID: sizeController.text ,
                                    COLORID: colorController.text ,
                                    CONFIGID: configController.text ,
                                    STYLESID: styleController.text ,
                                    STORECODE: activatedStore,
                                    LOCATION: transactionData[0]['VRLOCATION']
                                        .toString(),
                                    BATCHNO: batchNoController.text.trim(),
                                    EXPDATE: selectedEXPDate.toString(),
                                    // selectedExpDateFormatted.toString(),
                                    PRODDATE: selectedMGFDate.toString(),
                                    // selectedmgfDateFormatted.toString(),
                                    BatchEnabled: isBatchEnabled,
                                    BatchedItem: BatchedItem);

                                itemIdController.clear();
                                barcodeController.clear();
                                descriptionController.clear();
                                uomController.clear();
                                sizeController.clear();
                                colorController.clear();
                                styleController.clear();
                                configController.clear();
                                qtyController.clear();
                                remainedQuantityController.clear();

                                setState(() {
                                  isFocus = false;
                                });
                                FocusScope.of(context).unfocus();
                              }
                            }

                            setState(() {
                              importedSearch = false;
                            });

                            // Navigator.push(context, MaterialPageRoute(
                            //     builder: (context)=>TransactionViewPage(
                            //       currentIndex: 1,
                            //       pageType: widget.transactionType,
                            //     )));
                          } else {
                            print("Data from imported Search NOt");

                            // print("Data from imported Search");
                            print(widget.transDetails);
                            print(transType);
                            // return;

                            var dt = await _sqlHelper
                                .getFindItemExistOrnotTRANSDETAILS(
                                    DOCNO: transactionData[0]['DOCNO'],
                                    ITEMID: itemIdController.text,
                                    ITEMNAME: descriptionController.text,
                                    BARCODE: barcodeController.text,
                                    TRANSTYPE: transType == "STOCK COUNT"
                                        ? 1
                                        : widget.type == "GRN"
                                            ? 4
                                            : widget.type == "RP"
                                                ? 10
                                                : widget.type == "TO-OUT"
                                                    ? 5
                                                    : widget.type == "TO-IN"
                                                        ? 6
                                                        : "",
                                    UOM: disabledUOMSelection == "true"
                                        ? selectOUM
                                        : uomController.text);

                            print("Line 2592");
                            dt.forEach(print);
                            print(dt.length);
                            print((double.parse(qtyController.text) ) >
                                double.parse(remainedQuantityController.text));
                            if (dt.length > 0) {
                              if (
                                  // double.parse(remainedQuantityController.text) != 0.0
                                  //     &&
                                  double.parse(qtyController.text)>
                                              double.parse(
                                                  remainedQuantityController
                                                      .text) &&
                                          widget.type == "GRN" ||
                                      widget.type == "RP" ||
                                      widget.type == "TO-OUT" ||
                                      widget.type == "TO-IN"
                                  //     widget.type != "TO-OUT" &&
                                  // widget.type != "TO-IN"
                                  ) {
                                setState(() {
                                  isFocus = false;
                                });

                                showDialogCheckQuantity(
                                    "QTY Exceeded the limit. DO you want to proceed ?");
                              } else {
                                if (isBatchEnabled! &&
                                        !BatchedItem! &&
                                        dt[0]['BATCHNO'] !=
                                            batchNoController.text.trim() &&
                                        widget.type == "GRN" ||
                                    widget.type == "ST") {


                                  print("Line 3663");

                                  // return;

                                  await _sqlHelper.addTRANSDETAILS(
                                      HRecId: transactionData[0]['RecId'],
                                      STATUS: 1,
                                      AXDOCNO: transactionData[0]['AXDOCNO'],
                                      DOCNO: transactionData[0]['DOCNO'],
                                      ITEMID: itemIdController.text,
                                      ITEMNAME: descriptionController.text,
                                      TRANSTYPE: transType == "STOCK COUNT"
                                          ? 1
                                          : widget.type == "GRN"
                                              ? 4
                                              : widget.type == "RP"
                                                  ? 10
                                                  : "",
                                      DEVICEID: activatedDevice,
                                      QTY: int.parse(qtyController.text),
                                      UOM: disabledUOMSelection == "true"
                                          ?  selectOUM
                                          : uomController.text ,
                                      BARCODE: barcodeController.text ,
                                      CREATEDDATE: DateTime.now().toString(),
                                      INVENTSTATUS:
                                          widget.transDetails['INVENTSTATUS'],
                                      SIZEID: sizeController.text ,
                                      COLORID:colorController.text ,
                                      CONFIGID: configController.text ,
                                      STYLESID:styleController.text ,
                                      STORECODE: activatedStore,
                                      LOCATION: transactionData[0]['VRLOCATION']
                                          .toString(),
                                      BATCHNO: batchNoController.text.trim(),
                                      EXPDATE: selectedEXPDate.toString(),
                                      // selectedExpDateFormatted.toString(),
                                      PRODDATE: selectedMGFDate.toString(),
                                      // selectedmgfDateFormatted.toString(),
                                      BatchEnabled: isBatchEnabled,
                                      BatchedItem: BatchedItem);
                                } else {
                                  await _sqlHelper.updateTRANSDETAILSWithQty(
                                      dt[0]['id'],
                                      int.parse(dt[0]['QTY']) +
                                          int.parse(qtyController.text));
                                }
                                itemIdController.clear();
                                barcodeController.clear();
                                descriptionController.clear();
                                uomController.clear();
                                sizeController.clear();
                                colorController.clear();
                                styleController.clear();
                                configController.clear();
                                qtyController.clear();
                                remainedQuantityController.clear();

                                setState(() {
                                  isFocus = false;
                                });
                                FocusScope.of(context).unfocus();
                              }
                            } else {
                              if (
                                  // double.parse(remainedQuantityController.text) != 0.0
                                  //     &&
                                  double.parse(qtyController.text) >
                                              double.parse(
                                                  remainedQuantityController
                                                      .text) &&
                                          widget.type == "GRN" ||
                                      widget.type == "RP" ||
                                      widget.type == "TO-OUT" ||
                                      widget.type == "TO-IN"
                                  //     widget.type != "TO-OUT" &&
                                  // widget.type != "TO-IN"
                                  ) {
                                setState(() {
                                  isFocus = false;
                                });
                                showDialogCheckQuantity(
                                    "QTY Exceeded the limit. DO you want to proceed ?");
                              } else {
                                print("Line 3742");

                                // return;

                                await _sqlHelper.addTRANSDETAILS(
                                    HRecId: transactionData[0]['RecId'],
                                    STATUS: 1,
                                    AXDOCNO: transactionData[0]['AXDOCNO'],
                                    DOCNO: transactionData[0]['DOCNO'],
                                    ITEMID: itemIdController.text,
                                    ITEMNAME: descriptionController.text,
                                    TRANSTYPE: transType == "STOCK COUNT"
                                        ? 1
                                        : widget.type == "GRN"
                                            ? 4
                                            : widget.type == "RP"
                                                ? 10
                                                : widget.type == "TO-OUT"
                                                    ? 5
                                                    : widget.type == "TO-IN"
                                                        ? 6
                                                        : "",
                                    DEVICEID: activatedDevice,
                                    QTY: int.parse(qtyController.text),
                                    UOM: disabledUOMSelection == "true"
                                        ? selectOUM
                                        : uomController.text,
                                    BARCODE: barcodeController.text,
                                    CREATEDDATE: DateTime.now().toString(),
                                    INVENTSTATUS: barcodeScanData[0]
                                        ['INVENTSTATUS'],
                                    SIZEID: sizeController.text ,
                                    COLORID:colorController.text ,
                                    CONFIGID: configController.text ,
                                    STYLESID:styleController.text ,
                                    STORECODE: activatedStore,
                                    LOCATION: transactionData[0]['VRLOCATION']
                                        .toString(),
                                    BATCHNO: batchNoController.text.trim(),
                                    EXPDATE: selectedEXPDate.toString(),
                                    // selectedExpDateFormatted.toString(),
                                    PRODDATE: selectedMGFDate.toString(),
                                    // selectedmgfDateFormatted.toString(),
                                    BatchEnabled: isBatchEnabled,
                                    BatchedItem: BatchedItem);
                                itemIdController.clear();
                                barcodeController.clear();
                                descriptionController.clear();
                                uomController.clear();
                                sizeController.clear();
                                colorController.clear();
                                styleController.clear();
                                configController.clear();
                                qtyController.clear();
                                remainedQuantityController.clear();

                                setState(() {
                                  isFocus = false;
                                });
                                FocusScope.of(context).unfocus();
                              }
                            }
                          }
                          FocusScope.of(context)
                              .requestFocus(_focusNodeBarcode);
                        }

                        if (widget.type == "PO" ||
                            widget.type == "RO" ||
                            widget.type == "TO") {
                          if (importedSearch != null && importedSearch!) {
                            print("Data from imported Search");
                            print(widget.transDetails);
                            var b = {
                              "HRecId": transactionData[0]['RecId'],
                              "STATUS": 1,
                              "AXDOCNO": transactionData[0]['AXDOCNO'],
                              "DOCNO": transactionData[0]['DOCNO'],
                              "ITEMID": widget.transDetails['ITEMID'],
                              "ITEMNAME": widget.transDetails['ITEMNAME'],
                              "TRANSTYPE": transType == "STOCK COUNT"
                                  ? 1
                                  : transType == "PURCHASE ORDER"
                                      ? 3
                                      : "",
                              "DEVICEID": activatedDevice,
                              'QTY': int.parse(qtyController.text),
                              'UOM': widget.transDetails['UOM'],
                              'BARCODE': widget.transDetails['BARCODE'],
                              'CREATEDDATE': DateTime.now().toString(),
                              'INVENTSTATUS':
                                  widget.transDetails['INVENTSTATUS'],
                              'SIZEID': widget.transDetails['SIZEID'],
                              'COLORID': widget.transDetails['COLORID'],
                              'CONFIGID': widget.transDetails['CONFIGID'],
                              'STYLESID': widget.transDetails['STYLESID'],
                              'STORECODE': activatedStore,
                              'LOCATION':
                                  transactionData[0]['VRLOCATION'].toString()
                            };
                            print(b);
                            // return;
                            var dt = await _sqlHelper
                                .getFindItemExistOrnotTRANSDETAILS(
                                    DOCNO: transactionData[0]['DOCNO'],
                                    ITEMID: widget.transDetails['ItemId'],
                                    ITEMNAME: widget.transDetails['ItemName'],
                                    BARCODE: widget.transDetails['ITEMBARCODE'],
                                    TRANSTYPE: transType == "STOCK COUNT"
                                        ? 1
                                        : transType == "PURCHASE ORDER"
                                            ? 3
                                            : transType == "RETURN ORDER"
                                                ? 9
                                                : transType == "TRANSFER ORDER"
                                                    ? 11
                                                    : "",
                                    UOM: widget.transDetails['UNIT']);

                            print("Line 2762");
                            dt.forEach(print);
                            print(dt.length);

                            if (dt.length > 0) {
                              if (isBatchEnabled! &&
                                      !BatchedItem! &&
                                      dt[0]['BATCHNO'] !=
                                          batchNoController.text.trim() &&
                                      widget.type == "GRN" ||
                                  widget.type == "ST") {

                                print("Line 3870");

                                // return;

                                await _sqlHelper.addTRANSDETAILS(
                                    HRecId: transactionData[0]['RecId'],
                                    STATUS: 1,
                                    AXDOCNO: transactionData[0]['AXDOCNO'],
                                    DOCNO: transactionData[0]['DOCNO'],
                                    ITEMID: itemIdController.text,
                                    ITEMNAME: descriptionController.text,
                                    TRANSTYPE: transType == "STOCK COUNT"
                                        ? 1
                                        : widget.type == "GRN"
                                            ? 4
                                            : widget.type == "RP"
                                                ? 10
                                                : "",
                                    DEVICEID: activatedDevice,
                                    QTY: int.parse(qtyController.text),
                                    UOM: disabledUOMSelection == "true"
                                        ?  selectOUM
                                        : uomController.text ,
                                    BARCODE: barcodeController.text ,
                                    CREATEDDATE: DateTime.now().toString(),
                                    INVENTSTATUS:
                                        widget.transDetails['INVENTSTATUS'],
                                    SIZEID: sizeController.text ,
                                    COLORID: colorController.text ,
                                    CONFIGID: configController.text,
                                    STYLESID: styleController.text ,
                                    STORECODE: activatedStore,
                                    LOCATION: transactionData[0]['VRLOCATION']
                                        .toString(),
                                    BATCHNO: batchNoController.text.trim(),
                                    EXPDATE: selectedEXPDate.toString(),
                                    // selectedExpDateFormatted.toString(),
                                    PRODDATE: selectedMGFDate.toString(),
                                    // selectedmgfDateFormatted.toString(),
                                    BatchEnabled: isBatchEnabled,
                                    BatchedItem: BatchedItem);
                              } else {
                                await _sqlHelper.updateTRANSDETAILSWithQty(
                                    dt[0]['id'],
                                    int.parse(dt[0]['QTY']) +
                                        int.parse(qtyController.text));
                              }
                            } else {

                              print("Line 3870");

                              // return;

                              await _sqlHelper.addTRANSDETAILS(
                                  HRecId: transactionData[0]['RecId'],
                                  STATUS: 1,
                                  AXDOCNO: transactionData[0]['AXDOCNO'],
                                  DOCNO: transactionData[0]['DOCNO'],
                                  ITEMID: itemIdController.text,
                                  ITEMNAME: descriptionController.text,
                                  TRANSTYPE: transType == "STOCK COUNT"
                                      ? 1
                                      : transType == "PURCHASE ORDER"
                                          ? 3
                                          : transType == "RETURN ORDER"
                                              ? 9
                                              : transType == "TRANSFER ORDER"
                                                  ? 11
                                                  : "",
                                  DEVICEID: activatedDevice,
                                  QTY: int.parse(qtyController.text),
                                  UOM: disabledUOMSelection == "true"
                                      ?  selectOUM
                                      : uomController.text ,
                                  BARCODE: barcodeController.text.trim() ,
                                  CREATEDDATE: DateTime.now().toString(),
                                  INVENTSTATUS:
                                      widget.transDetails['INVENTSTATUS'],
                                  SIZEID: sizeController.text ,
                                  COLORID: colorController.text ,
                                  CONFIGID: configController.text ,
                                  STYLESID: styleController.text ,
                                  STORECODE: activatedStore,
                                  LOCATION: transactionData[0]['VRLOCATION']
                                      .toString(),
                                  BATCHNO: batchNoController.text.trim(),
                                  EXPDATE: selectedEXPDate.toString(),
                                  // selectedExpDateFormatted.toString(),
                                  PRODDATE: selectedMGFDate.toString(),
                                  // selectedmgfDateFormatted.toString(),
                                  BatchEnabled: isBatchEnabled,
                                  BatchedItem: BatchedItem);
                            }

                            itemIdController.clear();
                            barcodeController.clear();
                            descriptionController.clear();
                            uomController.clear();
                            sizeController.clear();
                            colorController.clear();
                            styleController.clear();
                            configController.clear();
                            qtyController.clear();
                            remainedQuantityController.clear();

                            setState(() {
                              isFocus = false;
                              importedSearch = false;
                            });
                            // Navigator.push(context, MaterialPageRoute(
                            //     builder: (context)=>TransactionViewPage(
                            //       currentIndex: 1,
                            //       pageType: widget.transactionType,
                            //     )));
                          } else {
                            print("Data from imported Search NOt");

                            print(widget.transDetails);
                            print(transType);
                            var b = {
                              "HRecId": transactionData[0]['RecId'],
                              "STATUS": 1,
                              "AXDOCNO": transactionData[0]['AXDOCNO'],
                              "DOCNO": transactionData[0]['DOCNO'],
                              "ITEMID": itemIdController.text,
                              "ITEMNAME": descriptionController.text,
                              "TRANSTYPE": transType == "STOCK COUNT"
                                  ? 1
                                  : transType == "PURCHASE ORDER"
                                      ? 3
                                      : "",
                              "DEVICEID": activatedDevice,
                              'QTY': int.parse(qtyController.text),
                              'UOM': disabledUOMSelection == "true"
                                  ?  selectOUM
                                  : uomController.text  ,
                              'BARCODE': barcodeController.text,
                              'CREATEDDATE': DateTime.now().toString(),
                              "INVENTSTATUS": barcodeScanData[0]
                                  ['INVENTSTATUS'],
                              "SIZEID": barcodeScanData[0]['SIZEID'],
                              "COLORID": barcodeScanData[0]['COLORID'],
                              "CONFIGID": barcodeScanData[0]['CONFIGID'],
                              "STYLESID": barcodeScanData[0]['STYLEID'],
                              "STORECODE": activatedStore,
                              "LOCATION":
                                  transactionData[0]['VRLOCATION'].toString()
                            };
                            print(b);

                            var dt = await _sqlHelper
                                .getFindItemExistOrnotTRANSDETAILS(
                                    DOCNO: transactionData[0]['DOCNO'],
                                    ITEMID: itemIdController.text,
                                    ITEMNAME: descriptionController.text,
                                    BARCODE: barcodeController.text,
                                    TRANSTYPE: transType == "STOCK COUNT"
                                        ? 1
                                        : transType == "PURCHASE ORDER"
                                            ? 3
                                            : transType == "RETURN ORDER"
                                                ? 9
                                                : transType == "TRANSFER ORDER"
                                                    ? 11
                                                    : "",
                                    UOM: disabledUOMSelection == "true"
                                        ? selectOUM
                                        : uomController.text);

                            print("Line 2873");
                            dt.forEach(print);
                            print(dt.length);
                            // return;
                            if (dt.length > 0) {
                              if (isBatchEnabled! &&
                                      !BatchedItem! &&
                                      dt[0]['BATCHNO'] !=
                                          batchNoController.text.trim() &&
                                      widget.type == "GRN" ||
                                  widget.type == "ST") {

                                print("Line 4060");

                                // return;

                                await _sqlHelper.addTRANSDETAILS(
                                    HRecId: transactionData[0]['RecId'],
                                    STATUS: 1,
                                    AXDOCNO: transactionData[0]['AXDOCNO'],
                                    DOCNO: transactionData[0]['DOCNO'],
                                    ITEMID: itemIdController.text,
                                    ITEMNAME: descriptionController.text,
                                    TRANSTYPE: transType == "STOCK COUNT"
                                        ? 1
                                        : widget.type == "GRN"
                                            ? 4
                                            : widget.type == "RP"
                                                ? 10
                                                : "",
                                    DEVICEID: activatedDevice,
                                    QTY: int.parse(qtyController.text),
                                    UOM: disabledUOMSelection == "true"
                                        ?  selectOUM
                                        : uomController.text ,
                                    BARCODE: barcodeController.text.trim() ,
                                    CREATEDDATE: DateTime.now().toString(),
                                    INVENTSTATUS:
                                        widget.transDetails['INVENTSTATUS'],
                                    SIZEID: sizeController.text ,
                                    COLORID: colorController.text ,
                                    CONFIGID: configController.text ,
                                    STYLESID: styleController.text ,
                                    STORECODE: activatedStore,
                                    LOCATION: transactionData[0]['VRLOCATION']
                                        .toString(),
                                    BATCHNO: batchNoController.text.trim(),
                                    EXPDATE: selectedEXPDate.toString(),
                                    // selectedExpDateFormatted.toString(),
                                    PRODDATE: selectedMGFDate.toString(),
                                    // selectedmgfDateFormatted.toString(),
                                    BatchEnabled: isBatchEnabled,
                                    BatchedItem: BatchedItem);
                              } else {
                                await _sqlHelper.updateTRANSDETAILSWithQty(
                                    dt[0]['id'],
                                    int.parse(dt[0]['QTY']) +
                                        int.parse(qtyController.text));
                              }
                            } else {
                              print("Line 4105");

                              // return;

                              await _sqlHelper.addTRANSDETAILS(
                                  HRecId: transactionData[0]['RecId'],
                                  STATUS: 1,
                                  AXDOCNO: transactionData[0]['AXDOCNO'],
                                  DOCNO: transactionData[0]['DOCNO'],
                                  ITEMID: itemIdController.text,
                                  ITEMNAME: descriptionController.text,
                                  TRANSTYPE: transType == "STOCK COUNT"
                                      ? 1
                                      : transType == "PURCHASE ORDER"
                                          ? 3
                                          : transType == "RETURN ORDER"
                                              ? 9
                                              : transType == "TRANSFER ORDER"
                                                  ? 11
                                                  : "",
                                  DEVICEID: activatedDevice,
                                  QTY: int.parse(qtyController.text),
                                  UOM: disabledUOMSelection == "true"
                                      ? selectOUM
                                      : disabledUOMSelection == "true"
                                          ? selectOUM
                                          : uomController.text,
                                  BARCODE: barcodeController.text,
                                  CREATEDDATE: DateTime.now().toString(),
                                  INVENTSTATUS: barcodeScanData[0]
                                      ['INVENTSTATUS'],
                                  SIZEID: sizeController.text ,
                                  COLORID:colorController.text ,
                                  CONFIGID: configController.text ,
                                  STYLESID:styleController.text ,
                                  STORECODE: activatedStore,
                                  LOCATION: transactionData[0]['VRLOCATION']
                                      .toString(),
                                  BATCHNO: batchNoController.text.trim(),
                                  EXPDATE: selectedEXPDate.toString(),
                                  // selectedExpDateFormatted.toString(),
                                  PRODDATE: selectedMGFDate.toString(),
                                  // selectedmgfDateFormatted.toString(),
                                  BatchEnabled: isBatchEnabled,
                                  BatchedItem: BatchedItem);
                            }

                            itemIdController.clear();
                            barcodeController.clear();
                            descriptionController.clear();
                            uomController.clear();
                            sizeController.clear();
                            colorController.clear();
                            styleController.clear();
                            configController.clear();
                            qtyController.clear();
                            remainedQuantityController.clear();
                            setState(() {
                              isFocus = false;
                            });
                          }
                          FocusScope.of(context).unfocus();
                        }

                        setState(() {
                          isFocus = true;
                        });
                      },
                      focusNode: _focusNodeQty,
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Required *' : null,
                      controller: qtyController,
                      decoration: InputDecoration(
                          focusedBorder: APPConstants().focusInputBorder,
                          enabledBorder: APPConstants().enableInputBorder,
                          // suffixIcon: IconButton(
                          //   onPressed: (){
                          //
                          //   }, icon: Icon(Icons.search_outlined),
                          // ),

                          isDense: true,
                          contentPadding: EdgeInsets.only(
                              left: 15, right: 15, top: 5, bottom: 5),
                          hintText: "QTY",
                          hintStyle: TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            // borderSide: Border()
                          )),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: SizedBox(
                    height: 30,
                    child: TextButton(
                        style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            backgroundColor: Colors.green[300]),
                        onPressed: () async {
                          print("barcodeController.text");

                          print(transactionData);
                          // print(widget.transDetails);
                          // return;
                          // List<dynamic> linesItems=[];
                          // linesItems.addAll(await  _sqlHelper.addMoreToCheckDatasLines(
                          //     AXDOCNO:"INVJ013616",
                          //     limit: 12000
                          // ));
                          //
                          //
                          // for(var i=1;i<=10000;i++){
                          //
                          //   print("Line ${i.toString()}");
                          //   var enabledCheck=[];
                          //   enabledCheck = await _sqlHelper.
                          //   getITEMMASTERBySearchScanBarcode(
                          //       linesItems[i]['BARCODE']??"");
                          //
                          //   print(enabledCheck[0]['BatchEnabled'].toString()=="1");
                          //   print(enabledCheck[0]['BatchedItem'].toString()=="0");
                          //
                          //
                          //   if(enabledCheck[0]['BatchEnabled'].toString()=="1"
                          //   && enabledCheck[0]['BatchedItem'].toString()=="0"){
                          //
                          //   }
                          //   else{
                          //
                          //
                          //
                          //
                          //     await _sqlHelper.addTRANSDETAILS(
                          //         HRecId :  transactionData[0]['RecId']  ,
                          //         STATUS: 1,
                          //         AXDOCNO: transactionData[0]['AXDOCNO'],
                          //         DOCNO :  transactionData[0]['DOCNO'] ,
                          //         ITEMID :linesItems[i]['ITEMID'] ,
                          //         ITEMNAME : linesItems[i]['ITEMNAME'],
                          //         TRANSTYPE :1,
                          //         DEVICEID :activatedDevice ,
                          //         QTY : 1,
                          //         UOM  : linesItems[i]['UOM'],
                          //         BARCODE :linesItems[i]['BARCODE'],
                          //         CREATEDDATE : DateTime.now().toString() ,
                          //         INVENTSTATUS : linesItems[i]['INVENTSTATUS'],
                          //         SIZEID : linesItems[i]['SIZEID'],
                          //         COLORID :  linesItems[i]['COLORID'],
                          //         CONFIGID :  linesItems[i]['CONFIGID'],
                          //         STYLESID :  linesItems[i]['STYLESID'],
                          //         STORECODE :  activatedStore,
                          //         LOCATION :  transactionData[0]['VRLOCATION'].toString(),
                          //         BATCHNO:enabledCheck[0]['BATCHNO'],
                          //         EXPDATE: selectedEXPDate.toString()??"",
                          //         // selectedExpDateFormatted.toString(),
                          //         PRODDATE: selectedMGFDate.toString()??"",
                          //         // selectedmgfDateFormatted.toString(),
                          //         BatchEnabled: enabledCheck[0]['BatchEnabled'],
                          //         BatchedItem:enabledCheck[0]['BatchedItem'],
                          //     );
                          //
                          //   }
                          //
                          //
                          // }
                          //
                          //
                          //
                          //
                          //
                          //
                          // return;

                          if (isBatchEnabled! && !BatchedItem!) {
                            if (selectedMGFDate == null) {
                              showDialogGotData("Manufacturer Date Required");
                              return;
                            }
                            if (selectedEXPDate == null) {
                              showDialogGotData("Expiry Date Required");
                              return;
                            }
                            if (batchNoController.text.trim() == "") {
                              showDialogGotData("Batch Number Required");
                              return;
                            }
                          }

                          var selectedmgfDateFormatted = selectedMGFDate == null
                              ? ""
                              : DateFormat("yyyy-MM-ddTHH:mm:ss")
                                  .format(selectedMGFDate!);

                          var selectedExpDateFormatted = selectedEXPDate == null
                              ? ""
                              : DateFormat("yyyy-MM-ddTHH:mm:ss")
                                  .format(selectedEXPDate!);

                          if (transactionData[0]['STATUS'] > 1) {
                            showDialogGotData(
                                "Cannot add item,Document Status is'Closed'");
                            return;
                          }

                          if (barcodeController.text == "") {
                            showDialogGotData("Scan Barcode");
                            return;
                          }
                          if (qtyController.text.trim() == "0" ||
                              qtyController.text.trim() == "") {
                            showDialogGotData("Enter your Quantity");
                            return;
                          }
                          if (disabledUOMSelection == "true" &&
                              selectOUM == null) {
                            showDialogGotData("Select UOM Unit");
                            return;
                          }
                          setState(() {
                            isFocus = false;
                          });

                          if (widget.type == "ST" ||
                              widget.type == "GRN" ||
                              widget.type == "RP" ||
                              widget.type == "TO-OUT" ||
                              widget.type == "TO-IN") {
                            if (importedSearch != null && importedSearch!) {
                              print("Data from imported Search");
                              print(widget.transDetails);
                              print(transType);
                              // return;
                              var dt = await _sqlHelper
                                  .getFindItemExistOrnotTRANSDETAILS(
                                      DOCNO: transactionData[0]['DOCNO'],
                                      ITEMID: widget.transDetails['ITEMID'],
                                      ITEMNAME: widget.transDetails['ITEMNAME'],
                                      BARCODE: widget.transDetails['BARCODE'],
                                      TRANSTYPE: transType == "STOCK COUNT"
                                          ? 1
                                          : widget.type == "GRN"
                                              ? 4
                                              : widget.type == "RP"
                                                  ? 10
                                                  : widget.type == "TO-OUT"
                                                      ? 5
                                                      : widget.type == "TO-IN"
                                                          ? 6
                                                          : "",
                                      UOM: widget.transDetails['UOM']);

                              print("Line 3114");
                              dt.forEach(print);
                              print(dt.length);

                              if (dt.length > 0) {
                                if (
                                    // double.parse(remainedQuantityController.text) != 0.0
                                    //     &&
                                    double.parse(qtyController.text)  >
                                                double.parse(
                                                    remainedQuantityController
                                                        .text) &&
                                            widget.type == "GRN" ||
                                        widget.type == "RP" ||
                                        widget.type == "TO-OUT" ||
                                        widget.type == "TO-IN"

                                    //         widget.type != "TO-OUT" &&
                                    // widget.type != "TO-IN"
                                    ) {
                                  setState(() {
                                    isFocus = false;
                                  });

                                  showDialogCheckQuantity(
                                      "QTY Exceeded the limit. DO you want to proceed ?");
                                } else {
                                  if (isBatchEnabled! &&
                                          !BatchedItem! &&
                                          dt[0]['BATCHNO'] !=
                                              batchNoController.text.trim() &&
                                          widget.type == "GRN" ||
                                      widget.type == "ST") {

                                    print("Line 4395");

                                // return;

                                    await _sqlHelper.addTRANSDETAILS(
                                        HRecId: transactionData[0]['RecId'],
                                        STATUS: 1,
                                        AXDOCNO: transactionData[0]['AXDOCNO'],
                                        DOCNO: transactionData[0]['DOCNO'],
                                        ITEMID: itemIdController.text,
                                        ITEMNAME: descriptionController.text,
                                        TRANSTYPE: transType == "STOCK COUNT"
                                            ? 1
                                            : widget.type == "GRN"
                                                ? 4
                                                : widget.type == "RP"
                                                    ? 10
                                                    : "",
                                        DEVICEID: activatedDevice,
                                        QTY: int.parse(qtyController.text),
                                        UOM:disabledUOMSelection == "true"
                                            ?  selectOUM
                                            : uomController.text  ,
                                        BARCODE: barcodeController.text.trim() ,
                                        CREATEDDATE: DateTime.now().toString(),
                                        INVENTSTATUS:
                                            widget.transDetails['INVENTSTATUS'],
                                        SIZEID:sizeController.text ,
                                        COLORID: colorController.text ,
                                        CONFIGID:
                                            configController.text ,
                                        STYLESID:
                                            styleController.text ,
                                        STORECODE: activatedStore,
                                        LOCATION: transactionData[0]
                                                ['VRLOCATION']
                                            .toString(),
                                        BATCHNO: batchNoController.text.trim(),
                                        EXPDATE: selectedEXPDate.toString(),
                                        // selectedExpDateFormatted.toString(),
                                        PRODDATE: selectedMGFDate.toString(),
                                        // selectedmgfDateFormatted.toString(),
                                        BatchEnabled: isBatchEnabled,
                                        BatchedItem: BatchedItem);
                                  } else {
                                    await _sqlHelper.updateTRANSDETAILSWithQty(
                                        dt[0]['id'],
                                        int.parse(dt[0]['QTY']) +
                                            int.parse(qtyController.text));
                                  }
                                  itemIdController.clear();
                                  barcodeController.clear();
                                  descriptionController.clear();
                                  uomController.clear();
                                  sizeController.clear();
                                  colorController.clear();
                                  styleController.clear();
                                  configController.clear();
                                  qtyController.clear();
                                  remainedQuantityController.clear();
                                  expDateController.clear();
                                  productionDateController.clear();
                                  batchNoController.clear();
                                  selectedEXPDate = null;
                                  selectedMGFDate = null;
                                  setState(() {
                                    isFocus = false;
                                  });
                                  FocusScope.of(context).unfocus();
                                }
                              } else {
                                if (
                                    // double.parse(remainedQuantityController.text) != 0.0
                                    //     &&
                                    double.parse(qtyController.text) >
                                                double.parse(
                                                    remainedQuantityController
                                                        .text) &&
                                            widget.type == "GRN" ||
                                        widget.type == "RP" ||
                                        widget.type == "TO-OUT" ||
                                        widget.type == "TO-IN"
                                    //     widget.type != "TO-OUT" &&
                                    // widget.type != "TO-IN"
                                    ) {
                                  setState(() {
                                    isFocus = false;
                                  });
                                  showDialogCheckQuantity(
                                      "QTY Exceeded the limit. DO you want to proceed ?");
                                } else

                                  {
                                    print("Line 4485 : ${isBatchEnabled}..${BatchedItem} ");



                                    // return;

                                    await _sqlHelper.addTRANSDETAILS(
                                      HRecId: transactionData[0]['RecId'],
                                      STATUS: 1,
                                      AXDOCNO: transactionData[0]['AXDOCNO'],
                                      DOCNO: transactionData[0]['DOCNO'],
                                        ITEMID: itemIdController.text,
                                        ITEMNAME: descriptionController.text,
                                      TRANSTYPE: transType == "STOCK COUNT"
                                          ? 1
                                          : widget.type == "GRN"
                                              ? 4
                                              : widget.type == "RP"
                                                  ? 10
                                                  : widget.type == "TO-OUT"
                                                      ? 5
                                                      : widget.type == "TO-IN"
                                                          ? 6
                                                          : "",
                                      DEVICEID: activatedDevice,
                                      QTY: int.parse(qtyController.text),
                                      UOM: disabledUOMSelection == "true"
                                          ?  selectOUM
                                          : uomController.text  ,
                                      BARCODE: barcodeController.text.trim(),
                                      CREATEDDATE: DateTime.now().toString(),
                                      INVENTSTATUS:
                                          widget.transDetails['INVENTSTATUS'],
                                        SIZEID:sizeController.text ,
                                        COLORID: colorController.text ,
                                        CONFIGID:
                                        configController.text ,
                                        STYLESID:
                                        styleController.text ,
                                      STORECODE: activatedStore,
                                      LOCATION: transactionData[0]['VRLOCATION']
                                          .toString(),
                                      BATCHNO: batchNoController.text.trim(),
                                      EXPDATE: selectedEXPDate.toString(),
                                      // selectedExpDateFormatted.toString(),
                                      PRODDATE: selectedMGFDate.toString(),
                                      // selectedmgfDateFormatted.toString(),
                                      BatchEnabled: isBatchEnabled,
                                      BatchedItem: BatchedItem);

                                  itemIdController.clear();
                                  barcodeController.clear();
                                  descriptionController.clear();
                                  uomController.clear();
                                  sizeController.clear();
                                  colorController.clear();
                                  styleController.clear();
                                  configController.clear();
                                  qtyController.clear();
                                  remainedQuantityController.clear();
                                  expDateController.clear();
                                  productionDateController.clear();
                                  batchNoController.clear();
                                  selectedEXPDate = null;
                                  selectedMGFDate = null;

                                  // controller?.resumeCamera();

                                  setState(() {
                                    isFocus = false;
                                  });
                                  FocusScope.of(context).unfocus();
                                }
                              }

                              setState(() {
                                importedSearch = false;
                              });

                              // Navigator.push(context, MaterialPageRoute(
                              //     builder: (context)=>TransactionViewPage(
                              //       currentIndex: 1,
                              //       pageType: widget.transactionType,
                              //     )));
                            } else {
                              print("Data from imported Search NOt");

                              // print("Data from imported Search");
                              // print(barcodeScanData[0]);
                              print(widget.transDetails);
                              print(transType);
                              // return;

                              var dt = await _sqlHelper
                                  .getFindItemExistOrnotTRANSDETAILS(
                                      DOCNO: transactionData[0]['DOCNO'],
                                      ITEMID: itemIdController.text,
                                      ITEMNAME: descriptionController.text,
                                      BARCODE: barcodeController.text,
                                      TRANSTYPE: transType == "STOCK COUNT"
                                          ? 1
                                          : widget.type == "GRN"
                                              ? 4
                                              : widget.type == "RP"
                                                  ? 10
                                                  : widget.type == "TO-OUT"
                                                      ? 5
                                                      : widget.type == "TO-IN"
                                                          ? 6
                                                          : "",
                                      UOM: disabledUOMSelection == "true"
                                          ? selectOUM
                                          : uomController.text);

                              print("Line 3287");
                              dt.forEach(print);
                              print(dt.length);

                              if (dt.length > 0) {
                                if (
                                    // double.parse(remainedQuantityController.text) != 0.0
                                    //     &&
                                    double.parse(qtyController.text) >
                                                double.parse(
                                                    remainedQuantityController
                                                        .text) &&
                                            widget.type == "GRN" ||
                                        widget.type == "RP" ||
                                        widget.type == "TO-OUT" ||
                                        widget.type == "TO-IN"
                                    //         widget.type != "TO-OUT" &&
                                    // widget.type != "TO-IN"
                                    ) {

                                  setState(() {
                                    isFocus = false;
                                  });
                                  showDialogCheckQuantity(
                                      "QTY Exceeded the limit. DO you want to proceed ?");
                                } else {
                                  if (isBatchEnabled! &&
                                          !BatchedItem! &&
                                          dt[0]['BATCHNO'] !=
                                              batchNoController.text.trim() &&
                                          widget.type == "GRN" ||
                                      widget.type == "ST") {
                                    if (importedSearch != null &&
                                        importedSearch!) {
                                      print("Line 4627");

                                      print(
                                          "not from imported search line 3915");

                                      // return;

                                      await _sqlHelper.addTRANSDETAILS(
                                          HRecId: transactionData[0]['RecId'],
                                          STATUS: 1,
                                          AXDOCNO: transactionData[0]
                                              ['AXDOCNO'],
                                          DOCNO: transactionData[0]['DOCNO'],
                                          ITEMID:

                                                  itemIdController.text ,
                                          ITEMNAME:

                                                  descriptionController.text ,
                                          TRANSTYPE: transType == "STOCK COUNT"
                                              ? 1
                                              : widget.type == "GRN"
                                                  ? 4
                                                  : widget.type == "RP"
                                                      ? 10
                                                      : "",
                                          DEVICEID: activatedDevice,
                                          QTY: int.parse(qtyController.text),
                                          UOM: disabledUOMSelection == "true"
                                              ?  selectOUM
                                              : uomController.text  ,
                                          BARCODE:
                                              barcodeController.text.trim() ,
                                          CREATEDDATE:
                                              DateTime.now().toString(),
                                          INVENTSTATUS: widget
                                              .transDetails['INVENTSTATUS'],
                                          SIZEID:sizeController.text ,
                                          COLORID: colorController.text ,
                                          CONFIGID:
                                          configController.text ,
                                          STYLESID:
                                          styleController.text ,
                                          STORECODE: activatedStore,
                                          LOCATION: transactionData[0]
                                                  ['VRLOCATION']
                                              .toString(),
                                          BATCHNO:
                                              batchNoController.text.trim(),
                                          EXPDATE: selectedEXPDate.toString(),
                                          // selectedExpDateFormatted.toString(),
                                          PRODDATE: selectedMGFDate.toString(),
                                          // selectedmgfDateFormatted.toString(),
                                          BatchEnabled: isBatchEnabled,
                                          BatchedItem: BatchedItem);
                                    } else {
                                      print("imported search line 3918");

                                      print("Line 3904");
                                      print(widget.isImportedSearch);
                                      print(importedSearch);
                                      print(widget.transDetails);
                                      print(transactionData[0]);
                                      print(itemIdController.text);

                                      print("Line 4690");



                                      // return;


                                      await _sqlHelper.addTRANSDETAILS(
                                          HRecId: transactionData[0]['RecId'],
                                          STATUS: 1,
                                          AXDOCNO: transactionData[0]
                                              ['AXDOCNO'],
                                          DOCNO: transactionData[0]['DOCNO'],
                                          ITEMID:
                                              itemIdController.text,
                                          ITEMNAME:
                                              descriptionController.text,
                                          TRANSTYPE: transType == "STOCK COUNT"
                                              ? 1
                                              : widget.type == "GRN"
                                                  ? 4
                                                  : widget.type == "RP"
                                                      ? 10
                                                      : "",
                                          DEVICEID: activatedDevice,
                                          QTY: int.parse(qtyController.text),
                                          UOM:  disabledUOMSelection == "true"
                                              ?  selectOUM
                                              : uomController.text ,
                                          BARCODE: barcodeController.text,
                                          CREATEDDATE:
                                              DateTime.now().toString(),
                                          INVENTSTATUS: barcodeScanData[0]
                                              ['INVENTSTATUS'],
                                          SIZEID: sizeController.text ,
                                          COLORID:colorController.text ,
                                          CONFIGID: configController.text ,
                                          STYLESID:styleController.text ,
                                          STORECODE: activatedStore,
                                          LOCATION: transactionData[0]
                                                  ['VRLOCATION']
                                              .toString(),
                                          BATCHNO:
                                              batchNoController.text.trim(),
                                          EXPDATE: selectedEXPDate.toString(),
                                          // selectedExpDateFormatted.toString(),
                                          PRODDATE: selectedMGFDate.toString(),
                                          // selectedmgfDateFormatted.toString(),
                                          BatchEnabled: isBatchEnabled,
                                          BatchedItem: BatchedItem);
                                    }
                                  } else {
                                    await _sqlHelper.updateTRANSDETAILSWithQty(
                                        dt[0]['id'],
                                        int.parse(dt[0]['QTY']) +
                                            int.parse(qtyController.text));
                                  }
                                  itemIdController.clear();
                                  barcodeController.clear();
                                  descriptionController.clear();
                                  uomController.clear();
                                  sizeController.clear();
                                  colorController.clear();
                                  styleController.clear();
                                  configController.clear();
                                  qtyController.clear();
                                  remainedQuantityController.clear();
                                  expDateController.clear();
                                  productionDateController.clear();
                                  batchNoController.clear();
                                  selectedEXPDate = null;
                                  selectedMGFDate = null;

                                  // controller?.resumeCamera();
                                  setState(() {
                                    isFocus = false;
                                  });
                                  FocusScope.of(context).unfocus();
                                }
                              } else {
                                if (
                                    // double.parse(remainedQuantityController.text) != 0.0
                                    //     &&
                                    double.parse(qtyController.text) >

                                                double.parse(
                                                    remainedQuantityController
                                                        .text) &&
                                            widget.type == "GRN" ||
                                        widget.type == "RP" ||
                                        widget.type == "TO-OUT" ||
                                        widget.type == "TO-IN"
                                    //         widget.type != "TO-OUT" &&
                                    // widget.type != "TO-IN"
                                    ) {
                                  setState(() {
                                    isFocus = false;
                                  });
                                  showDialogCheckQuantity(
                                      "QTY Exceeded the limit. DO you want to proceed ?");
                                } else {
                                  print("line 3975");


                                  print(transactionData[0]);
                                  print(importedSearch);
                                  print(widget.isImportedSearch);
                                  print(widget.transDetails);

                                  if (widget.isImportedSearch != null &&
                                      widget.isImportedSearch!) {

                                    print("Line 4803");

                                    // return;

                                    await _sqlHelper.addTRANSDETAILS(
                                        HRecId: transactionData[0]['RecId'],
                                        STATUS: 1,
                                        AXDOCNO: transactionData[0]
                                        ['AXDOCNO'],
                                        DOCNO: transactionData[0]['DOCNO'],
                                        ITEMID:

                                            itemIdController.text ,
                                        ITEMNAME:

                                            descriptionController.text ,
                                        TRANSTYPE: transType == "STOCK COUNT"
                                            ? 1
                                            : widget.type == "GRN"
                                            ? 4
                                            : widget.type == "RP"
                                            ? 10
                                            : "",
                                        DEVICEID: activatedDevice,
                                        QTY: int.parse(qtyController.text),
                                        UOM: disabledUOMSelection == "true"
                                            ?  selectOUM
                                            : uomController.text  ,
                                        BARCODE:
                                        barcodeController.text.trim(),
                                        CREATEDDATE:
                                        DateTime.now().toString(),
                                        INVENTSTATUS: widget
                                            .transDetails['INVENTSTATUS'],
                                        SIZEID:sizeController.text,
                                        COLORID:
                                        colorController.text ,
                                        CONFIGID:
                                       configController.text,
                                        STYLESID:
                                        styleController.text,
                                        STORECODE: activatedStore,
                                        LOCATION: transactionData[0]
                                        ['VRLOCATION']
                                            .toString(),
                                        BATCHNO:
                                        batchNoController.text.trim(),
                                        EXPDATE: selectedEXPDate.toString(),
                                        // selectedExpDateFormatted.toString(),
                                        PRODDATE: selectedMGFDate.toString(),
                                        // selectedmgfDateFormatted.toString(),
                                        BatchEnabled: isBatchEnabled,
                                        BatchedItem: BatchedItem);



                                  }
                                  else
                                  {
                                    print("Line 4859");

                                    // return;

                                    await _sqlHelper.addTRANSDETAILS(
                                        HRecId: transactionData[0]['RecId'],
                                        STATUS: 1,
                                        AXDOCNO: transactionData[0]['AXDOCNO'],
                                        DOCNO: transactionData[0]['DOCNO'],
                                        ITEMID: itemIdController.text,
                                        ITEMNAME: descriptionController.text,
                                        TRANSTYPE: transType == "STOCK COUNT"
                                            ? 1
                                            : widget.type == "GRN"
                                            ? 4
                                            : widget.type == "RP"
                                            ? 10
                                            : widget.type == "TO-OUT"
                                            ? 5
                                            : widget.type == "TO-IN"
                                            ? 6
                                            : "",
                                        DEVICEID: activatedDevice,
                                        QTY: int.parse(qtyController.text),
                                        UOM: disabledUOMSelection == "true"
                                            ? selectOUM
                                            : uomController.text,
                                        BARCODE: barcodeController.text,
                                        CREATEDDATE: DateTime.now().toString(),
                                        INVENTSTATUS: barcodeScanData[0]
                                        ['INVENTSTATUS'],
                                        SIZEID: sizeController.text ,
                                        COLORID:colorController.text ,
                                        CONFIGID: configController.text ,
                                        STYLESID:styleController.text ,
                                        STORECODE: activatedStore,
                                        LOCATION: transactionData[0]['VRLOCATION']
                                            .toString(),
                                        BATCHNO: batchNoController.text.trim(),
                                        EXPDATE: selectedEXPDate.toString(),
                                        // selectedExpDateFormatted.toString(),
                                        PRODDATE: selectedMGFDate.toString(),
                                        // selectedmgfDateFormatted.toString(),
                                        BatchEnabled: isBatchEnabled,
                                        BatchedItem: BatchedItem);



                                  }
                                  // print(barcodeScanData[0]);



                                  itemIdController.clear();
                                  barcodeController.clear();
                                  descriptionController.clear();
                                  uomController.clear();
                                  sizeController.clear();
                                  colorController.clear();
                                  styleController.clear();
                                  configController.clear();
                                  qtyController.clear();
                                  remainedQuantityController.clear();
                                  expDateController.clear();
                                  productionDateController.clear();
                                  batchNoController.clear();
                                  selectedEXPDate = null;
                                  selectedMGFDate = null;

                                  setState(() {
                                    isFocus = false;
                                  });
                                  FocusScope.of(context).unfocus();
                                }
                              }
                            }
                            FocusScope.of(context)
                                .requestFocus(_focusNodeBarcode);
                          }

                          if (widget.type == "PO" ||
                              widget.type == "RO" ||
                              widget.type == "TO") {
                            if (importedSearch != null && importedSearch!) {
                              print("Data from imported Search");
                              print(widget.transDetails);
                              var b = {
                                "HRecId": transactionData[0]['RecId'],
                                "STATUS": 1,
                                "AXDOCNO": transactionData[0]['AXDOCNO'],
                                "DOCNO": transactionData[0]['DOCNO'],
                                "ITEMID": widget.transDetails['ITEMID'],
                                "ITEMNAME": widget.transDetails['ITEMNAME'],
                                "TRANSTYPE": transType == "STOCK COUNT"
                                    ? 1
                                    : transType == "PURCHASE ORDER"
                                        ? 3
                                        : "",
                                "DEVICEID": activatedDevice,
                                'QTY': int.parse(qtyController.text),
                                'UOM': widget.transDetails['UOM'],
                                'BARCODE': widget.transDetails['BARCODE'],
                                'CREATEDDATE': DateTime.now().toString(),
                                'INVENTSTATUS':
                                    widget.transDetails['INVENTSTATUS'],
                                'SIZEID': widget.transDetails['SIZEID'],
                                'COLORID': widget.transDetails['COLORID'],
                                'CONFIGID': widget.transDetails['CONFIGID'],
                                'STYLESID': widget.transDetails['STYLESID'],
                                'STORECODE': activatedStore,
                                'LOCATION':
                                    transactionData[0]['VRLOCATION'].toString()
                              };
                              print(b);
                              // return;
                              var dt = await _sqlHelper
                                  .getFindItemExistOrnotTRANSDETAILS(
                                      DOCNO: transactionData[0]['DOCNO'],
                                      ITEMID: widget.transDetails['ItemId'],
                                      ITEMNAME: widget.transDetails['ItemName'],
                                      BARCODE:
                                          widget.transDetails['ITEMBARCODE'],
                                      TRANSTYPE: transType == "STOCK COUNT"
                                          ? 1
                                          : transType == "PURCHASE ORDER"
                                              ? 3
                                              : transType == "RETURN ORDER"
                                                  ? 9
                                                  : transType ==
                                                          "TRANSFER ORDER"
                                                      ? 11
                                                      : "",
                                      UOM: widget.transDetails['UNIT']);

                              print("Line 3469");
                              dt.forEach(print);
                              print(dt.length);

                              if (dt.length > 0) {
                                if (isBatchEnabled! &&
                                        !BatchedItem! &&
                                        dt[0]['BATCHNO'] !=
                                            batchNoController.text.trim() &&
                                        widget.type == "GRN" ||
                                    widget.type == "ST") {

                                  print("Line 5004");

                                  // return;


                                  await _sqlHelper.addTRANSDETAILS(
                                      HRecId: transactionData[0]['RecId'],
                                      STATUS: 1,
                                      AXDOCNO: transactionData[0]['AXDOCNO'],
                                      DOCNO: transactionData[0]['DOCNO'],
                                      ITEMID: itemIdController.text,
                                      ITEMNAME: descriptionController.text,
                                      TRANSTYPE: transType == "STOCK COUNT"
                                          ? 1
                                          : widget.type == "GRN"
                                              ? 4
                                              : widget.type == "RP"
                                                  ? 10
                                                  : "",
                                      DEVICEID: activatedDevice,
                                      QTY: int.parse(qtyController.text),
                                      UOM: disabledUOMSelection == "true"
                                          ?  selectOUM
                                          : uomController.text ,
                                      BARCODE: barcodeController.text.trim() ,
                                      CREATEDDATE: DateTime.now().toString(),
                                      INVENTSTATUS:
                                          widget.transDetails['INVENTSTATUS'],
                                      SIZEID: sizeController.text ,
                                      COLORID: colorController.text,
                                      CONFIGID: configController.text ,
                                      STYLESID: styleController.text ,
                                      STORECODE: activatedStore,
                                      LOCATION: transactionData[0]['VRLOCATION']
                                          .toString(),
                                      BATCHNO: batchNoController.text.trim(),
                                      EXPDATE: selectedEXPDate.toString(),
                                      // selectedExpDateFormatted.toString(),
                                      PRODDATE: selectedMGFDate.toString(),
                                      // selectedmgfDateFormatted.toString(),
                                      BatchEnabled: isBatchEnabled,
                                      BatchedItem: BatchedItem);
                                } else {
                                  await _sqlHelper.updateTRANSDETAILSWithQty(
                                      dt[0]['id'],
                                      int.parse(dt[0]['QTY']) +
                                          int.parse(qtyController.text));
                                }
                              } else {

                                print("Line 5050");

                                // return;

                                await _sqlHelper.addTRANSDETAILS(
                                    HRecId: transactionData[0]['RecId'],
                                    STATUS: 1,
                                    AXDOCNO: transactionData[0]['AXDOCNO'],
                                    DOCNO: transactionData[0]['DOCNO'],
                                    ITEMID: itemIdController.text,
                                    ITEMNAME: descriptionController.text,

                                    TRANSTYPE: transType == "STOCK COUNT"
                                        ? 1
                                        : transType == "PURCHASE ORDER"
                                            ? 3
                                            : transType == "RETURN ORDER"
                                                ? 9
                                                : transType == "TRANSFER ORDER"
                                                    ? 11
                                                    : "",
                                    DEVICEID: activatedDevice,
                                    QTY: int.parse(qtyController.text),
                                    UOM: disabledUOMSelection == "true"
                                        ?  selectOUM
                                        : uomController.text,
                                    BARCODE: barcodeController.text ,
                                    CREATEDDATE: DateTime.now().toString(),
                                    INVENTSTATUS:
                                        widget.transDetails['INVENTSTATUS'],
                                    SIZEID: sizeController.text ,
                                    COLORID: colorController.text ,
                                    CONFIGID: configController.text ,
                                    STYLESID: styleController.text ,
                                    STORECODE: activatedStore,
                                    LOCATION: transactionData[0]['VRLOCATION']
                                        .toString(),
                                    BATCHNO: batchNoController.text.trim(),
                                    EXPDATE: selectedEXPDate.toString(),
                                    // selectedExpDateFormatted.toString(),
                                    PRODDATE: selectedMGFDate.toString(),
                                    // selectedmgfDateFormatted.toString(),
                                    BatchEnabled: isBatchEnabled,
                                    BatchedItem: BatchedItem);
                              }

                              itemIdController.clear();
                              barcodeController.clear();
                              descriptionController.clear();
                              uomController.clear();
                              sizeController.clear();
                              colorController.clear();
                              styleController.clear();
                              configController.clear();
                              qtyController.clear();
                              expDateController.clear();
                              productionDateController.clear();
                              batchNoController.clear();
                              selectedEXPDate = null;
                              selectedMGFDate = null;

                              remainedQuantityController.clear();

                              setState(() {
                                isFocus = false;
                                importedSearch = false;
                              });
                              // Navigator.push(context, MaterialPageRoute(
                              //     builder: (context)=>TransactionViewPage(
                              //       currentIndex: 1,
                              //       pageType: widget.transactionType,
                              //     )));
                            } else {
                              print("Data from imported Search NOt");

                              print(widget.transDetails);
                              print(transType);
                              var b = {
                                "HRecId": transactionData[0]['RecId'],
                                "STATUS": 1,
                                "AXDOCNO": transactionData[0]['AXDOCNO'],
                                "DOCNO": transactionData[0]['DOCNO'],
                                "ITEMID": itemIdController.text,
                                "ITEMNAME": descriptionController.text,
                                "TRANSTYPE": transType == "STOCK COUNT"
                                    ? 1
                                    : transType == "PURCHASE ORDER"
                                        ? 3
                                        : "",
                                "DEVICEID": activatedDevice,
                                'QTY': int.parse(qtyController.text),
                                'UOM': disabledUOMSelection == "true"
                                    ?  selectOUM
                                    : uomController.text ,
                                'BARCODE': barcodeController.text,
                                'CREATEDDATE': DateTime.now().toString(),
                                "INVENTSTATUS": barcodeScanData[0]
                                    ['INVENTSTATUS'],
                                "SIZEID": barcodeScanData[0]['SIZEID'],
                                "COLORID": barcodeScanData[0]['COLORID'],
                                "CONFIGID": barcodeScanData[0]['CONFIGID'],
                                "STYLESID": barcodeScanData[0]['STYLEID'],
                                "STORECODE": activatedStore,
                                "LOCATION":
                                    transactionData[0]['VRLOCATION'].toString()
                              };
                              print(b);

                              var dt = await _sqlHelper
                                  .getFindItemExistOrnotTRANSDETAILS(
                                      DOCNO: transactionData[0]['DOCNO'],
                                      ITEMID: itemIdController.text,
                                      ITEMNAME: descriptionController.text,
                                      BARCODE: barcodeController.text,
                                      TRANSTYPE: transType == "STOCK COUNT"
                                          ? 1
                                          : transType == "PURCHASE ORDER"
                                              ? 3
                                              : transType == "RETURN ORDER"
                                                  ? 9
                                                  : transType ==
                                                          "TRANSFER ORDER"
                                                      ? 11
                                                      : "",
                                      UOM: disabledUOMSelection == "true"
                                          ? selectOUM
                                          : uomController.text);

                              print("Line 3585");
                              dt.forEach(print);
                              print(dt.length);


                              // return;
                              if (dt.length > 0) {
                                if (isBatchEnabled! &&
                                        !BatchedItem! &&
                                        dt[0]['BATCHNO'] !=
                                            batchNoController.text.trim() &&
                                        widget.type == "GRN" ||
                                    widget.type == "ST") {

                                  print("Line 5184");

                                        // return;

                                  await _sqlHelper.addTRANSDETAILS(
                                      HRecId: transactionData[0]['RecId'],
                                      STATUS: 1,
                                      AXDOCNO: transactionData[0]['AXDOCNO'],
                                      DOCNO: transactionData[0]['DOCNO'],
                                      ITEMID: itemIdController.text,
                                      ITEMNAME: descriptionController.text,
                                      TRANSTYPE: transType == "STOCK COUNT"
                                          ? 1
                                          : widget.type == "GRN"
                                              ? 4
                                              : widget.type == "RP"
                                                  ? 10
                                                  : "",
                                      DEVICEID: activatedDevice,
                                      QTY: int.parse(qtyController.text),
                                      UOM: disabledUOMSelection == "true"
                                          ?  selectOUM
                                          : uomController.text ,
                                      BARCODE: barcodeController.text ,
                                      CREATEDDATE: DateTime.now().toString(),
                                      INVENTSTATUS:
                                          widget.transDetails['INVENTSTATUS'],
                                      SIZEID: styleController.text ,
                                      COLORID: colorController.text ,
                                      CONFIGID: configController.text ,
                                      STYLESID: styleController.text ,
                                      STORECODE: activatedStore,
                                      LOCATION: transactionData[0]['VRLOCATION']
                                          .toString(),
                                      BATCHNO: batchNoController.text.trim(),
                                      EXPDATE: selectedEXPDate.toString(),
                                      // selectedExpDateFormatted.toString(),
                                      PRODDATE: selectedMGFDate.toString(),
                                      // selectedmgfDateFormatted.toString(),
                                      BatchEnabled: isBatchEnabled,
                                      BatchedItem: BatchedItem);
                                } else {
                                  await _sqlHelper.updateTRANSDETAILSWithQty(
                                      dt[0]['id'],
                                      int.parse(dt[0]['QTY']) +
                                          int.parse(qtyController.text));
                                }
                              } else {
                                print("Line 5229");

                                // return;



                                await _sqlHelper.addTRANSDETAILS(
                                    HRecId: transactionData[0]['RecId'],
                                    STATUS: 1,
                                    AXDOCNO: transactionData[0]['AXDOCNO'],
                                    DOCNO: transactionData[0]['DOCNO'],
                                    ITEMID: itemIdController.text,
                                    ITEMNAME: descriptionController.text,
                                    TRANSTYPE: transType == "STOCK COUNT"
                                        ? 1
                                        : transType == "PURCHASE ORDER"
                                            ? 3
                                            : transType == "RETURN ORDER"
                                                ? 9
                                                : transType == "TRANSFER ORDER"
                                                    ? 11
                                                    : "",
                                    DEVICEID: activatedDevice,
                                    QTY: int.parse(qtyController.text),
                                    UOM: disabledUOMSelection == "true"
                                            ? selectOUM
                                            : uomController.text,
                                    BARCODE: barcodeController.text,
                                    CREATEDDATE: DateTime.now().toString(),
                                    INVENTSTATUS: barcodeScanData[0]
                                        ['INVENTSTATUS'],
                                    SIZEID: sizeController.text ,
                                    COLORID:colorController.text ,
                                    CONFIGID: configController.text ,
                                    STYLESID:styleController.text ,
                                    STORECODE: activatedStore,
                                    LOCATION: transactionData[0]['VRLOCATION']
                                        .toString(),
                                    BATCHNO: batchNoController.text.trim(),
                                    EXPDATE: selectedEXPDate.toString(),
                                    // selectedExpDateFormatted.toString(),
                                    PRODDATE: selectedMGFDate.toString(),
                                    // selectedmgfDateFormatted.toString(),
                                    BatchEnabled: isBatchEnabled,
                                    BatchedItem: BatchedItem);
                              }

                              itemIdController.clear();
                              barcodeController.clear();
                              descriptionController.clear();
                              uomController.clear();
                              sizeController.clear();
                              colorController.clear();
                              styleController.clear();
                              configController.clear();
                              qtyController.clear();
                              expDateController.clear();
                              productionDateController.clear();
                              batchNoController.clear();
                              remainedQuantityController.clear();

                              setState(() {});
                              selectedEXPDate = null;
                              selectedMGFDate = null;
                              isFocus = false;
                              setState(() {});
                            }
                            // FocusScope.of(context).unfocus();
                            FocusScope.of(context)
                                .requestFocus(_focusNodeBarcode);
                          }



                    if(_focusNodeQty.hasFocus && qtyController.text
                        =="" ) {
                      // FocusScope.of(context)
                      // .unfocus();
                      FocusScope.of(context)
                          .requestFocus(_focusNodeBarcode);
                    }
                    else{

                    }
                          // FocusManager.instance.primaryFocus?.unfocus();
                    // Focus.of(context).unfocus();
                          FocusScope.of(context)
                              .requestFocus(_focusNodeBarcode);
                          // FocusScope.of(context).requestFocus( FocusNode());
                          setState(() {
                            isFocus = true;
                          });

                          // await controller?.toggleFlash();

                           print("Added the the data line 5240");

                          await controller?.resumeCamera();
                        },
                        child: Text(
                          "ADD",
                          style: TextStyle(color: Colors.white),
                        )),
                  )),
                ],
              ),
            ))
          ],
        ),
        SizedBox(
          height: 25,
        ),
      ],
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
