//
//  BridgeDebug.swift
//  Bridge
//
//  Created by Blake Tsuzaki on 4/3/17.
//  Copyright © 2017 PRAHVI. All rights reserved.
//

import Foundation

public enum BridgeDebugMessageType {
    case notification, error
}

public struct BridgeDebugMessage {
    public var message: String
    public var type: BridgeDebugMessageType
}

protocol BridgeDebugDelegate {
    func didPrintMessage(object: BridgeDebugMessage)
}

class BridgeDebug: NSObject {
    private let errorPrefix = "[Bridge ⚠️] "
    private let notifPrefix = "[Bridge 💬] "
    
    var delegate: BridgeDebugDelegate?
    
    func log(_ message: String, separator: String = " ", terminator: String = "\n") {
        print(notifPrefix, message, separator:separator, terminator: terminator)
        delegate?.didPrintMessage(object: BridgeDebugMessage(message: notifPrefix.appending(message), type: .notification))
    }
    func err(_ message: String, separator: String = " ", terminator: String = "\n") {
        print(errorPrefix, message, separator:separator, terminator: terminator)
        delegate?.didPrintMessage(object: BridgeDebugMessage(message: errorPrefix.appending(message), type: .error))
    }
}
