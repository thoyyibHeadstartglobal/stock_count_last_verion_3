import 'package:dynamicconnectapp/home_list/transaction_view_pages/transaction_add_item_page.dart';
import 'package:dynamicconnectapp/home_list/transaction_view_pages/transaction_header_page.dart';
import 'package:dynamicconnectapp/home_list/transaction_view_pages/transaction_lines_page.dart';
import 'package:dynamicconnectapp/common_pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TransactionViewPage extends StatefulWidget {

   TransactionViewPage({this.pageType,this.currentIndex,this.transDetails,this.isImportedSearch});
   final bool   ? isImportedSearch ;
   final dynamic transDetails;
final dynamic pageType;
final dynamic currentIndex;

  @override
  State<TransactionViewPage> createState() => _TransactionViewPageState();
}

class _TransactionViewPageState extends State<TransactionViewPage>  with SingleTickerProviderStateMixin{


  late TabController tabController;
  @override
  void initState() {
    getTransTypes();

    // tabController = new TabController(vsync: this, length: myList.length);
    tabController = TabController(
      length: 3,
      // initialIndex: pageIndex,
      vsync: this,
    );

    tabController.animation!.addListener(() {
      print("listening animation");
      setState(() {
        // Current animation value. It ranges from 0 to (tabsCount - 1)
        final animationValue = tabController.animation!.value;
        // Simple rounding gives us understanding of what tab is showing
        final currentTabIndex = animationValue.round();
        // currentOffset equals 0 when tabs are not swiped
        // currentOffset ranges from -0.5 to 0.5
        final currentOffset = currentTabIndex - animationValue;
        for (int i = 0; i < 3; i++) {
          if (i == currentTabIndex) {
            // For current tab bringing currentOffset to range from 0.0 to 1.0
            tabScales[i] = (0.5 - currentOffset.abs()) / 0.5;
          } else {
            // For other tabs setting scale to 0.0
            tabScales[i] = 0.0;
          }
        }
      });
    });
    super.initState();
  }

  var transType="";
 int pageIndex =0;
  getTransTypes(){
    if(widget.currentIndex ==0){
      setState((){
           pageIndex=0;
      });
    }
    else{
      setState((){
        pageIndex=widget.currentIndex ??0 ;
      });
    }
    if(widget.pageType == "STOCK COUNT"){
         transType= "ST";
         setState((){

         });
    }
    if(widget.pageType == "PURCHASE ORDER"){
      transType= "PO";
      setState((){

      });
    }
    if(widget.pageType == "GOODS RECEIVE"){
      transType= "GRN";
      setState((){

      });
    }

    if(widget.pageType == "RETURN PICK"){
      transType= "RP";
      setState((){

      });
    }

    if(widget.pageType == "RETURN ORDER"){
      transType= "RO";
      setState((){

      });
    }

    if(widget.pageType   == "MOVEMENT JOURNAL"){

      transType= "MJ";
      setState((){

      });
    }


    if(widget.pageType   == "TRANSFER ORDER"){
    transType= "TO";
    setState((){

    });
    }




    if(widget.pageType   == "TRANSFER OUT"){
      transType= "TO-OUT";
      setState((){

      });
    }


    if(widget.pageType   == "TRANSFER IN"){
      transType= "TO-IN";
      setState((){

      });
    }
  }

  static const initialIndex = 0;

