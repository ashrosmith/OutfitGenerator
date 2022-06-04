//
//  AppDelegate.swift
//  OutfitGenerator
//
//  Created by Ashley Smith on 2/18/22.
//

import UIKit
@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let defaults = UserDefaults.standard
        let prefs = Bundle.main.path(forResource: "Defaults", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: prefs!)
        defaults.set(dict, forKey: "defaults")
        defaults.register(defaults: dict as! [String : AnyObject])
        defaults.synchronize()
  
        return true
    }


}

