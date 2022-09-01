//
//  LocationService.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/08/31.
//

import Foundation
import Combine
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {

    var locationManager: CLLocationManager
    // 位置情報変化イベントをViewModelに通知するためのSubjectとPublisher
    private let locationSubject: PassthroughSubject<CLLocation, Never>
    let locationSharedPublisher: Publishers.Share<AnyPublisher<CLLocation, Never>>
    
    override init() {
        locationManager = CLLocationManager()
        self.locationSubject = PassthroughSubject<CLLocation, Never>()
        self.locationSharedPublisher = self.locationSubject.eraseToAnyPublisher().share()
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            locationManager.distanceFilter = 10
            // 位置情報の取得開始
            locationManager.startUpdatingLocation()
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationSubject.send(locations.first!)
    }
    
}
