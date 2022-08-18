//
//  AlbumViewModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/08/17.
//

import Foundation

class AlbumViewModel: ObservableObject {
    
    @Published var googleMapsViewModel: GoogleMapsViewModel
    @Published var isFilmLoaded: Bool
    @Published private(set) var rollViewModels: [RollViewModel]
    @Published private(set) var selectedRoll: RollViewModel
    
    init() {
        self.googleMapsViewModel = GoogleMapsViewModel()
        self.isFilmLoaded = false
        self.rollViewModels = []
        self.selectedRoll = RollViewModel(rollName: "init_filler")
        // ダミー。最終的にはストレージからロードする
        self.rollViewModels.append(
            RollViewModel(rollName: "First")
        )
        self.rollViewModels.append(
            RollViewModel(rollName: "Second")
        )
        // ダミーここまで
    }
    
    func setFilm(selectedRoll: RollViewModel) {
        self.selectedRoll = selectedRoll
        self.isFilmLoaded = true
    }
    
    func ejectFilm() {
        self.isFilmLoaded = false
    }

}
