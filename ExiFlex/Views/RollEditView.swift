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
    @ObservedObject private(set) var viewModel: RollEditViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Text("フィルム名")
                TextField("フィルム名を入力してください", text: $viewModel.rollName)
                DatePicker(selection: $viewModel.createdAt, label: {Text("作成日")})
                
                Picker(selection: $viewModel.rollBrand,
                       label: Text("ブランド")) {
                    ForEach(viewModel.rollBrands, id: \.self) { brand in
                        Text(brand)
                    }
                }
                
                Button(action: {}) {
                    Text("確定")
                }
            }.navigationBarTitle("フィルム情報")
        }
    }
}

struct RollEditView_Previews: PreviewProvider {
    static var previews: some View {
        RollEditView(viewModel: RollEditViewModel(viewContext: NSManagedObjectContext(), roll: nil))
    }
}
