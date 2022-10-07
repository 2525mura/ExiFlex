//
//  AlbumView.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/08/17.
//

import SwiftUI

struct AlbumView: View {
    
    @ObservedObject private(set) var viewModel: AlbumViewModel
    @Environment(\.managedObjectContext) var viewContext
    @State private var showingModalFilm = false
    
    @FetchRequest(
        entity: Roll.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Roll.createdAt, ascending: true)],
        predicate: nil
    ) private var rolls: FetchedResults<Roll>
    
    var body: some View {
        
        VStack {
            GoogleMapsView(viewModel: self.viewModel.googleMapsViewModel).frame(height: 250)
            if self.viewModel.isFilmLoaded {
                Text(self.viewModel.selectedRoll!.rollName ?? "N/A")
                Button(action: {
                    self.viewModel.ejectFilm()
                }, label: {
                    Image(systemName: "eject.circle")
                })
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                        ForEach(self.viewModel.selectedRoll!.takeMetasList) { takeMeta in
                            TakeMetaArcView(viewModel: takeMeta)
                                .contentShape(Rectangle()).onTapGesture {
                                    self.viewModel.selectMarker(id: takeMeta.id!)
                            }
                        }
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
                        List(rolls) { roll in
                            HStack {
                                Text(roll.rollName!)
                                Spacer()
                            }.contentShape(Rectangle()).onTapGesture {
                                self.viewModel.setFilm(viewContext: viewContext, selectedRoll: roll)
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
        AlbumView(viewModel: AlbumViewModel()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewLayout(.sizeThatFits)
    }
}
