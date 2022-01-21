//
//  DevAdvListViewModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/01/09.
//

import Foundation
import Combine


let devMock: [DevAdvViewModel] = [
    DevAdvViewModel(periUuidString: "xx:xx:xx:xx:xx:xx", devName: "My BLE 1", blePower: 1, rssi: -40),
    DevAdvViewModel(periUuidString: "yy:yy:yy:yy:yy:yy", devName: "My BLE 2", blePower: 2, rssi: -37)
]

final class DevAdvListViewModel: ObservableObject {

    @Published private(set) var devices: [DevAdvViewModel] = []
    private var cancellables: [AnyCancellable] = []
    let bleService: BleService

    init() {
        self.bleService = .init()
        bind()
    }
    
    func bind() {
        
        let peripheralAdvSubscriber = bleService.peripheralAdvSubject.sink(receiveValue: { ble in
            
            var blePower = Int(ceil((ble.rssi + 100.0) / 15.0))
            if blePower < 0 {blePower = 0}
            if blePower > 4 {blePower = 4}
            let rssi = Int(ble.rssi)
            // 既にペリフェラルが検出済みリストに登録されているかチェック
            if let foundId = self.devices.firstIndex(where: { return $0.periUuidString == ble.peripheralUuid }) {
                self.devices[foundId].blePower = blePower
                self.devices[foundId].rssi = rssi
                self.devices[foundId].isLostAdv = ble.isLostAdv
            } else {
                self.devices.append(
                    DevAdvViewModel(periUuidString: ble.peripheralUuid, devName: ble.peripheralName, blePower: blePower, rssi: rssi)
                )
            }
        })
        cancellables += [
            peripheralAdvSubscriber
        ]
        
    }
    
    func connectDevice(device: DevAdvViewModel) -> DevConnViewModel {
        return DevConnViewModel(connDevice: device.devName)
    }
}
