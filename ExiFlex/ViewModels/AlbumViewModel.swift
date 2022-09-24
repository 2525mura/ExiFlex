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
        // GoogleMapのマーカーを設定
        selectedRoll.takeMetasList.forEach { takeMeta in
            if takeMeta.locationActive {
                self.googleMapsViewModel.addMarker(id: takeMeta.id!, position: CLLocationCoordinate2D(latitude: takeMeta.latitude, longitude: takeMeta.longitude))
            }
        }
        // フィルムの先頭からスキャンして、最初に見つかった位置情報のマーカーに移動する
        if let found = selectedRoll.takeMetasList.first(where: { return $0.locationActive }) {
            self.selectMarker(id: found.id!)
        }
    }
    
    func selectMarker(id: UUID) {
        self.googleMapsViewModel.selectMarker(id: id)
    }
    
    func ejectFilm() {
        // マーカーを削除
        self.googleMapsViewModel.clearMarkerAll()
        self.isFilmLoaded = false
    }

}
