import UIKit
import Flutter
import GoogleMaps

import Firebase
import FirebaseAnalytics
import FirebaseMessaging

import AppsFlyerLib
import AppTrackingTransparency

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions:
      [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // AppsFlyer
    AppsFlyerLib.shared().appsFlyerDevKey = "xRGTsJR6oxkKskbJzu95hV"
    AppsFlyerLib.shared().appleAppID = "com.itrack.smstretching499566"
    AppsFlyerLib.shared().delegate = self
    AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)

    // Google Maps
    GMSServices.provideAPIKey("AIzaSyCVMlMklgY5YNPuxWJ_HE0TZqWlOMGtMO0")

    // Firebase
    FirebaseApp.configure()

    // Firebase Messaging
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .badge, .sound],
        completionHandler: {_, _ in }
      )
    } else {
      application.registerUserNotificationSettings(
        UIUserNotificationSettings(
          types: [.alert, .badge, .sound],
          categories: nil
        )
      )
    }
    application.registerForRemoteNotifications()
    Messaging.messaging().delegate = self
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: ["token": Messaging.messaging().fcmToken ?? ""]
    )

    GeneratedPluginRegistrant.register(with: self)
    return super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    if #available(iOS 14, *) {
      ATTrackingManager.requestTrackingAuthorization { (status) in }
    }

    // Start the SDK (start the IDFA timeout set above, for iOS 14 or later)
    AppsFlyerLib.shared().start()
  }

  override func application(
      _ application: UIApplication,
      didReceiveRemoteNotification userInfo: [AnyHashable : Any]
    ) {
    AppsFlyerLib.shared().handlePushNotification(userInfo)
  }

  override func application(
    _ application: UIApplication,
    open url: URL,
    sourceApplication: String?,
    annotation: Any
  ) -> Bool {
    AppsFlyerLib.shared().handleOpen(
      url,
      sourceApplication: sourceApplication,
      withAnnotation: annotation
    )
    return true
  }

  // Report Push Notification attribution data for re-engagements
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    AppsFlyerLib.shared().handleOpen(url, options: options)
    return true
  }

  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable : Any],
    fetchCompletionHandler completionHandler:
      @escaping (UIBackgroundFetchResult) -> Void
    ) {
    AppsFlyerLib.shared().handlePushNotification(userInfo)
  }

  // Reports app open from deep link for iOS 10 or later
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
    return true
  }
}

// MARK: AppsFlyerLibDelegate
extension AppDelegate: AppsFlyerLibDelegate {
  // Handle Organic/Non-organic installation
  func onConversionDataSuccess(_ installData: [AnyHashable: Any]) {
      print("onConversionDataSuccess data:")
      for (key, value) in installData {
          print(key, ":", value)
      }
      if let status = installData["af_status"] as? String {
          if (status == "Non-organic") {
              if let sourceID = installData["media_source"],
                  let campaign = installData["campaign"] {
                  print(
                    "This is a Non-Organic install. " +
                    "Media source: \(sourceID)  " +
                    "Campaign: \(campaign)"
                  )
              }
          } else {
              print("This is an organic install.")
          }
          if let is_first_launch = installData["is_first_launch"] as? Bool,
              is_first_launch {
              print("First Launch")
          } else {
              print("Not First Launch")
          }
      }
  }

  // Handle Deep Link
  func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
    print("onAppOpenAttribution data:")
    for (key, value) in attributionData {
      print(key, ":", value)
    }
  }

  func onAppOpenAttributionFailure(_ error: Error) {
    print(error)
  }

  func onConversionDataFail(_ error: Error) {
    print(error)
  }
}
