import 'dart:async';
import 'dart:io';
import 'package:fattafatt_rider/controller/localization_controller.dart';
import 'package:fattafatt_rider/controller/splash_controller.dart';
import 'package:fattafatt_rider/controller/theme_controller.dart';
import 'package:fattafatt_rider/helper/notification_helper.dart';
import 'package:fattafatt_rider/helper/route_helper.dart';
import 'package:fattafatt_rider/theme/dark_theme.dart';
import 'package:fattafatt_rider/theme/light_theme.dart';
import 'package:fattafatt_rider/util/app_constants.dart';
import 'package:fattafatt_rider/util/messages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:url_strategy/url_strategy.dart';
import 'controller/auth_controller.dart';
import 'helper/get_di.dart' as di;
import 'package:rxdart/subjects.dart';

import 'util/chat_helpers.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();
String selectedNotificationPayload;
Sockets socketService;

Future<void> main() async {
  if(!GetPlatform.isWeb) {
    HttpOverrides.global = new MyHttpOverrides();
  }
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version+packageInfo.buildNumber;
  String currentAppVersion = version.replaceAll(".", "");
  debugPrint("currentAppVersion:-> $currentAppVersion");
  AppConstants.APP_VERSION = int.parse(currentAppVersion);
  await Firebase.initializeApp();
  FirebaseMessaging.instance.getToken().then((value) => print("FCM Token:-> $value"));
  socketService = Sockets(
      socket: socketConnection
  );
  Map<String, Map<String, String>> _languages = await di.init();
  try {
    if (GetPlatform.isMobile) {

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        String _orderID = message?.notification?.titleLocKey??"";
        if(_orderID.isNotEmpty){
          Get.toNamed(
            RouteHelper.getOrderDetailsRoute(int.parse(_orderID),'Yes'),
          );
        }
      });

      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

    }
  }catch(e) {}

  runApp(MyApp(languages: _languages));
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>> languages;
  MyApp({@required this.languages});

  void _route() {
    Get.find<SplashController>().getConfigData().then((bool isSuccess) async {
      if (isSuccess) {
        if (Get.find<AuthController>().isLoggedIn()) {
          Get.find<AuthController>().updateToken();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if(GetPlatform.isWeb) {
      Get.find<SplashController>().initSharedData();
      _route();
    }

    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetBuilder<SplashController>(builder: (splashController) {
          return (GetPlatform.isWeb && splashController.configModel == null) ? SizedBox() : GetMaterialApp(
            title: AppConstants.APP_NAME,
            debugShowCheckedModeBanner: false,
            navigatorKey: Get.key,
            theme: themeController.darkTheme ? dark : light,
            locale: localizeController.locale,
            translations: Messages(languages: languages),
            fallbackLocale: Locale(AppConstants.languages[0].languageCode, AppConstants.languages[0].countryCode),
            initialRoute: RouteHelper.getSplashRoute(),
            getPages: RouteHelper.routes,
            defaultTransition: Transition.topLevel,
            transitionDuration: Duration(milliseconds: 500),
          );
        });
      });
    });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}