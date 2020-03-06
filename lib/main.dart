import 'dart:io';

import 'package:flutter/material.dart';
import 'routes.dart';
import 'package:firebase_admob/firebase_admob.dart';

void main() {
  runApp(new MyApp());
  FirebaseAdMob.instance
      .initialize(appId: 'ca-app-pub-5432103368789181~7906936997');
}

class MyApp extends StatelessWidget {
  static final String testAppId = Platform.isAndroid
      ? 'ca-app-pub-5432103368789181~7906936997'
      : 'ca-app-pub-3940256099942544~1458002511';
  @override
  Widget build(BuildContext context) {
    MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
      keywords: <String>['flutterio', 'beautiful apps'],
      contentUrl: 'https://flutter.cn',
      childDirected: false,

      testDevices: <String>[
        'DB7B496BF5B9C480',
        'F8724BFB964B9C18BEA5A9935A4249CF'
      ], // Android emulators are considered test devices
    );

    BannerAd myBanner = BannerAd(
      // Replace the testAdUnitId with an ad unit id from the AdMob dash.
      // https://developers.google.com/admob/android/test-ads
      // https://developers.google.com/admob/ios/test-ads
      adUnitId: 'ca-app-pub-5432103368789181/2790341687', //BannerAd.testAdUnitId,
      size: AdSize.smartBanner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event is $event");
      },
    );
    
InterstitialAd myInterstitial = InterstitialAd(
  // Replace the testAdUnitId with an ad unit id from the AdMob dash.
  // https://developers.google.com/admob/android/test-ads
  // https://developers.google.com/admob/ios/test-ads
  adUnitId: InterstitialAd.testAdUnitId,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("InterstitialAd event is $event");
  },
);
    myBanner
      // typically this happens well before the ad is shown
      ..load()
      ..show(
        // Positions the banner ad 60 pixels from the bottom of the screen
        anchorOffset: 0.0,
        // Positions the banner ad 10 pixels from the center of the screen to the right
        //horizontalCenterOffset: 10.0,
        // Banner Position
        anchorType: AnchorType.bottom,
      );
myInterstitial
  ..load()
  ..show(
    anchorType: AnchorType.bottom,
    anchorOffset: 0.0,
    horizontalCenterOffset: 0.0,
  );
    return new MaterialApp(
      title: 'Flutter login demo',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: new RootPage(auth: new Auth()));
      initialRoute: '/',
      routes: routes,
    );
  }
}
