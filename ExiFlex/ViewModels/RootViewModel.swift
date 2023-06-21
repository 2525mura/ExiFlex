//
//  RootViewModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/07/06.
//

import Foundation
import Combine

class RootViewModel: ObservableObject {
    
    private let bleService: BleService
    private let locationService: LocationService
    var peripheralListVm: PeripheralListViewModel
    var cameraControlViewModel: CameraControlViewModel
    var cie1931xyViewModel: Cie1931xyViewModel
    var albumViewModel: AlbumViewModel
    @Published public var connectStateBarCaption: String
    private var cancellables: [AnyCancellable] = []
    
    init() {
        self.bleService = BleService()
        self.locationService = LocationService()
        self.peripheralListVm = PeripheralListViewModel(bleService: bleService)
        self.cameraControlViewModel = CameraControlViewModel(bleService: bleService, locationService: locationService)
        self.cie1931xyViewModel = Cie1931xyViewModel(bleService: self.bleService)
        self.albumViewModel = AlbumViewModel()
        self.connectStateBarCaption = "No Connect"
        bind()
    }
    
    // BleServiceからのステータスバー表示値の更新通知を受け付ける処理
    func bind() {
        let connectStateBarSubscriber = bleService.connectStateBarSubject.sink(receiveValue: { caption in
            self.connectStateBarCaption = caption
        })
        cancellables += [
            connectStateBarSubscriber
        ]
    }
    
    func startAdvertiseScan() {
        self.peripheralListVm.bind()
        self.bleService.flushPeripherals()
        self.bleService.startAdvertiseScan()
    }
    
}
