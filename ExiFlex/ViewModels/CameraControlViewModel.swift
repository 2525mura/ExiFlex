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
        self.isFilmLoaded = false
        bind()
    }
    
    // Subscribe BLE message
    func bind() {
        // characteristicEvent subscribe process
        let eventSubscriber = bleService.bleServiceExpose.onRecvEventPublisher.sink(receiveValue: { payload in
            if payload.msg == "SHUTTER" && self.isFilmLoaded {
                if let context = self.viewContext {
                    let takeMeta = self.selectedRoll!.take(viewContext: context, isoValue: self.isoValue, fValue: self.fValue, ssValue: self.ssValue, location: self.nowLocation)
                    self.bleService.bleServiceExpose.sendEvent(msg: "SAVED")
                    self.lastId = takeMeta.id!
                }
            }
        })
        
        // characteristicLux subscribe process
        let luxSubscriber = bleService.bleServiceExpose.onRecvLuxPublisher.sink(receiveValue: { payload in
            // ExiFlexからの測定値をパースする
            self.onReceiveExposure(lux: payload)
        })
        
        // LocationService subscribe process
        let locationSubscriber = locationService.locationSharedPublisher.sink(receiveValue: { location in
            self.nowLocation = location
        })
        
        cancellables += [
            eventSubscriber,
            luxSubscriber,
            locationSubscriber
        ]
    }
    
    func onReceiveExposure(lux: CharacteristicLux) {

        self.isoValue = String(format: "%.1f", lux.iso)
        self.fValue = String(format: "%.1f", lux.f)
        self.ssValue = String(format: "%.1f", lux.ss)
        self.lvValue = Double(lux.lv)
        self.evValue = Double(lux.ev)
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
    
    func onChangeIso(isoValue: String) {
        self.bleService.bleServiceExpose.sendISO(iso: Int32(isoValue)!)
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
