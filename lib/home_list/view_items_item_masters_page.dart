// import 'package:dynamicconnectapp/helper/local_db.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';
//
// class ViewItemsPage extends StatefulWidget {
//   const ViewItemsPage({Key? key}) : super(key: key);
//
//   @override
//   State<ViewItemsPage> createState() => _ViewItemsPageState();
// }
//
// class _ViewItemsPageState extends State<ViewItemsPage> {
//   bool isLoading=true;
//   ScrollController _scrollController = ScrollController();
//   SQLHelper _sqlHelper = SQLHelper();
//
//   List<dynamic> itemMasters= [];
//   List<dynamic> itemMastersLists= [];
//
//   @override
//   void initState() {
//
//     // if()
//     getItemMasters();
//     // _scrollController.addListener(() {
//     //   print("max position");
//     //   print(_scrollController.position);
//     //   if (_scrollController.position.atEdge) {
//     //     bool isTop = _scrollController.position.pixels == 0;
//     //     if (isTop) {
//     //
//     //       setState((){
//     //         isLoading = false;
//     //       });
//     //       print('At the top');
//     //     } else {
//     //       print('At the bottom');
//     //     }
//     //   }
//     //   if (_scrollController.position.maxScrollExtent ==
//     //       _scrollController.position.pixels) {
//     //     if (!isLoading) {
//     //       isLoading = !isLoading;
//     //       setState((){
//     //
//     //       });
//     //       print(isLoading);
//     //
//     //       // Perform event when user reach at the end of list (e.g. do Api call)
//     //     }
//     //     else{
//     //       isLoading = false;
//     //       setState((){
//     //
//     //       });
//     //     }
//     //
//     //
//     //   }
//     //   else{
//     //   isLoading = true;
//     //   setState((){
//     //
//     //   });
//     //   }
//     // });
//     super.initState();
//   }
//
//
//   setValueLoadItemMaster(String ? key) async {
//     print("key");
//     print(key);
//
//     itemMasters = await  _sqlHelper.getItemMatersBySearch(key);
//
//     print(itemMasters.length);
//     // return;
//     for(var i=0;i<15;i++){
//       itemMastersLists.add(itemMasters[i]);
//     }
//     setState((){
//       isLoading=false;
//     });
//
//
//
//
//     // itemMasters = await _sqlHelper.getItemMatersBySearch
//     //   (key!);
//     //       if(itemMasters .length<=0){
//     //         // setState((){
//     //         //   isLoading= true;
//     //         //   itemMastersLists =[];
//     //         //   itemMasters =[];
//     //         // });
//     //         itemMasters = await _sqlHelper.getItemMatersBySearch
//     //           (key);
//     //         print(await _sqlHelper.getItemMatersBySearch
//     //           (key));
//     //         itemMasters.forEach((element) {
//     //
//     //           print(element);
//     //         });
//     //         for(var i=0;i<15;i++){
//     //           print(itemMasters[i]);
//     //           itemMastersLists.add(itemMasters[i]);
//     //         }
//     //       }
//     //    else{
//     //         print("itemMasters.length");
//     //         print(itemMasters.length);
//     //         // for(var i=0;i<15;i++){
//     //         //   itemMastersLists.add(itemMasters[i]);
//     //         // }
//     //       }
//
//
//
//   }
//
//   getItemMasters() async {
//
//
//
//     // return;
//     for(var i=0;i<15;i++){
//       itemMastersLists.add(itemMasters[i]);
//     }
//     setState((){
//       isLoading=false;
//     });
//   }
//
//   set(){
//     for(var i=0;i<5;i++){
//       itemMastersLists.add(itemMasters[i]);
//     }
//     setState((){
//
//     });
//
//   }
//
//   TextEditingController searchController =new TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar:
//       AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         automaticallyImplyLeading: false,
//         title: Column(
//           children: [
//             SizedBox(height: 10,),
//             TextField(
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
//                 hintStyle: TextStyle(
//                     color: Colors.black26
//
//                 ),
//
//                 prefixIcon: IconButton(
//                   icon: Icon(Icons.search),
//                   onPressed: () async {
//
//                     if(searchController.text.trim() == ""){
//
//                       setState((){
//                         isLoading= true;
//                         itemMastersLists =[];
//                         itemMasters =[];
//                       });
//                       await  getItemMasters();
//
//                       setState((){
//                         isLoading= false;
//                       });
//                       return;
//                     }
//                     var result = await _sqlHelper.getItemMatersBySearch(searchController.text);
//
//                     print(result.length);
//                     if(result.length >0){
//
//                       setState((){
//                         isLoading= true;
//                         itemMastersLists =[];
//                         itemMasters =[];
//                       });
//                       await setValueLoadItemMaster(searchController.text);
//                       setState((){
//                         isLoading=false;
//                       });
//                       return;
//                       print("search is found");
//                     }
//                     else{
//                       setState((){
//                         isLoading= true;
//                         itemMastersLists =[];
//                         itemMasters =[];
//                       });
//
//                       Future.delayed(const Duration(seconds: 3), () {
//
//
//
//                         setState((){
//                           isLoading= false;
//                         });
//
//                       });
//                       print("search is not found");
//                     }
//
//                   },
//                 ),
//                 suffixIcon: IconButton(
//                   icon: Icon(Icons.close,color: Colors.red,),
//                   onPressed: () async {
//                     // await _sqlHelper.getItemMatersBySearch(searchController.text);
//                     searchController.clear();
//                     print("search");
//                   },
//                 ),
//                 border: InputBorder.none,
//                 focusedBorder: OutlineInputBorder(
//
//                   borderSide: const BorderSide(
//                       color: Colors.black54, width: 0.1),
//                 ),
//                 enabledBorder:
//                 OutlineInputBorder(
//
//                   borderSide: const BorderSide(
//                       color: Colors.black54, width: 0.1),
//                 ),
//                 errorBorder: InputBorder.none,
//                 disabledBorder: InputBorder.none,
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
//
//               ),
//             ),
//           ],
//         ),
//       ),
//
//       body: Container(
//         margin: EdgeInsets.symmetric(horizontal: 20),
//         child: Column(
//           children: [
//             // SizedBox(height: 60,),
//
//             // SizedBox(height: 20,),
//             isLoading? Expanded(
//               child: Container(
//                 height: MediaQuery.of(context).size.height,
//                 child: Center(
//                   child:  Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CupertinoActivityIndicator(
//                         // color: Colors.green,
//                         radius: 50,
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ):
//
//             Expanded(child: Container(
//               height: MediaQuery.of(context).size.height ,
//               child: SmartRefresher(
//                 // scrollController: _scrollController,
//                 enablePullDown:  itemMasters.length != itemMastersLists .length ? true:false,
//                 enablePullUp:  true,
//                 header: WaterDropHeader(),
//                 footer: CustomFooter(
//                   builder: (BuildContext ? context,LoadStatus ? mode){
//                     Widget body ;
//                     print("last index 272");
//                     print(mode);
//                     // print(mode?.index == items.length-1);
//                     print(mode == LoadStatus.noMore);
//                     if( itemMasters.length == itemMastersLists .length){
//                       print("full loaded");
//                       body = Container();
//                     }
//                     else{
//
//                     }
//                     if(mode==LoadStatus.idle){
//                       print(LoadStatus.idle);
//                       print("ideal condition");
//                       print(itemMasters.length == itemMastersLists .length);
//                       print("ideal condition");
//                       if(itemMastersLists.length <=itemMasters.length){
//
//                         body = Container()
//                         // Text("pull up load")
//                             ;
//                       }
//                       else{
//                         body =
//                             Container()
//                         ;
//                       }
//
//                     }
//                     else if(mode==LoadStatus.loading && itemMastersLists.length !=itemMasters.length){
//                       body =
//                           CupertinoActivityIndicator(
//                             radius: 20,
//                           );
//                     }
//                     else if(mode == LoadStatus.failed){
//                       body = Text("Load Failed!Click retry!");
//                     }
//                     else if(mode == LoadStatus.canLoading){
//                       body = Text("release to load more");
//                     }
//                     else{
//                       body = Container();
//                       // Text("No more Data");
//                     }
//                     return Container(
//                       height: 55.0,
//                       child: Center(child:body),
//                     );
//                   },
//                 ),
//                 controller: _refreshController,
//                 onRefresh: _onRefresh,
//                 onLoading: _onLoading,
//                 child: ListView.builder(
//                   itemBuilder: (context,int index){
//                     return  Container(
//                         decoration: BoxDecoration(
//
//                             color: Colors.yellow[50],
//                             borderRadius: BorderRadius.circular(15.0),
//                             border: Border.all(
//                                 color: Colors.black12,
//                                 width: 1.2
//                             )
//                           // color: Colors.red,
//                         ),
//                         margin: EdgeInsets.only(right:0.0 ,bottom: 10.0,top:10.0 ,left: 0.0),
//                         padding: EdgeInsets.only(left: 10.0,bottom: 15,top: 15),
//                         //   height: 300,
//
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Row(
//                               children: [
//                                 // {id: 2, ITEMBARCODE: 3330000307227, ItemId: 33300003,
//                                 //   ItemName: 21ST CENT FOLICACID TAB 100S,
//                                 //   DATAAREAID: 1000, WAREHOUSE: ,
//                                 //   CONFIGID: , COLORID: , SIZEID: , STYLEID: ,
//                                 //   INVENTSTATUS: , QTY: 0.0, UNIT: PACK, ItemAmount: 0.0}
//                                 Expanded(child: Text("Item ID :")),
//                                 Expanded(child: Text(itemMastersLists[index]['ItemId']??""))
//                               ],
//                             ),
//                             SizedBox(height: 10,),
//                             Row(
//                               children: [
//                                 Expanded(child: Text("BARCODE  :")),
//                                 Expanded(child: Text(itemMastersLists[index]['ITEMBARCODE']??""))
//                               ],
//                             ),
//                             SizedBox(height: 10,),
//                             Row(
//                               children: [
//                                 Expanded(child: Text("Item Name :")),
//                                 Expanded(child: Text(itemMastersLists[index]['ItemName']??""))
//                               ],
//                             ),
//                             SizedBox(height: 10,),
//                             Row(
//                               children: [
//                                 Expanded(child: Text("Unit :")),
//                                 Expanded(child: Text(itemMastersLists[index]['UNIT']??""))
//                               ],
//                             ),
//                             SizedBox(height: 10,),
//                             Row(
//                               children: [
//                                 Expanded(child: Text("Style :")),
//                                 Expanded(child: Text(itemMastersLists[index]['STYLEID']??""))
//                               ],
//                             ),
//                             SizedBox(height: 10,),
//                             Row(
//                               children: [
//                                 Expanded(child: Text("Config :")),
//                                 Expanded(child: Text(itemMastersLists[index]['CONFIGID']??""))
//                               ],
//                             ),
//                             SizedBox(height: 10,),
//                             Row(
//                               children: [
//                                 Expanded(child: Text("Color :")),
//                                 Expanded(child: Text(itemMastersLists[index]['COLOR']??""))
//                               ],
//                             ),
//                             SizedBox(height: 10,),
//                             Row(
//                               children: [
//                                 Expanded(child: Text("Size :")),
//                                 Expanded(child: Text(itemMastersLists[index]['SIZEID']??""))
//                               ],
//                             ),
//                             SizedBox(height: 10,),
//                             // Row(
//                             //   children: [
//                             //     Expanded(child: Text("Item ID :")),
//                             //     Expanded(child: Text("30300"))
//                             //   ],
//                             // ),
//                           ],
//                         ));
//                   },
//
//                   // itemBuilder: (c, i) => Card(child: Center(child: Text(items[i]))),
//                   // itemExtent: 300.0,
//                   itemCount: itemMastersLists.length,
//                 ),
//               ),
//             ))
//           ],
//         ),
//       )
//       ,
//     );
//   }
//
//   // "11", "12",
//   // "13", "14", "15", "16", "17", "18", "19", "20","21", "22", "23", "24"
//
//   List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8","9", "10"];
//   List<String> item1 = [];
//   RefreshController _refreshController =
//   RefreshController(initialRefresh: false);
//
//   void _onRefresh() async{
//     // monitor network fetch
//     await Future.delayed(Duration(milliseconds: 1000));
//     // if failed,use refreshFailed()
//     _refreshController.refreshCompleted();
//   }
//   setvalue() {
//
//     for(var i= itemMastersLists.length-1; i < itemMasters.length -1;i++ ){
//       var u =0;
//       u++;
//
//       // item1.add(items[i-1]);
//       // print("contains value");
//       // print(!item1.any((element) => element.contains(items[i])));
//       //     if(!item1.any((element) => element.contains(items[i]))){
//       if(u<4){
//         print("contains value items : ${itemMasters.length.toString()}");
//         print("contains value item1 : ${itemMastersLists.length.toString()}");
//         if(itemMastersLists.length <=itemMasters.length){
//           print(itemMastersLists[i]);
//           // item1.add(items[i]);
//           // item1.add(items[i+1]);
//           // item1.add(items[i+2]);
//
//           itemMastersLists.length <=itemMasters.length  && itemMasters[i] !=null ?  itemMastersLists.add(itemMasters[i]):null;
//
//
//           itemMastersLists.length <=itemMasters.length  && itemMasters[i+1] !=null ?  itemMastersLists.add(itemMasters[i+1]):null;
//
//           itemMastersLists.length <=itemMasters.length  && itemMasters[i+2] !=null ?  itemMastersLists.add(itemMasters[i+2] ):null;
//
//           itemMastersLists.length <=itemMasters.length  && itemMasters[i+3] !=null ?  itemMastersLists.add(itemMasters[i+3] ):null;
//
//           itemMastersLists.length <=itemMasters.length  && itemMasters[i+4] !=null ?  itemMastersLists.add(itemMasters[i+4] ):null;
//
//
//           itemMastersLists.length <=itemMasters.length  && itemMasters[i+5] !=null ?  itemMastersLists.add(itemMasters[i+5]):null;
//
//
//           itemMastersLists.length <=itemMasters.length  && itemMasters[i+6] !=null ?  itemMastersLists.add(itemMasters[i+6]):null;
//
//           itemMastersLists.length <=itemMasters.length  && itemMasters[i+7] !=null ?  itemMastersLists.add(itemMasters[i+7] ):null;
//
//           itemMastersLists.length <=itemMasters.length  && itemMasters[i+8] !=null ?  itemMastersLists.add(itemMasters[i+8] ):null;
//
//           itemMastersLists.length <=itemMasters.length  && itemMasters[i+9] !=null ?  itemMastersLists.add(itemMasters[i+9] ):null;
//
//
//           itemMastersLists.length <=itemMasters.length  && itemMasters[i+10] !=null ?  itemMastersLists.add(itemMasters[i+10]):null;
//
//
//           itemMastersLists.length <=itemMasters.length  && itemMasters[i+11] !=null ?  itemMastersLists.add(itemMasters[i+11]):null;
//
//           itemMastersLists.length <=itemMasters.length  && itemMasters[i+12] !=null ?  itemMastersLists.add(itemMasters[i+12] ):null;
//
//           itemMastersLists.length <=itemMasters.length  && itemMasters[i+13] !=null ?  itemMastersLists.add(itemMasters[i+13] ):null;
//
//           itemMastersLists.length <=itemMasters.length  && itemMasters[i+14] !=null ?  itemMastersLists.add(itemMasters[i+14] ):null;
//
//           //   item1.length <=items.length   && items[i+1] !=null ?  item1.add(items[i+1]):null;
//           // item1.length <=items.length   && items[i+2] !=null  ?  item1.add(items[i+2]):null;
//           // item1.length <=items.length   && items[i+3] !=null  ?  item1.add(items[i+3]):null;
//           // // print( items[i+4]);
//           //
//           // item1.length <= items.length   && items[i+3] !=null  ?  item1.add(items[i+4]):null;
//
//
//           // item1.add(items[i+4]);
//         }
//         else{
//           item1.toSet().toList();
//           setState((){
//
//           });
//         }
//
//
//
//         return;
//       }
//       else{
//         item1.toSet().toList();
//         setState((){
//
//         });
//         return;
//       }
//
//
//       //     }
//     }
//     item1.toSet().toList();
//     setState((){
//
//     });
//
//
//   }
//
//   void _onLoading() async{
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
//
//     if(mounted)
//       setState(() {
//
//       });
//     // }
//     _refreshController.loadComplete();
//   }
//
//
//
// // @override
// // Widget build(BuildContext context) {
// //   return Scaffold(
// //     body: ,
// //   );
//
// }
