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
    @ObservedObject private(set) var viewModel: CameraControlViewModel
    @Environment(\.managedObjectContext) var viewContext
    @State private var isoValue: String = "100"
    @State private var showingModalRoll = false
    
    @FetchRequest(
        entity: Roll.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Roll.createdAt, ascending: true)],
        predicate: nil
    ) private var rolls: FetchedResults<Roll>
    
    var body: some View {
        VStack {
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
                                    self.viewModel.onChangeIso(isoValue: newValue)
                                }.frame(width: 100, height: 150).clipped()
                Text(viewModel.fValue).font(.system(size: 40, weight:.bold, design:.rounded)).foregroundColor(.blue)
                Text(viewModel.ssValue).font(.system(size: 40, weight:.bold, design:.rounded)).foregroundColor(.blue)
            }
            Spacer()
            if self.viewModel.isFilmLoaded {
                Button(action: {
                    self.viewModel.ejectFilm()
                }, label: {
                    Image(systemName: "eject.circle")
                })
                ScrollViewReader { render in
                    ScrollView(.horizontal) {
                        LazyHStack(alignment: .top) {
                            ForEach(self.viewModel.selectedRoll!.takeMetasList) { takeMeta in
                                TakeMetaView(viewModel: takeMeta).id(takeMeta.id)
                            }
                        }.frame(maxHeight: 250)
                    }.onChange(of: self.viewModel.lastId) { id in
                        withAnimation {
                            render.scrollTo(id)
                        }
                    }
                }
            } else {
                Button(action: {
                    self.showingModalRoll = true
                }, label: {
                    Image("film_set").resizable()
                        .aspectRatio(contentMode:.fill).frame(width:320, height:240)
                }).sheet(isPresented: $showingModalRoll, onDismiss: {
                    self.viewModel.modalRollState = .selectFilm
                }) {
                    
                    if self.viewModel.modalRollState == .selectFilm {
                        VStack {
                            Button(action: {
                                self.viewModel.tmpRollInit()
                            }, label: {
                                Text("フィルム追加")
                            })
                            NavigationView {
                                List {
                                    ForEach(rolls) { roll in
                                        HStack {
                                            Text(roll.rollName!)
                                            Spacer()
                                        }.contentShape(Rectangle()).onTapGesture {
                                            self.viewModel.setFilm(viewContext: viewContext, selectedRoll: roll)
                                            self.showingModalRoll = false
                                        }
                                    }
                                    .onDelete { (offsets) in
                                        for index in offsets {
                                            let delRoll = rolls[index]
                                            viewContext.delete(delRoll)
                                        }
                                        do {
                                            try viewContext.save()
                                        } catch {
                                            // handle the Core Data error
                                        }
                                    }
                                }.navigationBarTitle("フィルム棚")
                            }
                        }
                    } else if self.viewModel.modalRollState == .createFilm {
                        RollEditView(viewModel: viewModel.rollEditViewModel!, onOk: {
                            // 保存
                            self.viewModel.tmpRollSave()
                        })
                    }
                }
            }
        }
    }
}

struct CameraControlView_Previews: PreviewProvider {
    static var previews: some View {
        CameraControlView(viewModel: CameraControlViewModel(bleCentral: BleCentral(), locationService: LocationService())).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
