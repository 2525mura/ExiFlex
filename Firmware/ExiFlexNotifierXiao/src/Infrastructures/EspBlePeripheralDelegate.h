//
//  EspBlePeripheralDelegate.h
//  Exiflex EspBlePeripheralDelegate
//
//  Created by 村井慎太郎 on 2023/02/12.
//

#ifndef __ESP_BLE_PERIPHERAL_DELEGATE_H__
#define __ESP_BLE_PERIPHERAL_DELEGATE_H__

class EspBlePeripheralDelegate {
    public:
        virtual void onReceiveCharacteristic(String uuid, String alias, String data) = 0;
};

#endif __ESP_BLE_PERIPHERAL_DELEGATE_H__
