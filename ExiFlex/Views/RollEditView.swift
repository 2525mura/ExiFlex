//
//  RollEditView.swift
//  ExiFlex
//
//  Created by mac on 2022/10/02.
//

import SwiftUI
import CoreData

struct RollEditView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentation
    @ObservedObject private(set) var viewModel: RollEditViewModel
    let rollBrands = ["Fujifilm Provia100", "Fujifilm Velvia100"]
    let onOk: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Text("フィルム名")
                TextField("フィルム名を入力してください", text: $viewModel.rollName)
                DatePicker(selection: $viewModel.createdAt, label: {Text("作成日")})
                
                Picker(selection: $viewModel.rollBrand,
                       label: Text("ブランド")) {
                    ForEach(rollBrands, id: \.self) { brand in
                        Text(brand)
                    }
                }
                // Enumをリスト表示
                Picker(selection: $viewModel.rollType, label: Text("フィルムタイプ")) {
                    ForEach(RollType.allCases, id: \.self) { rollType in
                        // rollTypeはRollType型、rollType.rawValueはString型
                        // selectionに渡される値は、前者のRollType型の決定値
                        Text(rollType.rawValue).tag(rollType)
                    }
                }
                // Film typeを選択可能にする
                Button(action: {
                    self.viewModel.save(viewContext: viewContext)
                    self.presentation.wrappedValue.dismiss()
                    self.onOk()
                }) {
                    Text("確定")
                }
            }.navigationBarTitle("フィルム情報")
        }
    }
}

struct RollEditView_Previews: PreviewProvider {
    static var previews: some View {
        RollEditView(viewModel: RollEditViewModel(), onOk: {}).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
