import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../helper/local_db.dart';

class HomeHistoryDetailsPage extends StatefulWidget {
HomeHistoryDetailsPage({this.indexData});

final dynamic indexData;

  @override
  State<HomeHistoryDetailsPage> createState() => _HomeHistoryDetailsPageState();
}

class _HomeHistoryDetailsPageState extends State<HomeHistoryDetailsPage> {


  final   SQLHelper _sqlHelper = SQLHelper();
  @override
  void initState() {
    getHistoryDetails();
    super.initState();
  }

  List<dynamic> docDetailsHistoryList=[];
  getHistoryDetails() async {
    docDetailsHistoryList= await _sqlHelper.getTRANSDETAILSHistory(
        widget.indexData ['TRANSTYPE'],
        widget.indexData ['DOCNO']
    );
    setState((){

    });
    docDetailsHistoryList.forEach((element) {

      print(element);
    });

    print("elements 39");
  }

  int indexSelected=-1;
  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Scaffold(


        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          elevation: 0,
          backgroundColor: Colors.red,
          // backgroundColor:  Color(0xfff4e7e6),
          title: Text( widget.indexData ['DOCNO'] ??"",
          style: TextStyle( color: Colors.white, )),

        ),
        body: Column(

          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: docDetailsHistoryList.length,
                  itemBuilder: (context ,int index){
                    return  InkWell(
                      onTap: (){


                        setState((){
                          indexSelected= index;
                        });
                      },
                      child: Tooltip(
                        decoration:BoxDecoration(
                          color: Colors.red,
                        ),
                        message: "ITEM ID :${docDetailsHistoryList[index]['ITEMID']??""}",

                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin:EdgeInsets.symmetric(vertical: 0,horizontal: 0),
                          color: indexSelected == index
                              ? Colors.red[200]
                              :null,
                          child: Column(
                            children: [
                              Container(
                                  decoration: BoxDecoration(
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
                                          Expanded(child: Text("SL NO :")),
                                          Expanded(child: Text("${index+1}")),

                                          // style: TextStyle(
                                          //     color: Colors.red,
                                          //
                                          //     fontSize: 18,
                                          //     fontFamily:"RobotoSerif",
                                          //     fontWeight: FontWeight.bold
                                          // ),

                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Expanded(child: Text("ITEM ID :")),
                                          Expanded(child: Text(docDetailsHistoryList[index]['ITEMID']??"")),

                                          // style: TextStyle(
                                          //     color: Colors.red,
                                          //
                                          //     fontSize: 18,
                                          //     fontFamily:"RobotoSerif",
                                          //     fontWeight: FontWeight.bold
                                          // ),

                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Row(
                                        children: [
                                          // {id: 2, ITEMBARCODE: 3330000307227, ItemId: 33300003,
                                          //   ItemName: 21ST CENT FOLICACID TAB 100S,
                                          //   DATAAREAID: 1000, WAREHOUSE: ,
                                          //   CONFIGID: , COLORID: , SIZEID: , STYLEID: ,
                                          //   INVENTSTATUS: , QTY: 0.0, UNIT: PACK, ItemAmount: 0.0}
                                          Expanded(child: Text("BARCODE :")),
                                          Expanded(child: Text(docDetailsHistoryList[index]['BARCODE']??"")),
                                          // Expanded(child: Text(itemMastersLists[index].toString())),

                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Row(
                                        children: [
                                          Expanded(child: Text("ITEM NAME :")),
                                          Expanded(child: Text(docDetailsHistoryList[index]['ITEMNAME']??""))
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Row(
                                        children: [
                                          Expanded(child: Text("UNIT :")),
                                          Expanded(child: Text(docDetailsHistoryList[index]['UOM']??""))
                                        ],
                                      ),

                                      SizedBox(height: 10,),
                                      Row(
                                        children: [
                                          Expanded(child: Text("QTY :")),
                                          Expanded(child: Text(docDetailsHistoryList[index]['QTY']??""))
                                        ],
                                      ),

                                      // Row(
                                      //   children: [
                                      //     Expanded(child: Text("QTY :")),
                                      //     Expanded(child: Text("${onHandList[index]['QTY']?.toString() ??""}"
                                      //         "\t\t\t\t  \t\t\t\t${onHandList[index]['UNIT']?.toString() ??""}"))
                                      //   ],
                                      // ),
                                      SizedBox(height: 10,),


                                      SizedBox(height: 10,),
                                      Row(
                                        children: [

                                          Expanded(child: Text("Batch Enabled :")),
                                          Expanded(child: Text("${docDetailsHistoryList[index]['BatchEnabled']
                                          .toString() == "1"?  "true":"false"
                                              }")),

                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Row(
                                        children: [

                                          Expanded(child: Text("Batched Item :")),
                                          Expanded(child: Text("${docDetailsHistoryList[index]['BatchedItem']
                                              .toString() == "1" ?  "true":"false"}")),


                                        ],
                                      ),

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
