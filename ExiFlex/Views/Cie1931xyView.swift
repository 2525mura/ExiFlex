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
        VStack {
            Text("\(viewModel.luxMonitor, specifier: "%.1f") lx")
            HStack {
                Text("X: \(viewModel.cieX, specifier: "%.1f")").padding()
                Text("Y: \(viewModel.cieY, specifier: "%.1f")").padding()
                Text("Z: \(viewModel.cieZ, specifier: "%.1f")").padding()
            }
            Image(uiImage: self.viewModel.plotImage)
                .resizable().aspectRatio(contentMode:.fit)
        }
    }
}

struct Cie1931xyView_Previews: PreviewProvider {
    static var previews: some View {
        Cie1931xyView(viewModel: Cie1931xyViewModel(bleService: BleService()))
            .previewLayout(.sizeThatFits)
    }
}
