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
            Text("タイトル").lineLimit(1)
            Divider()
            HStack {
                VStack {
                    Text("被写体")
                    Text("名無しさん")
                }
                Spacer()
                VStack {
                    Text("TAKE").padding(.trailing, 20)
                    Text("\(self.viewModel.takeCount)/36").padding(.trailing, 20)
                }
                Spacer()
                VStack {
                    Text("ROLL")
                    Text("0054111")
                }
            }
            Divider()
            HStack {
                Text("撮影情報").padding(.trailing, 10)
                Text("ISO\(self.viewModel.isoValue)")
                Text("F\(self.viewModel.fValue)").padding(.trailing, 10)
                Text("1/\(self.viewModel.ssValue)s").padding(.trailing, 10)
                Spacer()
            }
            Divider()
            HStack {
                Text("日付").padding(.trailing, 10)
                Text(self.viewModel.takeDateStr).padding(.trailing, 10)
                Spacer()
                Text("✨")
                Text("🛰")
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
            viewModel: TakeMetaViewModel(isoValue: "100", fValue: "2.8", ssValue: "125", takeCount: 0)
        ).previewLayout(.sizeThatFits)
    }
}
