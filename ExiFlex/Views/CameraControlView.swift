//
//  CameraControlView.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/03/09.
//

import SwiftUI

struct CameraControlView: View {
    
    @State private var selectionValue = 0
    
    var body: some View {
        VStack {
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
            }
            Text("露出オーバーです")

            LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                // カラム数の指定
                Text("ISO")
                Text("Exp")
                Text("SS")
                Picker(selection: $selectionValue, label: Text("")) {
                    Text("50").tag(50)
                    Text("100").tag(100)
                    Text("200").tag(200)
                    Text("400").tag(400)
                    Text("800").tag(800)
                }.frame(width: 100, height: 100)
                    .clipped()
                    //.pickerStyle(WheelPickerStyle())
                Picker(selection: $selectionValue, label: Text("")) {
                    Text("1.4").tag(50)
                    Text("2").tag(100)
                    Text("2.8").tag(200)
                    Text("4").tag(400)
                    Text("5.6").tag(800)
                }.frame(width: 100, height: 100)
                    .clipped()
                    //.pickerStyle(WheelPickerStyle())
            }
            
            
            ScrollView(.horizontal) {
                HStack {
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
