//
//  GoogleMapsViewModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/08/16.
//

import Foundation
import Combine
import UIKit
import GoogleMaps

class GoogleMapsViewModel: ObservableObject {

    @Published var markers: [GMSMarker]
    @Published var selectedMarker: GMSMarker?

    init() {
        // ダミーデータをセットする
        self.markers = [GMSMarker(position: CLLocationCoordinate2D(latitude: 35.6684411, longitude: 139.6004407))]
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
            self.selectedMarker = self.markers[0]
        })
    }

}
