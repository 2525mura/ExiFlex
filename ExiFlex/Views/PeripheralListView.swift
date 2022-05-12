//
//  PeripheralListView.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/01/10.
//

import SwiftUI

struct PeripheralListView: View {
    
    @ObservedObject private(set) var viewModel: PeripheralListViewModel
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        VStack {
            Button(action: {
                self.viewModel.stopAdvertiseScan()
                self.presentation.wrappedValue.dismiss()
                self.viewModel.removeAllPeripherals()
            }, label: {
              Text("キャンセル")
            })
            NavigationView {
                List(self.viewModel.peripherals) { peripheral in
                    // ペリフェラルに接続する
                    Button(action: {
                        self.viewModel.disConnectPeripheralAll()
                        self.viewModel.connectPeripheral(peripheral: peripheral)
                        self.presentation.wrappedValue.dismiss()
                        self.viewModel.removeAllPeripherals()
                    }, label: {
                        PeripheralAdvCardView(viewModel: peripheral)
                    })
                }.navigationBarTitle("BLEデバイス一覧")
            }
        }
    }
}

struct PeripheralListView_Previews: PreviewProvider {
    static var previews: some View {
        PeripheralListView(viewModel: PeripheralListViewModel(bleService: BleService()))
    }
}
