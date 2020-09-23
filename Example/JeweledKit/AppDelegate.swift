//
//  AppDelegate.swift
//  JeweledKit
//
//  Created by cool-jeweled-moon on 09/06/2020.
//  Copyright (c) 2020 cool-jeweled-moon. All rights reserved.
//

import UIKit
import JeweledKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
}

class ViewController: UIViewController {
    
}
