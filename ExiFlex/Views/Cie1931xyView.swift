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
            HStack {
                Text("\(viewModel.luxMonitor, specifier: "%.1f") lx").frame(width: 75)
                Text("CT: \(viewModel.colorTemp, specifier: "%.0f") K").frame(width: 100)
            }
            HStack {
                Text("X: \(viewModel.cieX, specifier: "%.0f")").frame(width: 75)
                Text("Y: \(viewModel.cieY, specifier: "%.0f")").frame(width: 75)
                Text("Z: \(viewModel.cieZ, specifier: "%.0f")").frame(width: 75)
                Text("IR1: \(viewModel.cieIR1, specifier: "%.0f")").frame(width: 75)
            }
            Image(uiImage: self.viewModel.plotImage)
                .resizable().aspectRatio(contentMode:.fit)
        }
    }
}

struct Cie1931xyView_Previews: PreviewProvider {
    static var previews: some View {
        Cie1931xyView(viewModel: Cie1931xyViewModel(bleCentral: BleCentral()))
            .previewLayout(.sizeThatFits)
    }
}
