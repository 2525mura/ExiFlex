//
//  AppDelegate.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/08/08.
//

import Foundation
import GoogleMaps

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GMSServices.provideAPIKey("AIzaSyDkuDhBZ9aO9m_27qvN-cvw4Dg8eQkkdQY")
        return true
    }
}