  // Number of tabs
  static const tabsCount = 3;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  // List with current scales for each tab's fab
  // Initialize with 1.0 for initial opened tab, 0.0 for others
  final tabScales =
  List.generate(tabsCount, (index) => index == initialIndex ? 1.0 : 0.0);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        Navigator.push(context, MaterialPageRoute(builder: (context)=> LandingHomePage()));
        return true;
      },
      child:  SafeArea(
        child:
         DefaultTabController(

          initialIndex: pageIndex,
          length: 3,
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(kMinInteractiveDimension),
              child: AppBar(
                backgroundColor: Colors.red,
                // backgroundColor:  Color(0xfff4e7e6),
                // backgroundColor: const Color(0xffed648e),
                centerTitle: true,
                // backgroundColor:
                // // Color(0xff82bef2),
                // Color(0xffa97ef4),
                elevation: 0,

                bottom: TabBar(
                  // isScrollable: true,
                  // controller: tabController ,



                  onTap: (int index){

                    print("the index is : ${index +1} page");

                  },
                  // indicator: BoxDecoration(
                  //   color: Color(0xffff00a8),
                  //   // color: _hasBeenPressed ? Color(0xffffffff) : Color(0xffff00a8),
                  // ),
                  // unselectedLabelColor: Color(0xffff00a8),
                  // indicatorColor: Color(0xffff00a8),
                  // labelColor: Color(0xffffffff),
                  labelColor: Colors.white,
                  indicator: BoxDecoration(
                    color: Colors.red[800],

                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white,
                        width: 4.0,
                      ),

                      // top: BorderSide(
                      //   color: Colors.white,
                      //   width: 4.0,
                      // ),
                      // right: BorderSide(
                      //   color: Colors.white,
                      //   width: 4.0,
                      // ),
                      // left: BorderSide(
                      //   color: Colors.white,
                      //   width: 4.0,
                      // )
                    ),
                  ),

                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor: Colors.black,
                  tabs: [
                    Tab(
                        child: Text(
                      "${transType} - HEADER",
                      style: TextStyle(fontSize: 12,
                      color: Colors.white),
                    )),
                    Tab(
                        child:
                            InkWell(
                              onTap: (){

                                print("Clicked the add item");
                              },
                              child: Text("${transType} - ADD ITEM",
                                  style: TextStyle(fontSize: 12,
                                  color: Colors.white)),
                            )),
                    Tab(child: Text("${transType} - LINES", style: TextStyle(fontSize: 12,
                        color: Colors.white))),
                  ],
                ), // title: Text('Tabs Demo'),
              ),
            ),
            body: TabBarView(
              // physics: const NeverScrollableScrollPhysics(),
              // controller: tabController,
              children: [

                TranscationHeaderPage(
                    type: transType,
                ),
                TranscationAddItemPage(
                  touchTab: true,
                  type: transType,
                    isImportedSearch: widget.isImportedSearch !=null
                        && widget.isImportedSearch! ? true:false ,
                  transDetails:widget.isImportedSearch !=null && widget.isImportedSearch! ?
                  widget.transDetails :""  ),
                TranscationLinesPage(
                  type: transType,),
              ],
            ),
            // floatingActionButton:
            // createScaledFab(),
          ),
        ),
      ),
    );
  }

  Widget? createScaledFab() {

    // Searching for index of a tab with not 0.0 scale
    final indexOfCurrentFab = [ "${transType} - HEADER","${transType} - ADD ITEM","${transType} - LINES"]
        .indexWhere((fabScale) => fabScale != 0);
    print("loading index : ${indexOfCurrentFab.toString()}");
    // If there are no fabs with non-zero opacity return nothing
    if (indexOfCurrentFab == -1) {
      return null;
    }
    // Creating fab for current index
    final fab = createFab(indexOfCurrentFab);
    // If no fab created return nothing
    if (fab == null) {
      return null;
    }
    final currentFabScale = [ "${transType} - HEADER","${transType} - ADD ITEM","${transType} - LINES"][indexOfCurrentFab];
    // Scale created fab with
    // You can use different Widgets to create different effects of switching
    // fabs. E.g. you can use Opacity widget or Transform.translate to create
    // custom animation effects
    return Transform.scale(scale: double.parse(currentFabScale), child: fab);
  }

  // Create fab for provided index
  // You can skip creating fab for any indexes you want
  Widget? createFab(final int index) {
    print("The given index is");
    if (index == 0) {
      return FloatingActionButton(
        onPressed: () => print("On first fab clicked"),
        child: Icon(Icons.one_k),
      );
    }
    // Not created fab for 1 index deliberately
    if (index == 2) {
      return FloatingActionButton(
        onPressed: () => print("On third fab clicked"),
        child: Icon(Icons.three_k),
      );
    }
  }
}

