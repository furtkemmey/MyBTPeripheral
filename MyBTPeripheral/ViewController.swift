//
//  ViewController.swift
//  MyBTPeripheral
//
//  Created by KaiChieh on 2018/4/13.
//  Copyright © 2018 KaiChieh. All rights reserved.
//

import UIKit
import CoreBluetooth


class ViewController: UIViewController {
    let strService = "8B3A14A0-BD8D-4891-98C6-C3CE6B28081B" // get form uuidgen command
    let strCharacteristic1 = "51D39CEA-041D-47D2-979F-B65E0FAC3743"  // for send message
    let strCharacteristic2 = "157012B5-5F47-4D48-8B09-E9EDD519E948"  // for written

    var peripheralMangger: CBPeripheralManager!
    var arrCharacteristics = [CBMutableCharacteristic]()


    @IBOutlet weak var textInfo: UITextView!
    @IBOutlet weak var lblSend: UILabel!
    @IBOutlet weak var switchPower: UISwitch!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.peripheralMangger = CBPeripheralManager(delegate: self, queue: nil)
    }


}

extension ViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheralMangger.state {
        case .poweredOn:
            textInfo.text = "powerOn"
        case .poweredOff:
            textInfo.text = "powerOff"
        default:
            textInfo.text = "unknow"
            return
        }
        let serivce = CBMutableService(type: CBUUID(string: strService), primary: true)
        // notify from strCharacteristic1
        var characteristic = CBMutableCharacteristic(type: CBUUID(string: strCharacteristic1), properties: .notify, value: nil, permissions: .readable)
        arrCharacteristics.append(characteristic)
        //write from strCharacteristic2
        characteristic = CBMutableCharacteristic(type: CBUUID(string: strCharacteristic2), properties: .write, value: nil, permissions: .writeable)
        arrCharacteristics.append(characteristic)

        serivce.characteristics = arrCharacteristics
        peripheralMangger.add(serivce)
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if error != nil {
            textInfo.text = textInfo.text + "\n \(error!.localizedDescription)"
            return
        } else {
            textInfo.text = textInfo.text + "\n did add serivce"
        }
        textInfo.text = textInfo.text + "\n added device"
        let deviceNmae = UIDevice.current.name
        peripheralMangger.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[service.uuid], CBAdvertisementDataLocalNameKey:deviceNmae])

        //持續傳送累加數字
        let globalQueue = DispatchQueue.global(qos: .default)
        globalQueue.async {
            var i = 0
            while true {
                i += 1
                let strData = "\(i)".data(using: .utf8)!
                DispatchQueue.main.async {
                    self.lblSend.text = "\(i)"
                }
                Thread.sleep(forTimeInterval: 1)
            }
        }
    }


}
