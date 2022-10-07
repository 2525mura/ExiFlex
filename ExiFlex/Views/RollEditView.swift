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
    @ObservedObject private(set) var viewModel: Roll
    let rollBrands = ["Fujifilm Provia100", "Fujifilm Velvia100"]
    
    var body: some View {
        NavigationView {
            Form {
                Text("フィルム名")
                TextField("フィルム名を入力してください", text: Binding($viewModel.rollName)!)
                DatePicker(selection: Binding($viewModel.createdAt)!, label: {Text("作成日")})
                
                Picker(selection: Binding($viewModel.rollBrand)!,
                       label: Text("ブランド")) {
                    ForEach(rollBrands, id: \.self) { brand in
                        Text(brand)
                    }
                }
                
                // Film typeを選択可能にする
                Button(action: {}) {
                    Text("確定")
                }
            }.navigationBarTitle("フィルム情報")
        }
    }
}

struct RollEditView_Previews: PreviewProvider {
    static var previews: some View {
        RollEditView(viewModel: Roll.example).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
