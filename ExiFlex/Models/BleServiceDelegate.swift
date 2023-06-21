import Foundation
import CoreBluetooth

protocol BleServiceDelegate {

    func peripheralDidDiscover(uuid: UUID, peripheral: CBPeripheral, rssi: Double)
    func peripheralDidUpdate(uuid: UUID, peripheral: CBPeripheral, rssi: Double)
    func peripheralDidDelete(uuid: UUID)
}
