import Foundation
import CoreBluetooth

protocol BleServiceExposeDelegate {

    func onRecvEvent(msg: String)
    func onRecvLux(iso: Float, f: Float, ss: Float, lv: Float, ev: Float, lux: Float)
    func onRecvRGB(r: Float, g: Float, b: Float, ir: Float)
    func onRecvISO(iso: Int32)
}
