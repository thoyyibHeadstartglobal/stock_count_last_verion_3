import 'package:flutter/cupertino.dart';

class _NavigatorHistory extends NavigatorObserver {
  _NavigatorHistory(){
    // didStartUserGesture(route, previousRoute);
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    // TODO: implement didStartUserGesture
    print("${route.settings.name} popped");
    print("${previousRoute?.settings.name} popped");
    super.didStartUserGesture(route, previousRoute);
  }


  // @override
  // void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
  //   print("${route.settings.name} pushed");
  // }
  //
  // @override
  // void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
  //   print("${route.settings.name} popped");
  // }
  //
  // @override
  // void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
  //   print("${oldRoute.settings.name} is replaced by ${newRoute.settings.name}");
  // }
  //
  // @override
  // void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
  //   print("${route.settings.name} removed");
  // }


}