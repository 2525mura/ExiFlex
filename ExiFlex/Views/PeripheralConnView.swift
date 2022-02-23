//
//  PeripheralConnView.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/01/10.
//

import SwiftUI

struct PeripheralConnView: View {
    
    @ObservedObject private(set) var viewModel: PeripheralConnViewModel
    
    var body: some View {
        VStack() {
            Text("接続デバイス：\(viewModel.peripheralName ?? "N/A")").frame(height:20)
            Text("UUID：\(viewModel.peripheralUuid)").frame(height:20)
            Text("シャッター回数：\(viewModel.shutterCount)").frame(height:20)
            Spacer()
        }.navigationBarTitle(viewModel.peripheralName ?? "N/A")
    }
}

struct PeripheralConnView_Previews: PreviewProvider {
    static var previews: some View {
        PeripheralConnView(viewModel: .init(peripheralUuid: "uuid",
                                            peripheralName: "N/A",
                                            bleService: .init()))
    }
}
