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
            PeripheralListView()
                .tabItem {
                    Image(systemName: "personalhotspot")
                    Text("Connect")
                }
            Text("Settings Page")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .underline()
                .tabItem {
                    Image(systemName: "film")
                    Text("My Memory")
                }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
