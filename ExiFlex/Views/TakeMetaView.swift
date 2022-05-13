//
//  TakeMetaView.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/03/11.
//

import SwiftUI

struct TakeMetaView: View {
    
    @ObservedObject private(set) var viewModel: TakeMetaViewModel
    
    var body: some View {
        
        // テキストを主役に背景を合わせる
        VStack {
            HStack {
                Text("Title.").padding(.trailing, 10)
                Text("アコスタさいたまスーパーアリーナ").lineLimit(1)
                Spacer()
            }
            Divider()
            HStack {
                VStack {
                    Text("SCENE")
                    Text("1")
                }
                Spacer()
                VStack {
                    Text("TAKE")
                    Text("1")
                }
                Spacer()
                VStack {
                    Text("ROLL")
                    Text("1")
                }
            }
            Divider()
            HStack {
                Text("CAMERA").padding(.trailing, 10)
                Text("1/\(self.viewModel.ssValue)s").padding(.trailing, 10)
                Text("F\(self.viewModel.fValue)").padding(.trailing, 10)
                Text("ISO\(self.viewModel.isoValue)")
                Spacer()
            }
            Divider()
            HStack {
                Text("DATE").padding(.trailing, 10)
                Text("2022/03/21").padding(.trailing, 10)
                Spacer()
                Text("GPS ON")
            }.padding(.vertical, 2)
        }.padding(.horizontal, 20)
            .padding(.vertical, 50)
            .frame(width:320, height:240)
            .background(Image("film_frame")
                            .resizable()
                            .aspectRatio(contentMode:.fill))
    }
}

struct TakeMetaView_Previews: PreviewProvider {
    static var previews: some View {
        TakeMetaView(
            viewModel: TakeMetaViewModel(isoValue: "100", fValue: "2.8", ssValue: "125")
        ).previewLayout(.sizeThatFits)
    }
}
