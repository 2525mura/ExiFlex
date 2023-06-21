//
//  BleServiceExposeEntity.swift
//  ExiFlex
//
//  Created by mac on 2023/06/20.
//

import Foundation

struct CharacteristicEvent {

    let msg: String
}

struct CharacteristicLux {

    let iso: Float
    let f: Float
    let ss: Float
    let lv: Float
    let ev: Float
    let lux: Float
}

struct CharacteristicRGB {

    let r: Float
    let g: Float
    let b: Float
    let ir: Float
}

struct CharacteristicISO {

    let iso: Int32
}
