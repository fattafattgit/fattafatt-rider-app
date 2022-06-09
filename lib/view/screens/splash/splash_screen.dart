import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:fattafatt_rider/controller/auth_controller.dart';
import 'package:fattafatt_rider/controller/splash_controller.dart';
import 'package:fattafatt_rider/helper/route_helper.dart';
import 'package:fattafatt_rider/util/app_constants.dart';
import 'package:fattafatt_rider/util/dimensions.dart';
import 'package:fattafatt_rider/util/images.dart';
import 'package:fattafatt_rider/util/styles.dart';
import 'package:fattafatt_rider/view/base/no_internet_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ota_update/ota_update.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<ConnectivityResult> _onConnectivityChanged;
  OtaEvent currentEvent;

  @override
  void initState() {
    super.initState();

    bool _firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if(!_firstTime) {
        bool isNotConnected = result != ConnectivityResult.wifi && result != ConnectivityResult.mobile;
        isNotConnected ? SizedBox() : ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isNotConnected ? Colors.red : Colors.green,
          duration: Duration(seconds: isNotConnected ? 6000 : 3),
          content: Text(
            isNotConnected ? 'no_connection' : 'connected',
            textAlign: TextAlign.center,
          ),
        ));
        if(!isNotConnected) {
          _route();
        }
      }
      _firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    _route();

  }

  @override
  void dispose() {
    super.dispose();

    _onConnectivityChanged.cancel();
  }

  void _route() {
    Get.find<SplashController>().getConfigData().then((isSuccess) {
      if(isSuccess) {
        Timer(Duration(seconds: 1), () async {
          int _minimumVersion = 0;
          if(GetPlatform.isAndroid) {
            _minimumVersion = Get.find<SplashController>().configModel.appMinimumVersionAndroid;
          }else if(GetPlatform.isIOS) {
            _minimumVersion = Get.find<SplashController>().configModel.appMinimumVersionIos;
          }

          print("_minimumVersion:-> $_minimumVersion");
          print("AppConstants.APP_VERSION:-> ${AppConstants.APP_VERSION}");

          if(AppConstants.APP_VERSION < _minimumVersion || Get.find<SplashController>().configModel.maintenanceMode) {

            if(GetPlatform.isAndroid){
              bool isUpdated = await updateAndroidApp(latestAppUrl: Get.find<SplashController>().configModel.appUrlAndroid);
              print("Update Required:-> $isUpdated");
              if(!isUpdated){
                _runNormalAppFlow();
              }
            }else if(GetPlatform.isIOS||Get.find<SplashController>().configModel.maintenanceMode){
              Get.offNamed(RouteHelper.getUpdateRoute(AppConstants.APP_VERSION < _minimumVersion));
            }
          }
          else{
            _runNormalAppFlow();
          }
        });
      }
    });
  }

  _runNormalAppFlow()async{



      if (Get.find<AuthController>().isLoggedIn()) {
        Get.find<AuthController>().updateToken();
        await Get.find<AuthController>().getProfile();
        Get.offNamed(RouteHelper.getInitialRoute());

        RemoteMessage message  =  await FirebaseMessaging.instance.getInitialMessage();

        if(message!=null){
          print("Opened app from FCM");
          String _orderID = message?.notification?.titleLocKey??"";
          if(_orderID.isNotEmpty){

            Get.toNamed(
              RouteHelper.getOrderDetailsRoute(int.parse(_orderID),'Yes'),
            );
          }
        }
      } else {
        if(AppConstants.languages.length > 1) {
          Get.offNamed(RouteHelper.getLanguageRoute());
        }else {
          Get.offNamed(RouteHelper.getSignInRoute());
        }
      }
  }


  Future<bool>updateAndroidApp({@required String latestAppUrl})async {
    if(Get.find<SplashController>().configModel.maintenanceMode){
      return false;
    }

    print("updating AndroidApp :-> $latestAppUrl");
    try {
     OtaUpdate().execute(
        latestAppUrl,
        destinationFilename: latestAppUrl.split('/').last,
      ).listen((OtaEvent event) {
        setState(() => currentEvent = event);
        print("currentEvent.value :-> ${currentEvent.value}");
        print("currentEvent.status :-> ${currentEvent.status}");
      },
      ).onDone(() {
        return true;
     });
    } catch (e) {
      print('Failed to make OTA update. Details: $e');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _globalKey,
      body: GetBuilder<SplashController>(builder: (splashController) {
        return Stack(
        children: [
          Center(
            child: splashController.hasConnection ?
            Image.asset(Images.splashCombinedLogo, width: deviceSize.shortestSide*.4,)
                : NoInternetScreen(child: SplashScreen()),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                Images.splashBottomCroppedF,
                width: deviceSize.shortestSide*.89,
                height: deviceSize.shortestSide>600?deviceSize.shortestSide*.5:deviceSize.shortestSide*.89,
                alignment: Alignment.bottomLeft,
              ),
            ),
          ),


          (currentEvent!=null&&currentEvent.status==OtaStatus.DOWNLOADING)
              ? Positioned(
            bottom: 20,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Text(
                    'Downloading latest apk'.tr, textAlign: TextAlign.center,
                    style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_DEFAULT, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 10,),
                  SizedBox(
                    height: 30,
                    child: LiquidLinearProgressIndicator(
                      value: ((double.tryParse(currentEvent?.value??"0.0"))??0)/100, // Defaults to 0.5.
                      valueColor: AlwaysStoppedAnimation(Color(0xFFCA1212)), // Defaults to the current Theme's accentColor.
                      backgroundColor: Colors.grey.shade400, // Defaults to the current Theme's backgroundColor.
                      borderColor: Colors.grey.shade400,
                      borderWidth: 1.0,
                      borderRadius: 50.0,
                      direction: Axis.horizontal, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.horizontal.
                      center: Text("${currentEvent?.value??0}.0%"),
                    ),
                  ),
                ],
              ),
            ),
          )
              : const SizedBox(),
        ],
      );
      }),
    );
  }
}