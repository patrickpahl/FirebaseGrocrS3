//
//  AppDelegate.swift
//  FirebaseGrocrS3
//
//  Created by Patrick Pahl on 10/22/16.
//  Copyright © 2016 Patrick Pahl. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.statusBarStyle = .lightContent
        FIRApp.configure()
        //Offline data persistense!!
        FIRDatabase.database().persistenceEnabled = true
        
        return true
    }

}
