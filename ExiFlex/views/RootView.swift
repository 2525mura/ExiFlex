//
//  RootView.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/01/06.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            DevAdvListView()
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("BLE List")
                }
            Text("Settings Page")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .underline()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}

