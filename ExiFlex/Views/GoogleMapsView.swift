//
//  GoogleMapsView.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/08/08.
//

import SwiftUI
import GoogleMaps

struct GoogleMapsView: UIViewRepresentable {
    
    typealias UIViewType = GMSMapView
    @ObservedObject private(set) var viewModel: GoogleMapsViewModel
    let gmsMapView = GMSMapView(frame: .zero)
    
    func makeUIView(context: Context) -> GMSMapView {
        // マーカーが1個でもあれば、先頭マーカーの座標をセットする
        if let markerFirst = self.viewModel.markers.first {
            let camera = GMSCameraPosition.camera(withLatitude: markerFirst.position.latitude, longitude: markerFirst.position.longitude, zoom: 8)
            self.gmsMapView.camera = camera
        }
        return self.gmsMapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        // show markers
        self.viewModel.markers.forEach { $0.map = mapView }
        // animate to selectedMarker
        self.viewModel.selectedMarker?.map = mapView
        animateToSelectedMarker(mapView: mapView)
    }
    
    private func animateToSelectedMarker(mapView: GMSMapView) {
        guard let selectedMarker = self.viewModel.selectedMarker else {
            return
        }
        
        if mapView.selectedMarker != selectedMarker {
            mapView.selectedMarker = selectedMarker
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                mapView.animate(toZoom: 8)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    mapView.animate(with: GMSCameraUpdate.setTarget(selectedMarker.position))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        mapView.animate(toZoom: 12)
                    })
                }
            }
        }
    }
    
}

struct GoogleMapsView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleMapsView(viewModel: GoogleMapsViewModel())
    }
}
