//
//  RootViewModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/07/06.
//

import Foundation
import Combine

class RootViewModel: ObservableObject {
    
    private let bleCentral: BleCentral
    private let locationService: LocationService
    var peripheralListVm: PeripheralListViewModel
    var cameraControlViewModel: CameraControlViewModel
    var cie1931xyViewModel: Cie1931xyViewModel
    var albumViewModel: AlbumViewModel
    @Published public var connectStateBarCaption: String
    private var cancellables: [AnyCancellable] = []
    
    init() {
        self.bleCentral = BleCentral()
        self.locationService = LocationService()
        self.peripheralListVm = PeripheralListViewModel(bleCentral: bleCentral)
        self.cameraControlViewModel = CameraControlViewModel(bleCentral: bleCentral, locationService: locationService)
        self.cie1931xyViewModel = Cie1931xyViewModel(bleCentral: bleCentral)
        self.albumViewModel = AlbumViewModel()
        self.connectStateBarCaption = "No Connect"
        bind()
    }
    
    // BleCentralからのステータスバー表示値の更新通知を受け付ける処理
    func bind() {
        let connectStateBarSubscriber = bleCentral.connectStateBarSubject.sink(receiveValue: { caption in
            self.connectStateBarCaption = caption
        })
        cancellables += [
            connectStateBarSubscriber
        ]
    }
    
    func startAdvertiseScan() {
        self.peripheralListVm.bind()
        self.bleCentral.clearDiscoverHistory()
        self.bleCentral.startAdvertiseScan()
    }
    
}
