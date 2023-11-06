import 'package:dynamicconnectapp/constants/constant.dart';
import 'package:dynamicconnectapp/helper/local_db.dart';
import 'package:dynamicconnectapp/common_pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
   LoginPage({this.isLogg});
  final bool ? isLogg;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController userIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLogged =false;
  SharedPreferences? prefs;
  final SQLHelper _sqlHelper = SQLHelper();
  bool isShowPassword = true;


@override
  void initState() {
      getUsername();
    super.initState();
  }
  String ?username;
  getUsername()async{
    print("checked 30");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    isLogged = prefs.getBool('isLoggedIn') ?? false;
    print("Logged status is : ${isLogged.toString()}");
    print(await prefs.getString("isLogged"));
    username = await  prefs.getString(
        "username");

    setState((){

    });

    print(username);
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()
      async
      {

        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: null,
          body: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              // decoration: BoxDecoration(
              //     image: DecorationImage(
              //         fit: BoxFit.cover,
              //         image: NetworkImage(
              //           "https://headstartglobal.com/wp-content/uploads/2020/12/logo1.png",
              //
              //           // fit: BoxFit.fill,
              //         ))),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text("${username.runtimeType}"),
                      Spacer(),
                      // Spacer(),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //
                      //     Image.network(
                      //       "https://headstartglobal.com/wp-content/uploads/2020/12/logo1.png",
                      //       fit: BoxFit.fill,
                      //     ),
                      //   ],
                      // ),
                      Spacer(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Image.asset(
                            "assets/logo_company.png",
                            fit: BoxFit.fill,
                          ),
                        ],
                      ),
                      Spacer(),
                      TextFormField(

                            validator: (value) => value!.isEmpty ? 'Required *' : null,
                            controller: userIdController,
                            decoration: InputDecoration(
                              prefixIcon: IconButton(
                                icon:
                                Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.red
                                ),
                                onPressed: ()
                                {

                                },
                              ),
                            focusedBorder:APPConstants().focusInputBorder ,
                            enabledBorder: APPConstants().enableInputBorder,
                            contentPadding: EdgeInsets.only(top: 12,bottom: 12,left: 15),
                            isDense: true,
                            fillColor: Colors.white,
                            focusColor: Colors.white,
                            hintText: "User ID",
                            hintStyle: TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                    // color: APPConstants().colorRed,
                                    width: 0.5
                                )
                              // borderSide: Border()
                            )),

                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        validator: (value) => value!.isEmpty ? 'Required *' : null,
                        controller: passwordController,
                        obscuringCharacter: '*',
                        obscureText: isShowPassword,
                        decoration: InputDecoration(
                            focusedBorder:APPConstants().focusInputBorder ,
                            enabledBorder: APPConstants().enableInputBorder,
                            prefixIcon: IconButton(
                              icon: Icon(
                                Icons.lock_open_outlined,
                                size: 30,
                                color: Colors.red),
                              onPressed: () {  },
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                passwordController.text !=null &&
                                    passwordController.text !="" &&
                                isShowPassword ?
                                Icons.remove_red_eye_outlined :
                                Icons.remove_red_eye,
                                size: 30,
                                color: Colors.red,),
                              onPressed: () {
                                setState((){
                                  isShowPassword =!isShowPassword;
                                });
                              },
                            ),
                            contentPadding: EdgeInsets.only(top: 12,bottom: 12,left: 15),
                            isDense: true,
                            hintText: "password",
                            hintStyle: TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              // borderSide: Border()
                            )),
                      ),
                      Row(
                        children: [
                          Spacer(),
                          Text("Keep Logged In"),
                          Checkbox(
                            activeColor:  APPConstants().colorRed,
                              value: isLogged,
                              onChanged: (v){
                                setState((){
                                      isLogged= v!;
                                    });
                              })

                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? MediaQuery.of(context).size.height / 15
                            : MediaQuery.of(context).size.height / 6,
                        width: MediaQuery.of(context).size.width,
                        // flex: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: TextButton(

                         style:
                                   APPConstants().btnBackgroundNo,
                            onPressed: () async {
                              var st = _formKey.currentState;
                              print(st!.validate());
                              // final FormState? form = _formKey.currentState!;
                              if (st.validate()) {

                                print('Form is valid');

                              } else {
                                print('Form is invalid');
                              }

                              if (userIdController.text.trim() == "" ||
                                  passwordController.text.trim() == "") {
                                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                //
                                //   content: Text('Invalid Credentials',textAlign: TextAlign.center,),
                                // ));
                              } else {
                                var result = await _sqlHelper.checkAdminUserLogin(
                                    userId: userIdController.text.toLowerCase(),
                                    password: passwordController.text
                                        ,
                                );
                                print("login user Status : ${result}");
                                // if(usernameController.text != "Admin"
                                //     && passwordController.text !="@dmin"){

                                if (result != "Login Success") {

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                      'Invalid Credentials',
                                      textAlign: TextAlign.center,
                                    ),
                                  ));
                                  return;
                                }
                                else{

                                  prefs = await SharedPreferences.getInstance();

                                dynamic log = await  _sqlHelper.checkAdminUserLoginByLoad(
                                    userId: userIdController.text.toString().toLowerCase() ,
                                    password: passwordController.text.toString()
                                  );
                                print("log is");
                                print(log[0]);
                                // return;
                                  await prefs?.setString(
                                      "userType",log[0]['userType'] ??"");
                                  await prefs?.setString(
                                      "userId",userIdController.text.trim());
                                  await prefs?.setString(
                                      "username", log[0]['username'] ??"");
                                  await prefs?.setString(
                                      "password", passwordController.text.trim());


                                  SharedPreferences ? pref = await SharedPreferences.getInstance();
                                  pref.setBool("isLoggedIn", isLogged);
                                  print("login user is :");
                                  print( await prefs?.getString(
                                      "isLogged"));
                                  // ScaffoldMessenger.of(context)
                                  //     .showSnackBar(
                                  //
                                  //     SnackBar(
                                  //
                                  //   content: Text(
                                  //     'Login Success ',
                                  //     textAlign: TextAlign.center,
                                  //   ),
                                  // ));
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LandingHomePage())).
                                  whenComplete((){
                                    getUsername();
                                  });
                                }
                              }
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Spacer(),
                      Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
