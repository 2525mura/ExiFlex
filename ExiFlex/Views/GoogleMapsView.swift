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
        // 現在地を表示する
        self.gmsMapView.isMyLocationEnabled = true
        return self.gmsMapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        if self.viewModel.markers.count == 0 {
            mapView.clear()
        } else {
            // show markers
            self.viewModel.markers.forEach { $0.value.map = mapView }
            // animate to selectedMarker
            animateToSelectedMarker(mapView: mapView)
        }
    }
    
    private func animateToSelectedMarker(mapView: GMSMapView) {
        guard let id = self.viewModel.selectedMarkerId else {
            return
        }
        guard let selectedMarker = self.viewModel.markers[id] else {
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
