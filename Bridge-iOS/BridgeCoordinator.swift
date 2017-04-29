//
//  BridgeHandler.swift
//  Bridge
//
//  Created by Blake Tsuzaki on 4/3/17.
//  Copyright © 2017 PRAHVI. All rights reserved.
//

import UIKit
import Bridge

protocol BridgeCoordinatorDelegate {
    func bridgeCoordinator(_ coordinator: BridgeCoordinator, didReceiveData data: NSData)
}
class BridgeCoordinator: NSObject {
    var baseBridge: Bridge?
    var imageCaptureBridge: BridgeImageCapture?
    var delegate: BridgeCoordinatorDelegate?
    
    override init() {
        super.init()
        let baseBridge = Bridge()
        baseBridge.delegate = self
        self.baseBridge = baseBridge
    }
    
    func startCommunication() {
        baseBridge?.startService(completion: nil)
    }
}

extension BridgeCoordinator: BridgeDelegate {
    func didPrintDebugMessage(object: BridgeDebugMessage) {
        NotificationCenter.default.post(name: Constants.bridgeNotification, object: object)
    }
    func bridgeDidConnect(bridge: Bridge) {
        if (bridge == baseBridge) {
            
        }
    }
    func bridgeDidDisconnect(bridge: Bridge) {
        
    }
    func bridge(_ bridge: Bridge, didReceiveData data: NSData) {
        delegate?.bridgeCoordinator(self, didReceiveData: data)
    }
}
