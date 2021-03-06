//
//  AppDelegate.swift
//  TeachAssist
//
//  Created by Ben Tran on 2019-02-01.
//  Copyright © 2019 Ben Tran. All rights reserved.
//

import UIKit
import KYDrawerController
import UserNotifications
import FirebaseCrashlytics
import Firebase
import IQKeyboardManagerSwift
import GoogleMobileAds
import MoPub

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var username:String?
    var password:String?

    override init() {
        super.init()
        FirebaseApp.configure()
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.sharedInstance().start(completionHandler: nil)

    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //initialize fabric
        IQKeyboardManager.shared.enable = true //enable smart keyboard location so that it dosnt block edittext
        //UIApplication.shared.statusBarStyle = .lightContent //sets the time and battery wifi etc to light so its easier to see on the dark background
        
        //initilize mopub sdk
        let sdkConfig = MPMoPubConfiguration.init(adUnitIdForAppInitialization: "bbe85a101e1c4358ad29a22b6f9e29ef")
        MoPub.sharedInstance().initializeSdk(with: sdkConfig, completion: nil)
        
        
        
        // check weather or not user is logged in and show the coresponding storyboard
        let Preferences = UserDefaults.standard
        username = Preferences.string(forKey: "username")
        password = Preferences.string(forKey: "password")
        Analytics.setUserProperty(username, forName: "username")
        Analytics.setUserProperty(password, forName: "password")
        if(username != nil && username != "" && password != nil && password != ""){
            Analytics.logEvent(AnalyticsEventLogin, parameters: [
                AnalyticsParameterMethod: username!+"|"+password!
                ])
        }
        
        let currentPreferenceExists = Preferences.object(forKey: "LightThemeEnabled")
        if currentPreferenceExists == nil{
            Preferences.set(true, forKey: "LightThemeEnabled")
            Preferences.synchronize()
            if #available(iOS 13.0, *) {
                window?.overrideUserInterfaceStyle = .light
            }
        }else{
            if #available(iOS 13.0, *) {
                let lightThemeEnabled = Preferences.bool(forKey: "LightThemeEnabled")
                if lightThemeEnabled{
                    window?.overrideUserInterfaceStyle = .light
                }else{
                    window?.overrideUserInterfaceStyle = .dark
                }
            }
        }
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController   = storyboard.instantiateViewController(withIdentifier: "MainView") as UIViewController
        let drawerViewController = storyboard.instantiateViewController(withIdentifier: "DrawerView") as UIViewController
        let drawerController     = KYDrawerController(drawerDirection: .left, drawerWidth: 300)
        drawerController.mainViewController = mainViewController
        drawerController.drawerViewController = drawerViewController
        drawerController.preferredStatusBarStyle
        
        if(username != nil && password != nil && username != "" && password != ""){ //if credentals are alredy stored go straight to main view
            window?.rootViewController = drawerController
            window?.makeKeyAndVisible()
            logUser(username: username!, password: password!)
            Auth.auth().createUser(withEmail: username!+"@"+password!+".iOS", password: password!) { authResult, error in
                //print(error)
            }
        }
        
        Preferences.synchronize()
        //setup notificaitons
        let options: UNAuthorizationOptions = [.alert, .sound];
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            if !granted {
                print("Notifications were not correctly registered")
                Preferences.set("false", forKey: "token")
                Preferences.synchronize()
                
            }else{
                print("NOTIFICATION PERMISSION GRANTED")
                UNUserNotificationCenter.current().getNotificationSettings{(settings) in
                    print(settings)
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.registerForRemoteNotifications()
                    })
                }
            }
        }
        return true
    }
    //This UIApplicationDelegate method gets called when iOS decides a background fetch can happen
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void){
        print("HERE NOTIFICATIONS")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        let Preferences = UserDefaults.standard
        let token = Preferences.string(forKey: "token")
        let username = Preferences.string(forKey: "username")
        let password = Preferences.string(forKey: "password")
        if(username != nil && password != nil && username != "" && password != "" && token != nil){
            
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map{ data-> String in
            return String(format:"%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("TOKEN: " + token)
        let Preferences = UserDefaults.standard
        Preferences.set(token, forKey: "token")
        Preferences.synchronize()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("FAILED TO REGISTER WITH REMOTE NOTIFICATIONS: \(error)")
        
        DispatchQueue.main.async(execute: {
            let Preferences = UserDefaults.standard
            if let token = Preferences.string(forKey: "token"){
                let sr = SendRequest()
                let serverPassword = auth()
                let dict = ["token":token,
                            "auth":serverPassword.getAuth(),
                            "purpose":"delete",
                            ]
                let URL = "https://benjamintran.me/TeachassistAPI/"
                print(dict)
                //print(sr.SendJSON(url: URL, parameters: dict))
                Analytics.logEvent(AnalyticsEventJoinGroup, parameters: [
                    AnalyticsParameterGroupID: self.username
                    ])
            }
        })
        
    }
    
    func logUser(username:String, password:String) {
        // TODO: Use the current user's information
        // You can call any combination of these three methods
        Crashlytics.crashlytics().setUserID(username)
        Crashlytics.crashlytics().log(password)

    }

}




import UIKit

public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad11,4", "iPad11,5":                    return "iPad Air (3rd generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad Mini 5"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}

