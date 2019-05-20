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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        
        // check weather or not user is logged in and show the coresponding storyboard
        let Preferences = UserDefaults.standard
        var username = Preferences.string(forKey: "username")
        var password = Preferences.string(forKey: "password")
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController   = storyboard.instantiateViewController(withIdentifier: "MainView") as UIViewController
        let drawerViewController = storyboard.instantiateViewController(withIdentifier: "DrawerView") as UIViewController
        let drawerController     = KYDrawerController(drawerDirection: .left, drawerWidth: 300)
        drawerController.mainViewController = mainViewController
        drawerController.drawerViewController = drawerViewController
        
        if(username != nil && password != nil && username != "" && password != ""){ //if credentals are alredy stored go straight to main view
            window?.rootViewController = drawerController
            window?.makeKeyAndVisible()
        }else if Preferences.bool(forKey: "shouldUnregister"){ //if there are no credentuals stored and the user has not been unregistered from the notification server
            let sr = SendRequest()
            let dict = ["token":Preferences.string(forKey: "token")!,
                        "auth":"taappyrdsb123!",
                        "purpose":"delete",
                        ]
            let URL = "https://benjamintran.me/TeachassistAPI/"
            print(sr.SendJSON(url: URL, parameters: dict))
            Preferences.set(false, forKey: "shouldUnregister")
        }
        
        Preferences.synchronize()
        //setup notificaitons
        let options: UNAuthorizationOptions = [.alert, .sound];
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            if !granted {
                print("Notifications weremnot correctly registered")
                Preferences.set("false", forKey: "token")
                Preferences.synchronize()
                
            }else{
                print("NOTIFICATION PERMISSION GRANTED")
                UNUserNotificationCenter.current().getNotificationSettings{(settings) in
                    print(settings)
                    UIApplication.shared.registerForRemoteNotifications()
                    
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
        let Preferences = UserDefaults.standard
        Preferences.set("simulator token", forKey: "token")
        Preferences.synchronize()
    }


}

