//
//  AlbumViewModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/08/17.
//

import Foundation
import CoreData
import CoreLocation

class AlbumViewModel: ObservableObject {
    
    @Published var googleMapsViewModel: GoogleMapsViewModel
    @Published var isFilmLoaded: Bool
    private(set) var viewContext: NSManagedObjectContext?
    @Published private(set) var selectedRoll: Roll?
    
    init() {
        self.googleMapsViewModel = GoogleMapsViewModel()
        self.isFilmLoaded = false
    }
    
    func setFilm(viewContext: NSManagedObjectContext, selectedRoll: Roll) {
        self.viewContext = viewContext
        self.selectedRoll = selectedRoll
        self.isFilmLoaded = true
        // マーカーを設定(要修正)
        selectedRoll.takeMetasList.forEach { takeMeta in
            if takeMeta.locationActive {
                self.googleMapsViewModel.addMarker(position: CLLocationCoordinate2D(latitude: takeMeta.latitude, longitude: takeMeta.longitude))
            }
        }
    }
    
    func ejectFilm() {
        // マーカーを削除
        self.googleMapsViewModel.clearMarkers()
        self.isFilmLoaded = false
    }

}
