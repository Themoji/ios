//
//  AppDelegate.swift
//  EmojiCommunicationsInc
//
//  Created by Felix Krause on 05/01/16.
//  Copyright © 2016 Felix Krause. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.applicationSupportsShakeToEdit = false

        Fabric.with([Crashlytics.self])
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let url = url.standardized
        let emoji = url.absoluteString.components(separatedBy: "/").last
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ShowEmoji"), object: emoji)
        
        return true
    }
}

