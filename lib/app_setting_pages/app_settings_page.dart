
import 'package:dynamicconnectapp/app_setting_pages/project_setting_environment_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_general_page.dart';
import 'app_user_page.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({Key? key}) : super(key: key);

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          // backgroundColor: Color(0xffc8c4c3),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kMinInteractiveDimension),
            child: AppBar(
              backgroundColor: Colors.red,
              // backgroundColor:  Color(0xfff4e7e6),
              // backgroundColor:  Color(0xffed648e),
              elevation: 0,
              bottom: TabBar(
                labelColor: Colors.white,
                indicator: BoxDecoration(
                  color: Colors.red[800],

                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white,
                      width: 4.0,
                    ),
                  ),
                ),

                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Colors.black,
                tabs: [
                  Tab(child: Text("APP SETTINGS",style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),)),
                  Tab(child: Text("APP USER",style: TextStyle(
                      fontSize: 12,
                    color: Colors.white,
                  ))),
                  Tab(child: Text("GENERAL",style: TextStyle(
                      fontSize: 12,
                    color: Colors.white,
                  ))),
                ],
              ),
              // title: Text('Tabs Demo'),
            ),
          ),
          body: TabBarView(
            children: [
              ProjectSettingsEnvironmentPage( isSettings: true),
              AppUserPage(),
              AppGeneralPage(),
            ],
          ),
        ),
      ),
    );
  }
}
