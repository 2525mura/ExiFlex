//
//  Cie1931xyView.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/06/28.
//

import SwiftUI

struct Cie1931xyView: View {
    
    @ObservedObject private(set) var viewModel: Cie1931xyViewModel
    
    var body: some View {
        Image(uiImage: self.viewModel.plotImage)
            .resizable().aspectRatio(contentMode:.fit)
    }
}

struct Cie1931xyView_Previews: PreviewProvider {
    static var previews: some View {
        Cie1931xyView(viewModel: Cie1931xyViewModel())
            .previewLayout(.sizeThatFits)
    }
}
