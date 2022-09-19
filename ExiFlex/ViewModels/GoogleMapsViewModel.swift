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

    @Published var markers: [UUID: GMSMarker]
    @Published var selectedMarkerId: UUID?

    init() {
        self.markers = [:]
    }
    
    func addMarker(id: UUID, position: CLLocationCoordinate2D) {
        self.markers[id] = GMSMarker(position: position)
    }
    
    func clearMarker(id: UUID) {
        self.markers[id]!.map = nil
        self.markers.removeValue(forKey: id)
    }
    
    func clearMarkerAll() {
        self.markers.removeAll()
    }
    
    func selectMarker(id: UUID) {
        self.selectedMarkerId = id
    }
    
}
