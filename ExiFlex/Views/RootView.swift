//
//  RootView.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/01/06.
//

import SwiftUI

struct RootView: View {
    
    @StateObject private var viewModel: RootViewModel = RootViewModel()
    @State private var showingModal = false
    
    var body: some View {
        VStack {
            HStack {
                // memo: Spacer()は、VStack, HStackに1個だけ入れるとレイアウトが整う
                Spacer()
                Text("BLE 接続成功")
                Button(action: {
                    self.showingModal.toggle()
                    // TrueならAdvertiseスキャンを開始する
                    if self.showingModal {
                        self.viewModel.startAdvertiseScan()
                    }
                }, label: {
                    Image(systemName: "antenna.radiowaves.left.and.right").padding(.trailing, 10)
                }).sheet(isPresented: $showingModal) {
                    PeripheralListView(viewModel: viewModel.peripheralListVm)
                }
            }
            TabView {
                CameraControlView(viewModel: viewModel.cameraControlViewModel)
                    .tabItem {
                        Image(systemName: "film")
                        Text("Take")
                    }
                Cie1931xyView(viewModel: viewModel.cie1931xyViewModel)
                    .tabItem {
                        Image(systemName: "cloud.sun")
                        Text("Light Meter")
                    }
                AlbumView(viewModel: viewModel.albumViewModel)
                    .tabItem {
                        Image(systemName: "books.vertical")
                        Text("Album")
                    }
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
