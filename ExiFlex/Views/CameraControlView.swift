//
//  CameraControlView.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/03/09.
//

import SwiftUI

struct CameraControlView: View {
    // 参照型のViewModelの場合は、ObservableObjectサブクラスのインスタンスを代入する
    // 自身のViewでインスタンス生成して代入する場合はStateObject、親Viewから貰う場合はObservedObject
    @StateObject private var viewModel: CameraControlViewModel = CameraControlViewModel()
    @State private var isoValue = 100
    @State private var fValue = 28
    @State private var ssValue = 125
    @State private var showingModal = false
    
    var body: some View {
        // memo: 縦画面の場合、第一階層はVStackにするとレイアウトが整いやすい
        VStack {
            HStack {
                // memo: Spacer()は、VStack, HStackに1個だけ入れるとレイアウトが整う
                Spacer()
                Text("BLE 接続成功")
                Button(action: {
                    self.showingModal.toggle()
                }) {
                    Image(systemName: "antenna.radiowaves.left.and.right").padding(.trailing, 10)
                }.sheet(isPresented: $showingModal) {
                    PeripheralListView(viewModel: viewModel.peripheralListVm)
                }
            }
            HStack {
                Text("◀︎")
                    .foregroundColor(.gray)
                    .font(.system(size: 30))
                Text("●")
                    .foregroundColor(.gray)
                    .font(.system(size: 15))
                    .padding(.horizontal, 15)
                Text("▶︎")
                    .foregroundColor(.gray)
                    .font(.system(size: 30))
            }.padding(.top, 10)
            Text("露出オーバーです")
            LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                // カラム数の指定
                Text("ISO")
                Text("F num")
                Text("SS")
                Picker(selection: $isoValue, label: Text("")) {
                    Text("50").tag(50)
                    Text("100").tag(100)
                    Text("200").tag(200)
                    Text("400").tag(400)
                    Text("800").tag(800)
                }.frame(width: 100, height: 150).clipped()
                Picker(selection: $fValue, label: Text("")) {
                    Text("1.4").tag(14)
                    Text("2").tag(20)
                    Text("2.8").tag(28)
                    Text("4").tag(40)
                    Text("5.6").tag(56)
                    Text("8").tag(80)
                    Text("11").tag(110)
                    Text("16").tag(160)
                }.frame(width: 100, height: 150).clipped()
                Picker(selection: $ssValue, label: Text("")) {
                    Text("1").tag(1)
                    Text("2").tag(2)
                    Text("4").tag(4)
                    Text("8").tag(8)
                    Text("15").tag(15)
                    Text("30").tag(30)
                    Text("60").tag(60)
                    Text("125").tag(125)
                    Text("250").tag(250)
                    Text("500").tag(500)
                }.frame(width: 100, height: 150).clipped()
            }
            Spacer()
            ScrollView(.horizontal) {
                LazyHStack {
                    TakeMetaView()
                    TakeMetaView()
                    TakeMetaView()
                }
                
            }
        }
    }
}

struct CameraControlView_Previews: PreviewProvider {
    static var previews: some View {
        CameraControlView()
    }
}
