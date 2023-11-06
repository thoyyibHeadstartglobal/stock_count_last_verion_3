import 'package:dynamicconnectapp/helper/local_db.dart';
import 'package:dynamicconnectapp/user_details/update_user_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/constant.dart';



class AppUserPage extends StatefulWidget {
  const AppUserPage({Key? key}) : super(key: key);

  @override
  State<AppUserPage> createState() => _AppUserPageState();
}

class _AppUserPageState extends State<AppUserPage> {
  final GlobalKey<FormState> ?_formKey = GlobalKey<FormState>();



  @override
  void initState() {
   getUsers();
   super.initState();
  }
  SQLHelper _sqlHelper  = SQLHelper();
  List<dynamic> users=[];
 int _selectedIndex =-1;
  getUsers()async{
    print("app User");

   users =   await  _sqlHelper.getUserWithOutAdmin();
   setState((){

   });
   print(users.length);
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: null,
      floatingActionButton: Tooltip(
        message: "ADD USER",
        child: FloatingActionButton(
          onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>  EditProfilePage(
                        // editDetails: lst,
                        isAddUser: true,))).whenComplete(() {
                    getUsers();
                  });
          },
          backgroundColor: Colors.green,
          child: Icon(Icons.person_add_alt_1,
           ),
        ),
      ),
      body:
      users.isNotEmpty ?
      SingleChildScrollView(
        child:

       Column(
          children: [

          SizedBox(height: 20,),


            Container(
              // color: Colors.red,
              height: MediaQuery.of(context).size.height,
              child:

              ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 5),
                physics: ClampingScrollPhysics(),
                  itemBuilder: (context,int index){
                    // final lst =users[index];
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.black12,
                      height: 60,
                      child: Row(
                        children: [
                          Expanded(
                            flex:3,
                            child: Text(users[index]['username'],
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17
                            ),),
                          ),
                          Expanded(child:
                          Tooltip(
                            message: "EDIT",
                            child: IconButton(
                               onPressed: () {
                                 // print(lst);
                                 Navigator.of(context).push(MaterialPageRoute(
                                     builder: (BuildContext context) =>  EditProfilePage(

                                       editDetails: users[index],
                                     isAddUser: false,))).whenComplete(() {
                                   getUsers();
                                 });
                               }, icon: Icon(Icons.edit,
                            color:APPConstants().colorGreen)),
                          ),
                          ),
                          Expanded(
                              child:
                          Tooltip(
                            message: "DELETE",
                            child: IconButton(
                              onPressed: ()  {
                                removeDialogUser(context, index);
                                    // users.remove(lst);

                              },
                              icon: Icon(Icons.delete_forever_outlined,
                                  color:APPConstants().colorRed),),
                          ))


                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context,int index){
                      // return Container();
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 10,vertical: 2),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      // child: Divider(
                      //
                      //   height: 1,
                      //   thickness: 3,
                      // ),
                    );
                  },
                  itemCount: users.length)
            ),


          ],
        )
      )
          :

      Container(
        width: MediaQuery.of(context).size.width,
        // color: Colors.red,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.not_interested,color: Colors.red,size: 25,),
                Text("Empty",
                style: TextStyle(
                    color: Colors.red,fontSize: 25
                ),),
                // SizedBox(width: 10,),
              ],

        ),
      ),

    );
  }


  removeDialogUser(context,int index ){
    // print(onpress);
    // return;
    showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("Do You Want to Remove This User ?"),
            actions: <Widget>[
              TextButton(

                // color:
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: Text("Yes"
                ,
                  style: APPConstants().YesText,),
                onPressed:() async {
                    print(index);
                    print(users[index]['id']);
                    await _sqlHelper.deleteUsers(users[index]['id']);
                    // return;
                 // var v=   users.removeWhere((item) => item['index'] == users[index]);
                    users =[];
                    getUsers();
                    setState((){

                    });
                  // users.removeAt(index);

                    Navigator.pop(context);


                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                ), // color:
                child: Text("No",
          style: APPConstants().YesText,),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
