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
    @State private var showingModal = false
    @State private var isoValue: String = "100"
    @State private var fValue: String = "2.8"
    @State private var ssValue: String = "125"
    
    var body: some View {
        // memo: 縦画面の場合、第一階層はVStackにするとレイアウトが整いやすい
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
            HStack {
                if viewModel.dEv >= 0.5 {
                    Text("▶︎")
                        .foregroundColor(.pink)
                        .font(.system(size: 30))
                } else {
                    Text("▶︎")
                        .foregroundColor(.gray)
                        .font(.system(size: 30))
                }
                if viewModel.dEv > -1.0 && viewModel.dEv < 1.0 {
                    Text("●")
                        .foregroundColor(.green)
                        .font(.system(size: 15))
                } else {
                    Text("●")
                        .foregroundColor(.gray)
                        .font(.system(size: 15))
                }
                if viewModel.dEv <= -0.5 {
                    Text("◀︎")
                        .foregroundColor(.pink)
                        .font(.system(size: 30))
                } else {
                    Text("◀︎")
                        .foregroundColor(.gray)
                        .font(.system(size: 30))
                }
            }.padding(.top, 10)
            
            if viewModel.dEv <= -1.0 {
                Text("露出アンダーです")
            } else if viewModel.dEv > -1.0 && viewModel.dEv < 1.0 {
                Text("適正露出です")
            } else if viewModel.dEv >= 1.0 {
                Text("露出オーバーです")
            }
            LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                // カラム数の指定
                Text("ISO")
                Text("F num")
                Text("SS")
                Picker(selection: self.$isoValue, label: Text("")) {
                    Text("50").tag("50")
                    Text("100").tag("100")
                    Text("200").tag("200")
                    Text("400").tag("400")
                    Text("800").tag("800")
                }.onChange(of: self.isoValue) { newValue in
                    self.viewModel.onChangeEv(isoValue: newValue, fValue: self.fValue, ssValue: self.ssValue)
                }.frame(width: 100, height: 150).clipped()
                Picker(selection: self.$fValue, label: Text("")) {
                    Text("1.4").tag("1.4")
                    Text("2").tag("2")
                    Text("2.8").tag("2.8")
                    Text("4").tag("4")
                    Text("5.6").tag("5.6")
                    Text("8").tag("8")
                    Text("11").tag("11")
                    Text("16").tag("16")
                }.onChange(of: self.fValue) { newValue in
                    self.viewModel.onChangeEv(isoValue: self.isoValue, fValue: newValue, ssValue: self.ssValue)
                }.frame(width: 100, height: 150).clipped()
                Picker(selection: self.$ssValue, label: Text("")) {
                    Text("1").tag("1")
                    Text("2").tag("2")
                    Text("4").tag("4")
                    Text("8").tag("8")
                    Text("15").tag("15")
                    Text("30").tag("30")
                    Text("60").tag("60")
                    Text("125").tag("125")
                    Text("250").tag("250")
                    Text("500").tag("500")
                }.onChange(of: self.ssValue) { newValue in
                    self.viewModel.onChangeEv(isoValue: self.isoValue, fValue: self.fValue, ssValue: newValue)
                }.frame(width: 100, height: 150).clipped()
            }
            Spacer()
            ScrollViewReader { render in
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(self.viewModel.takeMetas) { takeMetaViewModel in
                            TakeMetaView(viewModel: takeMetaViewModel)
                        }
                    }
                }.onChange(of: self.viewModel.lastId) { id in
                    withAnimation {
                        render.scrollTo(id)
                    }
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