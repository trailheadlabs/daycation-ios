//
//  AppDelegate.swift
//
//  Created by Ethan on 2/18/16.
//  Copyright © 2016 Ethan. All rights reserved.
//




import UIKit
import FBSDKCoreKit
import Fabric
import Crashlytics
import Haneke
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var viewController: UIViewController?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self, Answers.self])
        
        Shared.imageCache.removeAll()
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let navigationController = UINavigationController(rootViewController: EntryViewController())
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        let backgroundImage = UIImage(named:"DAYC_ORANGE_BOTTOM@3x.png")!.croppedImage(CGRect(x: 0, y: 0, w: UIScreen.mainScreen().bounds.w, h: 80))
        
        UITabBar.appearance().backgroundImage = backgroundImage
        UITabBar.appearance().shadowImage = nil
        //UITabBar.appearance().shadowImage = backgroundImage
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSFontAttributeName: UIFont(name:"Quicksand-Bold", size:11)!,NSForegroundColorAttributeName: UIColor.whiteColor()],
            forState: .Normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name:"Quicksand-Bold", size:14)!, NSForegroundColorAttributeName: UIColor(hexString: "#fff9e1")!], forState: UIControlState.Normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name:"Quicksand-Bold", size:14)!, NSForegroundColorAttributeName: UIColor(hexString: "#fff9e1")!], forState: UIControlState.Selected)
        let navBackgroundImage:UIImage! = UIImage(named: "backgroundNB.png")
        UINavigationBar.appearance().setBackgroundImage(backgroundImage!.croppedImage(CGRect(x: 0, y: 0, w: UIScreen.mainScreen().bounds.w, h: 80)), forBarMetrics: .Default)
        UINavigationBar.appearance().tintColor = UIColor(hexString: "#fff9e1")!
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name:"TrueNorthRoughBlack-Regular", size:26)!, NSForegroundColorAttributeName: UIColor(hexString: "#fcfbea")!]
        let cancelButtonAttributes: NSDictionary = [NSFontAttributeName: UIFont(name:"Quicksand-Bold", size:14)!, NSForegroundColorAttributeName: UIColor(hexString: "#fff9e1")!]
        // Remove the icon, which is located in the left view
        for familyName in UIFont.familyNames() {
            print("\n-- \(familyName) \n")
            for fontName in UIFont.fontNamesForFamilyName(familyName) {
                print(fontName)
            }
        }
        
        // Override point for customization after application launch.
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication,
                     openURL url: NSURL,
                             sourceApplication: String?,
                             annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            openURL: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}