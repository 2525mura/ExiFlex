//
//  AlbumView.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/08/17.
//

import SwiftUI

struct AlbumView: View {
    
    @ObservedObject private(set) var viewModel: AlbumViewModel
    @State private var showingModalFilm = false
    
    var body: some View {
        
        VStack {
            GoogleMapsView(viewModel: viewModel.googleMapsViewModel)            
            if self.viewModel.isFilmLoaded {
                Button(action: {
                    self.viewModel.ejectFilm()
                }, label: {
                    Image(systemName: "eject.circle")
                })
                ScrollViewReader { render in
                    ScrollView(.horizontal) {
                        LazyHStack(alignment: .top) {
                            ForEach(self.viewModel.selectedRoll.takeMetaViewModels) { takeMetaViewModel in
                                TakeMetaView(viewModel: takeMetaViewModel)
                            }
                        }.frame(maxHeight: 250)
                    }
                }
            } else {
                Button(action: {
                    self.showingModalFilm.toggle()
                }, label: {
                    Image("album_seiri").resizable()
                        .aspectRatio(contentMode:.fill).frame(width:320, height:240)
                }).sheet(isPresented: $showingModalFilm) {
                    NavigationView {
                        List(self.viewModel.rollViewModels) { roll in
                            
                            HStack {
                                Text(roll.rollName)
                                Spacer()
                            }.contentShape(Rectangle()).onTapGesture {
                                self.viewModel.setFilm(selectedRoll: roll)
                                self.showingModalFilm = false
                            }
                            
                        }.navigationBarTitle("アルバム棚")
                    }
                }
            }
        }
    }
}

struct AlbumView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumView(viewModel: AlbumViewModel())
            .previewLayout(.sizeThatFits)
    }
}
