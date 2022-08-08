//
//  GoogleMapsView.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/08/08.
//

import SwiftUI
import GoogleMaps

struct GoogleMapsView: UIViewRepresentable {
    
    // 緯度経度は東京駅を設定しています
    let mapView = GMSMapView(
        frame: .zero, camera: GMSCameraPosition.camera(withLatitude: 35.681111, longitude: 139.766667, zoom: 15.0)
    )
    
    func makeUIView(context: Context) -> GMSMapView {
        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
    }
}

struct GoogleMapsView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleMapsView()
    }
}
