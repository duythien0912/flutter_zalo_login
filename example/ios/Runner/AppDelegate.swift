import UIKit
import Flutter
import ZaloSDK

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    open url: URL,
    sourceApplication: String?,
    annotation: Any
  ) -> Bool {
    print("Hello Swift")
    print(sourceApplication)

    return ZDKApplicationDelegate.sharedInstance().application(application,
        open: url,
        sourceApplication: sourceApplication,
        annotation: annotation
    )
  }

    @available(iOS 9.0, *)
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        return ZDKApplicationDelegate
            .sharedInstance()
            .application(app,
                            open: url as URL?,
                            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?,
                            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        return false
    }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
