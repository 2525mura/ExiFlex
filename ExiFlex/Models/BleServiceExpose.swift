import Foundation
import Combine
import CoreBluetooth

class BleServiceExpose: NSObject, CBPeripheralDelegate, BleServiceExposeDelegate {

    // MARK: ESP32 Ble UUID
    private let serviceUuid: CBUUID
    private let characteristicEventUuid = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8")
    private let characteristicLuxUuid = CBUUID(string: "16cf81e3-0212-58b9-0380-0dbc6b54c51d")
    private let characteristicRGBUuid = CBUUID(string: "67f46ec5-3d54-54c2-ae2d-fb318a4973b0")
    private let characteristicISOUuid = CBUUID(string: "241abff2-5d09-b5a3-4a77-cfc19cfac587")
    private var characteristicUuids: [CBUUID] = []
    
    // A service and characteristics
    private var cbService: CBService?
    private var cbCharacteristicEvent: CBCharacteristic?
    private var cbCharacteristicLux: CBCharacteristic?
    private var cbCharacteristicRGB: CBCharacteristic?
    private var cbCharacteristicISO: CBCharacteristic?
    
    public var delegate: BleServiceExposeDelegate? = nil
    
    // MARK: - Init
    init(serviceUuid: CBUUID) {
        self.serviceUuid = serviceUuid
        self.characteristicUuids.append(characteristicEventUuid)
        self.characteristicUuids.append(characteristicLuxUuid)
        self.characteristicUuids.append(characteristicRGBUuid)
        self.characteristicUuids.append(characteristicISOUuid)
        // テンプレートここまで
        
        self.onRecvEventPublisher = onRecvEventSubject.eraseToAnyPublisher().share()
        self.onRecvLuxPublisher = onRecvLuxSubject.eraseToAnyPublisher().share()
        self.onRecvRGBPublisher = onRecvRGBSubject.eraseToAnyPublisher().share()
        self.onRecvISOPublisher = onRecvISOSubject.eraseToAnyPublisher().share()
        super.init()
        
        self.delegate = self
    }
    
    // On discover servises (Implemented exclusively for one service)
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error == nil {
            if let services = peripheral.services {
                for service in services {
                    // The specified service was found
                    if service.uuid == serviceUuid {
                        // Set member variable of Service. And discover the specified Characteristic from this service
                        cbService = service
                        peripheral.discoverCharacteristics(self.characteristicUuids, for: service)
                        print("Discoverd Service \"Expose\"")
                    }
                }
            }
        } else {
        }
    }
    
    // On discover characteristics of servise
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error == nil {
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    // Set each member variable of Characteristic. And allow notifications
                    switch characteristic.uuid {
                    case characteristicEventUuid:
                        cbCharacteristicEvent = characteristic
                        peripheral.setNotifyValue(true, for: characteristic)
                        break
                    case characteristicLuxUuid:
                        cbCharacteristicLux = characteristic
                        peripheral.setNotifyValue(true, for: characteristic)
                        break
                    case characteristicRGBUuid:
                        cbCharacteristicRGB = characteristic
                        peripheral.setNotifyValue(true, for: characteristic)
                        break
                    case characteristicISOUuid:
                        cbCharacteristicISO = characteristic
                        peripheral.setNotifyValue(true, for: characteristic)
                        break
                    default:
                        break
                    }
                    print("Discoverd Characteristics")
                }
            }
        } else {
            
        }
    }
    
    // ペリフェラルからnotify通知があった時に呼び出される
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error == nil {
            guard let data = characteristic.value else {
                return
            }
            guard let recvDelegate = delegate else {
                return
            }
            
            // Distribute call functions based on characteristic UUID
            switch characteristic.uuid {
            case characteristicEventUuid:
                recvDelegate.onRecvEvent(msg: String(data: data, encoding: .ascii)!)
                break
            case characteristicLuxUuid:
                let buff = data.arrayFloat
                recvDelegate.onRecvLux(iso: buff[0], f: buff[1], ss: buff[2], lv: buff[3], ev: buff[4], lux: buff[5])
                break
            case characteristicRGBUuid:
                let buff = data.arrayFloat
                recvDelegate.onRecvRGB(r: buff[0], g: buff[1], b: buff[2], ir: buff[3])
                break
            case characteristicISOUuid:
                let buff = data.arrayInt32
                recvDelegate.onRecvISO(iso: buff[0])
                break
            default:
                break
            }
            
        } else {
            
        }
    }
    
    // send Event to peripheral
    func sendEvent(msg: String) {
        guard let data = msg.data(using: .ascii) else {
            return
        }
        if let peripheral = cbService?.peripheral {
            if let characteristic = cbCharacteristicEvent {
                peripheral.writeValue(data, for: characteristic, type: .withResponse)
            }
        }
    }
    
    // send ISO to peripheral
    func sendISO(iso: Int32) {
        if let peripheral = cbService?.peripheral {
            if let characteristic = cbCharacteristicISO {
                peripheral.writeValue(iso.data, for: characteristic, type: .withResponse)
            }
        }
    }
    
    // テンプレートここまで
    
    // 以下はcallback eventをpublishするサンプル
    private let onRecvEventSubject = PassthroughSubject<CharacteristicEvent, Never>()
    private let onRecvLuxSubject = PassthroughSubject<CharacteristicLux, Never>()
    private let onRecvRGBSubject = PassthroughSubject<CharacteristicRGB, Never>()
    private let onRecvISOSubject = PassthroughSubject<CharacteristicISO, Never>()
    public let onRecvEventPublisher: Publishers.Share<AnyPublisher<CharacteristicEvent, Never>>
    public let onRecvLuxPublisher: Publishers.Share<AnyPublisher<CharacteristicLux, Never>>
    public let onRecvRGBPublisher: Publishers.Share<AnyPublisher<CharacteristicRGB, Never>>
    public let onRecvISOPublisher: Publishers.Share<AnyPublisher<CharacteristicISO, Never>>
    
    func onRecvEvent(msg: String) {
        let payload = CharacteristicEvent(msg: msg)
        onRecvEventSubject.send(payload)
    }
    
    func onRecvLux(iso: Float, f: Float, ss: Float, lv: Float, ev: Float, lux: Float) {
        let payload = CharacteristicLux(iso: iso, f: f, ss: ss, lv: lv, ev: ev, lux: lux)
        onRecvLuxSubject.send(payload)
    }
    
    func onRecvRGB(r: Float, g: Float, b: Float, ir: Float) {
        let payload = CharacteristicRGB(r: r, g: g, b: b, ir: ir)
        onRecvRGBSubject.send(payload)
    }
    
    func onRecvISO(iso: Int32) {
        let payload = CharacteristicISO(iso: iso)
        onRecvISOSubject.send(payload)
    }
    
}
