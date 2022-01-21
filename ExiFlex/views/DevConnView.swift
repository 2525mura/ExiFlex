//
//  DevConnView.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/01/10.
//

import SwiftUI

struct DevConnView: View {
    
    let viewModel: DevConnViewModel
    
    var body: some View {
        VStack() {
            Text("接続デバイス：\(viewModel.connDevice ?? "N/A")").frame(height:20)
            Text("シャッター回数：\(viewModel.shutterCount)").frame(height:20)
            Spacer()
        }.navigationBarTitle(viewModel.connDevice ?? "N/A")
    }
}

struct DevConnView_Previews: PreviewProvider {
    static var previews: some View {
        DevConnView(viewModel: .init(connDevice: "my ble device"))
    }
}
