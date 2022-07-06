//
//  RootViewModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/07/06.
//

import Foundation

class RootViewModel: ObservableObject {
    
    private let bleService: BleService
    var peripheralListVm: PeripheralListViewModel
    var cameraControlViewModel: CameraControlViewModel
    var cie1931xyViewModel: Cie1931xyViewModel
    
    init() {
        self.bleService = BleService()
        self.peripheralListVm = PeripheralListViewModel(bleService: bleService)
        self.cameraControlViewModel = CameraControlViewModel(bleService: bleService)
        self.cie1931xyViewModel = Cie1931xyViewModel(bleService: self.bleService)
    }
    
    func startAdvertiseScan() {
        self.peripheralListVm.bind()
        self.bleService.flushPeripherals()
        self.bleService.startAdvertiseScan()
    }
    
}
