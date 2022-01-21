//
//  DevAdvListView.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/01/10.
//

import SwiftUI

struct DevAdvListView: View {
    
    @StateObject private var viewModel: DevAdvListViewModel = .init()
    
    var body: some View {
        NavigationView {
            List(self.viewModel.devices) { device in
                NavigationLink(
                    // タップ後に表示するビュー
                    destination: DevConnView(viewModel: viewModel.connectDevice(device: device)),
                    label: {
                        // リストに表示するビュー
                        DevAdvCardView(viewModel: device)
                    })
            }
            .navigationBarTitle("BLEデバイス一覧")
        }
    }
}


struct DevAdvListView_Previews: PreviewProvider {
    static var previews: some View {
        DevAdvListView()
    }
}
