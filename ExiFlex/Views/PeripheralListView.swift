//
//  PeripheralListView.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/01/10.
//

import SwiftUI

struct PeripheralListView: View {
    
    // 代入出来るインスタンスはObservableObject継承クラスのインスタンス
    @StateObject private var viewModel: PeripheralListViewModel = PeripheralListViewModel()
    
    var body: some View {
        NavigationView {
            List(self.viewModel.devices) { device in
                NavigationLink(
                    // タップ後に表示するビュー。リストに表示するビューと一緒に生成される。
                    // タップ後に生成されるわけではない。
                    destination: PeripheralConnView(
                        viewModel: device.connViewModel).onAppear {
                        viewModel.connectDevice(device: device)
                    }.onDisappear {
                        print("DisAppear")
                    },
                    label: {
                        // リストに表示するビュー
                        PeripheralAdvCardView(viewModel: device)
                    }
                )
            }
            .navigationBarTitle("BLEデバイス一覧")
        }
    }
}

struct PeripheralListView_Previews: PreviewProvider {
    static var previews: some View {
        PeripheralListView()
    }
}
