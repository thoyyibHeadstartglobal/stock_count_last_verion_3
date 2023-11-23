import 'package:dynamicconnectapp/helper/local_db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/constant.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({this.editDetails, this.isAddUser});
  final editDetails;
  final isAddUser;

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController userIdController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  TextEditingController passwordController = TextEditingController();
  TextEditingController userTypeController = TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();

  bool isLoading = false;
  final SQLHelper _sqlHelper = SQLHelper();

  final _formKey = GlobalKey<FormState>();
  bool showPassword = false;

  @override
  void initState() {
    getUser();
    super.initState();
  }

  getUser() {
    if (widget.editDetails != null) {
      userIdController.text = widget.editDetails['userId'] ?? "";
      usernameController.text = widget.editDetails['username'] ?? "";
      passwordController.text = widget.editDetails['password'] ?? "";
      confirmPasswordController.text = widget.editDetails['password'] ?? "";
      userTypeController.text = widget.editDetails['usertype'] ?? "";
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.editDetails);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
            // Navigator.of(context).push(MaterialPageRoute(
            //     builder: (BuildContext context) => const SettingsPage()));
          },
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(
          //     Icons.settings,
          //     color: Colors.black,
          //   ),
          //   onPressed: () {
          //     // Navigator.of(context).push(MaterialPageRoute(
          //     //     builder: (BuildContext context) => const SettingsPage()));
          //   },
          // ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 16, top: 5, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              Center(
                child: !widget.isAddUser
                    ? Text(
                        "${"Edit Profile"}",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w500),
                      )
                    : Text(
                        "${"Add User"}",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w500),
                      ),
              ),
              SizedBox(
                height: 20,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor),
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(0, 10))
                          ],
                          shape: BoxShape.circle,
                          image: const DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                "https://cdn-icons-png.flaticon.com/512/21/21104.png",
                              ))),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      validator: (value) =>
                      value!.isEmpty ? 'Required *' : null,
                      decoration:  InputDecoration(
                        contentPadding: EdgeInsets.only(
                            left: 15, right: 15, top: 7, bottom: 7),
                        isDense: true,
                        focusedBorder:APPConstants().focusInputBorder,
                        enabledBorder: APPConstants().enableInputBorder,
                        labelText: "USER ID",
                        labelStyle: TextStyle(
                            color: Colors.black26

                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal)),
                        hintText: 'USER ID',
                        hintStyle: TextStyle(
                            color: Colors.black26

                        ),
                      ),
                      controller: userIdController,
                      keyboardType: TextInputType.name,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      validator: (value) =>
                      value!.isEmpty ? 'Required *' : null,
                      decoration:  InputDecoration(
                        contentPadding: EdgeInsets.only(
                            left: 15, right: 15, top: 7, bottom: 7),
                        isDense: true,
                        focusedBorder:APPConstants().focusInputBorder,

                        enabledBorder: APPConstants().enableInputBorder,
                        labelText: "USERNAME",
                        labelStyle: TextStyle(
                            color: Colors.black26

                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal)),
                        hintText: 'USERNAME',
                        hintStyle: TextStyle(
                            color: Colors.black26

                        ),
                      ),
                      controller: usernameController,
                      //
                      // keyboardType: TextInputType.number,
                    ),
                    SizedBox(
                      height: 10,
                    ),

                    TextFormField(
                      obscuringCharacter: '*',
                      obscureText: true,
                      validator: (value) =>
                      value!.isEmpty ? 'Required *' : null,
                      decoration:  InputDecoration(
                        contentPadding: EdgeInsets.only(
                            left: 15, right: 15, top: 7, bottom: 7),
                        isDense: true,
                        focusedBorder:APPConstants().focusInputBorder,
                        enabledBorder: APPConstants().enableInputBorder,
                        labelText: "Password",
                        labelStyle:  TextStyle(
                            color: Colors.black26

                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal)),
                        hintText: 'Password',
                        hintStyle: TextStyle(
                            color: Colors.black26

                        ),
                      ),
                      controller: passwordController,
                      //
                      // keyboardType: TextInputType.number,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      obscuringCharacter: '*',
                      obscureText: true,
                      validator: (value) =>
                      value!.isEmpty ? 'Required *' : null,
                      controller: confirmPasswordController,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(
                              left: 15, right: 15, top: 7, bottom: 7),
                          isDense: true,
                          focusedBorder:APPConstants().focusInputBorder,
                          enabledBorder: APPConstants().enableInputBorder,
                          hintText: "Confirm Password",
                          labelText: "Confirm Password",
                          hintStyle: TextStyle(
                              color: Colors.black26

                          ),
                          labelStyle:  TextStyle(
                              color: Colors.black26


                          ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal))),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("CANCEL",
                        style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2.2,
                            color: Colors.white)),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () async {

                      if (!_formKey.currentState!.validate()) {
                        if(confirmPasswordController.text.trim() != passwordController.text.trim()){
                          showDialogGotData("Confirm password is not matching");
                          return;
                        }
                        return;
                      } else {
                        if (widget.isAddUser) {
                          if(confirmPasswordController.text.trim() != passwordController.text.trim()){
                            showDialogGotData("Confirm password is not matching");
                            return;
                          }
                          await _sqlHelper.addUsers(
                              userId: userIdController.text.toString().toLowerCase(),
                              username: usernameController.text.toString().toLowerCase(),
                              password: passwordController.text,
                              userType: "user");

                          userIdController.clear();
                          usernameController.clear();
                          passwordController.clear();
                          confirmPasswordController.clear();
                          showDialogGotData("User Added Successfully");

                        } else {
                          if(confirmPasswordController.text.trim() != passwordController.text.trim()){
                            showDialogGotData("Confirm password is not matching");
                            return;
                          }
                          await _sqlHelper.updateUserDetails(
                              Id: widget.editDetails['id'],
                              userId: userIdController.text,
                              username: usernameController.text,
                              password: passwordController.text,
                              userType: "user");
                          showDialogGotData("User Updated Successfully");
                        }
                        print("valid");
                      }
                      // FirebaseDatabase.instance.ref()
                      //     .child('useProfileBrowse')
                      //     .child(user!.uid)
                      //     .update({
                      //   'name': displayNameController.text //yes I know.
                      // });
                      // FirebaseDatabase.instance.ref()
                      //     .child('useProfileBrowse')
                      //     .child(user!.uid)
                      //     .update({
                      //   'age': ageController.text //yes I know.
                      // });
                    },
                    child: const Text(
                      "SAVE",
                      style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 2.2,
                          color: Colors.white),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }



  showDialogGotData(String text){

    // set up the button
    Widget yesButton = TextButton(
      style: APPConstants().btnBackgroundYes,
      child: Text("Ok",
        style: APPConstants().YesText),
      onPressed: () {
        // saveSettings();
        setState(() {

        });
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

      // title: Text("User Added Successfully"),
      content: Text("$text"),
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
}
