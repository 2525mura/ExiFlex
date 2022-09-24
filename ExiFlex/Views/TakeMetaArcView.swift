//
//  TakeMetaArcView.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/09/13.
//

import SwiftUI

struct TakeMetaArcView: View {
    
    @ObservedObject private(set) var viewModel: TakeMeta
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            if self.viewModel.frameType == .leader {
                Image("film_leader").resizable().aspectRatio(contentMode:.fit).frame(width: 105)
                Spacer()
            } else if self.viewModel.frameType == .picture {
                Image("film_frame").resizable().aspectRatio(contentMode:.fill).frame(width: 105)
                    .overlay(
                        Text("\(self.viewModel.takeNo)").foregroundColor(.white).background(Color.blue).font(.subheadline),
                        alignment: .topTrailing
                    )
                    .overlay(
                        HStack {
                            Text("5000K").foregroundColor(.white).background(Color.gray).font(.caption2)
                            if viewModel.locationActive {
                                Text("🛰").font(.caption2)
                            }
                        }.padding(.bottom, 10),
                        alignment: .bottomTrailing
                    )
                    .overlay(
                        Text("ISO\(self.viewModel.isoValueUnwrap)").foregroundColor(.white).background(Color.gray).font(.caption2),
                        alignment: .topLeading
                    )
                Text("nnnn.jpg").font(.caption)
                Text(self.viewModel.takeDateStr).font(.caption)
                Text("F\(self.viewModel.fValueUnwrap) 1/\(self.viewModel.ssValueUnwrap)s").font(.caption)
            }
            
        }.frame(width: 105)
        
    }
}

struct TakeMetaArcView_Previews: PreviewProvider {
    static var previews: some View {
        TakeMetaArcView(viewModel: TakeMeta())
            .previewLayout(.sizeThatFits)
    }
}
