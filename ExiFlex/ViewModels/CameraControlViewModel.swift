//
//  CameraControlViewModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/05/09.
//

import Foundation
import Combine
import CoreData
import CoreLocation

final class CameraControlViewModel: ObservableObject {

    private let bleService: BleService
    private let locationService: LocationService
    private var cancellables: [AnyCancellable] = []
    private var nowLocation: CLLocation?
    // 画面部品の状態変数
    @Published var isoValue: String = "N/A"
    @Published var fValue: String = "N/A"
    @Published var ssValue: String = "N/A"
    // 設定条件における適正EV値
    private var evValue: Double = 0
    // 実測LV値
    private var lvValue: Double = 0
    // LV - EV
    @Published var dEv: Double = 0
    private(set) var viewContext: NSManagedObjectContext?
    @Published private(set) var selectedRoll: Roll?
    @Published var lastId: UUID = UUID()
    @Published var isFilmLoaded: Bool
    public var rollEditViewModel: RollEditViewModel?
    // Memo: モーダルで何を開いているかは、ViewModel側で持つべし
    @Published var modalRollState: ModalRollState = .selectFilm
    
    init(bleService: BleService, locationService: LocationService) {
        self.bleService = bleService
        self.locationService = locationService
        self.bleService.addCharacteristicUuid(uuid: "beb5483e-36e1-4688-b7f5-ea07361b26a8", alias: "shutter")
        self.bleService.addCharacteristicUuid(uuid: "16cf81e3-0212-58b9-0380-0dbc6b54c51d", alias: "lux")
        self.isFilmLoaded = false
        bind()
    }
    
    func bind() {
        // BleServiceからのキャラクタリスティック受信を受け付ける処理
        let characteristicMsgSubscriber = bleService.characteristicSharedPublisher.sink(receiveValue: { characteristicMsg in
            if characteristicMsg.characteristicAlias == "shutter" && self.isFilmLoaded {
                if let context = self.viewContext {
                    let takeMeta = self.selectedRoll!.take(viewContext: context, isoValue: self.isoValue, fValue: self.fValue, ssValue: self.ssValue, location: self.nowLocation)
                    self.bleService.sendMessage(message: "SAVED", characteristicUuid: "beb5483e-36e1-4688-b7f5-ea07361b26a8")
                    self.lastId = takeMeta.id!
                }
            } else if characteristicMsg.characteristicAlias == "lux" {
                // ExiFlexからの測定値をパースする
                self.onReceiveExposure(recvStr: characteristicMsg.characteristicData)
            }
        })
        
        // LocationServiceからの位置情報受信を受け付ける処理
        let locationSubscriber = locationService.locationSharedPublisher.sink(receiveValue: { location in
            self.nowLocation = location
        })
        
        cancellables += [
            characteristicMsgSubscriber,
            locationSubscriber
        ]
    }
    
    func onReceiveExposure(recvStr: String) {
        var expParams = recvStr.components(separatedBy: " ").reduce([String: String]()) { (dict, item) in
            var resultDict = dict
            var kv = item.components(separatedBy: ":")
            resultDict[kv[0]] = kv[1]
            return resultDict
        }
        self.isoValue = expParams["ISO"]!
        self.fValue = expParams["FNUM"]!
        self.ssValue = expParams["SS"]!
        var luxValue = expParams["LUX"]!
        self.lvValue = Double(expParams["LV"]!)!
        self.evValue = Double(expParams["EV"]!)!
        self.dEv = lvValue - evValue
    }
    
    func setFilm(viewContext: NSManagedObjectContext, selectedRoll: Roll) {
        self.viewContext = viewContext
        self.selectedRoll = selectedRoll
        self.isFilmLoaded = true
        if let lastTakeMeta = self.selectedRoll!.takeMetasList.last {
            // 見つかったコマがリーダーでない場合
            if lastTakeMeta.frameType != .leader {
                // set後1秒後にフィルムの最後をアニメーション表示する
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.lastId = lastTakeMeta.id!
                }
            }
        }
    }
    
    func ejectFilm() {
        if let firstTakeMeta = self.selectedRoll!.takeMetasList.first {
            self.lastId = firstTakeMeta.id!
        }
        
        if let lastTakeMeta = self.selectedRoll!.takeMetasList.last {
            // 見つかったコマがリーダーでない場合
            if lastTakeMeta.frameType != .leader {
                // アニメーションが終わるのを待ってからeject状態にする
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.isFilmLoaded = false
                }
            } else {
                self.isFilmLoaded = false
            }
        } else {
            self.isFilmLoaded = false
        }
    }
    
    func tmpRollInit() {
        self.rollEditViewModel = RollEditViewModel()
        self.modalRollState = .createFilm
    }
    
    func tmpRollSave() {
        self.selectedRoll = self.rollEditViewModel?.editRoll
        self.isFilmLoaded = true
        self.modalRollState = .selectFilm
    }
    
    /*
    func tmpRollRollback(viewContext: NSManagedObjectContext) {
        // ロールバック
        viewContext.rollback()
        self.modalRollState = .selectFilm
    }
    */
    
}

enum ModalRollState {
    case selectFilm
    case createFilm
}
