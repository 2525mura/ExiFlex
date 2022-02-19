//
//  PeripheralAdvCardView.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/01/06.
//

import SwiftUI

struct PeripheralAdvCardView: View {

    let viewModel: PeripheralAdvViewModel

    var body: some View {
        HStack {
            VStack {
                if viewModel.state == .adLost {
                    Text(viewModel.peripheralName ?? "Unnamed")
                        .foregroundColor(.gray)
                        .font(.title)
                        .fontWeight(.bold)
                } else {
                    Text(viewModel.peripheralName ?? "Unnamed")
                        .foregroundColor(.black)
                        .font(.title)
                        .fontWeight(.bold)
                }
                Text(viewModel.peripheralUuid)
                    .foregroundColor(.gray)
                    .font(.footnote)
            }
            Spacer()
            VStack {
                if viewModel.state == .adLost {
                    Image(uiImage: UIImage(named: "ble_pow_0")!)
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 33, height: 27)
                    Text("N/A")
                        .foregroundColor(.black)
                        .font(.footnote)
                        .lineLimit(1)
                        .frame(width: 50)
                } else {
                    Image(uiImage: UIImage(named: "ble_pow_\(viewModel.blePower)")!)
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 33, height: 27)
                    Text("\(viewModel.rssi)")
                        .foregroundColor(.black)
                        .font(.footnote)
                        .lineLimit(1)
                        .frame(width: 50)
                }
            }
        }
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
        .frame(minWidth: 140)
    }
}

struct PeripheralAdvCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PeripheralAdvCardView(viewModel: .init(peripheralUuid: "xx:xx:xx:xx:xx:xx",
                                                   peripheralName: "My BLE 1",
                                                   blePower: 1,
                                                   rssi: -40)).previewLayout(.sizeThatFits)
        }
    }
}
