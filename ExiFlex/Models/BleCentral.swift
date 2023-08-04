//
//  BleCentral.swift
//
//  BlueJinja Common library for iOS
//

import Foundation
import Combine
import CoreBluetooth

class BleCentral: NSObject, CBCentralManagerDelegate {

    // BLE Profile (Auto generated class)
    public let bleProfile: BleProfile
    
    // MARK: - Init
    override init() {
        self.connectStateBarSubject = PassthroughSubject<String, Never>()
        self.bleProfile = BleProfile()
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // 以降、共通処理
    private var centralManager: CBCentralManager?
    private var peripheralsDiscoverDate: [UUID:Date] = [:]
    private var peripheralsConnectRequestQueue: [UUID:String] = [:]
    private var peripheralsDisconnectRequestQueue: [UUID:String] = [:]
    private var peripheralsConnect: [UUID:CBPeripheral] = [:]
    private var advertiseCheckingTimer: Timer?
    public var delegate: BleCentralDelegate? = nil
    // ヘッダーバーの接続状態表示エリアに通知するためのSubject
    public let connectStateBarSubject: PassthroughSubject<String, Never>
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case CBManagerState.poweredOn:
            break
        default:
            break
        }
    }
    
    // On receive peripheral's advertise message
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let uuid = peripheral.identifier
        // send peripheral discovery and rediscoverd notifycation
        if let discoverDelegate = self.delegate {
            if peripheralsDiscoverDate.keys.contains(uuid) {
                // Rediscovered
                peripheralsDiscoverDate[uuid] = Date()
                discoverDelegate.peripheralDidUpdate(uuid: uuid, peripheral: peripheral, rssi: RSSI.doubleValue)
            } else {
                // First discovered
                peripheralsDiscoverDate[uuid] = Date()
                discoverDelegate.peripheralDidDiscover(uuid: uuid, peripheral: peripheral, rssi: RSSI.doubleValue)
            }
        }
        
        // commit connect request
        if peripheralsConnect.keys.contains(uuid) {
            // ubnormal case
        } else {
            // commit connect request
            // When a connection request for this Periphera is queued
            if let requestUuid = peripheralsConnectRequestQueue[uuid] {
                centralManager?.connect(peripheral)
                peripheralsConnect[uuid] = peripheral
                // remove reserved peripheral uuid from queue
                peripheralsConnectRequestQueue.removeValue(forKey: uuid)
                print("ペリフェラル接続受付")
                // When all request commited
                if peripheralsConnectRequestQueue.isEmpty {
                    stopAdvertiseScan()
                    print("Stop advertise scanning")
                }
            }
        }
    }
    
    // On connect success peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral.state == .connected {
            let uuid = peripheral.identifier
            if peripheralsConnect.keys.contains(uuid) {
                peripheral.delegate = bleProfile
                peripheral.discoverServices(bleProfile.serviceUuids)
                self.connectStateBarSubject.send("Connected")
            }
        }
    }
    
    // On connect failed peripheral
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let uuid = peripheral.identifier
        peripheralsConnect.removeValue(forKey: uuid)
        self.connectStateBarSubject.send("Connect Failed")
        print("ペリフェラルに接続失敗しました")
    }
    
    // calld on disconnect (requested or unexpected disconnect)
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let uuid = peripheral.identifier
        
        // commit disconnect request
        if peripheralsConnect.keys.contains(uuid) {
            if let requestUuid = peripheralsDisconnectRequestQueue[uuid] {
                // disconnect request commited
                peripheralsConnect.removeValue(forKey: uuid)
                peripheralsDisconnectRequestQueue.removeValue(forKey: uuid)
            } else {
                // Disconnected without a disconnect request
                // retry connect
                peripheralsConnect.removeValue(forKey: uuid)
                connectPeripheral(peripheralUuid: uuid.uuidString)
                startAdvertiseScan()
                print("ペリフェラル再接続中")
            }
        } else {
            // ubnormal case
        }
    }
    
    // バックグラウンド実行から復帰した際に呼ばれる
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("willRestoreState")
    }
    
    // Notify Peripheral deletion if more than 5 seconds have passed since Advertise was last received
    @objc private func advertiseChecker() {
        
        // send peripheral delete notifycation
        if let discoverDelegate = self.delegate {
            for discoverdDate in peripheralsDiscoverDate {
                let uuid = discoverdDate.key
                let date = discoverdDate.value
                if Date().timeIntervalSince(date) > 5 {
                    peripheralsDiscoverDate.removeValue(forKey: uuid)
                    discoverDelegate.peripheralDidDelete(uuid: uuid)
                }
            }
        }
    }
    
    // connect to the specified peripheral from ViewModel
    func connectPeripheral(peripheralUuid: String) {
        let uuid = UUID(uuidString: peripheralUuid)!
        peripheralsConnectRequestQueue[uuid] = ""
        // Update status bar message
        self.connectStateBarSubject.send("Connecting")
    }
    
    // disconnect to the specified peripheral from ViewModel
    func disConnectPeripheral(peripheralUuid: String) {
        let uuid = UUID(uuidString: peripheralUuid)!
        peripheralsDisconnectRequestQueue[uuid] = ""
        if let peripheral = peripheralsConnect[uuid] {
            centralManager?.cancelPeripheralConnection(peripheral)
            // Update status bar message
            self.connectStateBarSubject.send("Disconnecting")
            print("ペリフェラル切断要求")
        }
    }
    
    // disconnect to all peripheral from ViewModel
    func disConnectPeripheralAll() {
        for kvPeripheral in peripheralsConnect {
            let uuid = kvPeripheral.key
            disConnectPeripheral(peripheralUuid: uuid.uuidString)
        }
    }
    
    func startAdvertiseScan() {
        centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        // Start Advertise checker (Polling method)
        self.advertiseCheckingTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(self.advertiseChecker),
            userInfo: nil,
            repeats: true
        )
    }
    
    func stopAdvertiseScan() {
        // Stop Advertise checker
        self.advertiseCheckingTimer?.invalidate()
        centralManager?.stopScan()
        clearDiscoverHistory()
    }
    
    func clearDiscoverHistory() {
        peripheralsDiscoverDate.removeAll()
    }
    
}

extension Data {
    var bytes: [UInt8] {
        self.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                return []
            }
            return [UInt8](UnsafeBufferPointer(start: pointer, count: count))
        }
    }
    
    var arrayInt32: [Int32] {
        self.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: Int32.self) else {
                return []
            }
            return [Int32](UnsafeBufferPointer(start: pointer, count: count>>2))
        }
    }
    
    var arrayFloat: [Float] {
        self.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: Float.self) else {
                return []
            }
            return [Float](UnsafeBufferPointer(start: pointer, count: count>>2))
        }
    }
}

extension Int32 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<Int32>.size)
    }
}
