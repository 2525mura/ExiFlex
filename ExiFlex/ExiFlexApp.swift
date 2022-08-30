//
//  ExiFlexApp.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/01/06.
//

import SwiftUI

@main
struct ExiFlexApp: App {
    
    let persistenceController = PersistenceController.shared
    // AppDelegateと接続するアダプタを宣言
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RootView().environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
