//
//  TakeMetaView.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/03/11.
//

import SwiftUI

struct TakeMetaView: View {
    
    @ObservedObject private(set) var viewModel: TakeMeta
    
    var body: some View {
        
        // テキストを主役に背景を合わせる
        if self.viewModel.isLeader {
            Image("film_leader").resizable().frame(width:320, height:240)
                .aspectRatio(contentMode:.fill).padding(.leading, 50)
        } else {
            VStack {
                Spacer().frame(height: 25)
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
                        Text("\(self.viewModel.takeNo)/36").padding(.trailing, 20)
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
                    Text("ISO\(self.viewModel.isoValueUnwrap)")
                    Text("F\(self.viewModel.fValueUnwrap)").padding(.trailing, 10)
                    Text("1/\(self.viewModel.ssValueUnwrap)s").padding(.trailing, 10)
                    Spacer()
                }
                Divider()
                HStack {
                    Text("日付").padding(.trailing, 10)
                    Text(self.viewModel.takeDateStr).padding(.trailing, 10)
                    Spacer()
                    Text("🛰")
                }
                Spacer().frame(height: 12)
                HStack {
                    Text("\(self.viewModel.takeNo, specifier: "%02d")").font(.caption).foregroundColor(.white).padding(.leading, 2.5)
                    Spacer()
                }
            }.padding(.horizontal, 20)
                .frame(width:320, height:240)
                .background(Image("film_frame")
                                .resizable()
                                .aspectRatio(contentMode:.fill))
        }
    }
}

/*
struct TakeMetaView_Previews: PreviewProvider {
    static var previews: some View {
        TakeMetaView(
            viewModel: TakeMetaViewModel(refRoll: RollViewModel(rollName: "myRoll"), isoValue: "100", fValue: "2.8", ssValue: "125", takeCount: 0)
        ).previewLayout(.sizeThatFits)
    }
}
*/
