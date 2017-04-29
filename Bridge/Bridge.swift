//
//  Bridge.swift
//  Bridge
//
//  Created by Blake Tsuzaki on 2/16/17.
//  Copyright © 2017 PRAHVI. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

public protocol BridgeDelegate {
    func didPrintDebugMessage(object: BridgeDebugMessage)
    func bridgeDidConnect(bridge: Bridge)
    func bridgeDidDisconnect(bridge: Bridge)
    func bridge(_ bridge: Bridge, didReceiveData data: NSData)
}

open class Bridge: NSObject {
    private let bridgeDelegateQueueName = "BridgeDelegateQueue"
    private let bridgeDomain = "local."
    private let bridgeType = "_PRAHVI._tcp."
    private var netService: NetService?
    private var asyncSocket: GCDAsyncSocket?
    internal var connectedSockets = [GCDAsyncSocket]()
    internal let bridgeDebug = BridgeDebug()
    
    public var delegate: BridgeDelegate?
    open var bridgeName = ""
    
    public override init() {
        super.init()
        let delegateQueue = DispatchQueue(label: bridgeDelegateQueueName)
        asyncSocket = GCDAsyncSocket(delegate: self, delegateQueue: delegateQueue)
        bridgeDebug.delegate = self
    }
    
    public convenience init(bridgeName: String) {
        self.init()
        self.bridgeName = bridgeName
    }
    
    public func startService(completion: ((Bool, Error?)->())?) {
        guard let asyncSocket = asyncSocket else { return }
        
        do {
            try asyncSocket.accept(onPort: 0)
            let port = asyncSocket.localPort
            let netService = NetService(domain: bridgeDomain, type: bridgeType, name: bridgeName, port: Int32(port))
            
            netService.delegate = self
            netService.publish()
            
            self.netService = netService
            
            if let completion = completion { completion(true, nil) }
        } catch {
            if let completion = completion { completion(false, error) }
        }
    }
}

extension Bridge: GCDAsyncSocketDelegate {
    public func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        bridgeDebug.log("Service Connected: host(\(newSocket.connectedHost!)) port(\(newSocket.connectedPort))")
        
        newSocket.readData(withTimeout: -1, tag: 0)
        connectedSockets.append(newSocket)
        
        delegate?.bridgeDidConnect(bridge: self)
    }
    
    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        bridgeDebug.log("Service Disconnected: host(\(String(describing: sock.connectedHost))) port(\(sock.connectedPort))")
        
        let idx = connectedSockets.index(of: sock)
        if let idx = idx { connectedSockets.remove(at: idx) }
        
        delegate?.bridgeDidDisconnect(bridge: self)
    }
    
    public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
//        bridgeDebug.log("Service Received Data: data(\(data)), tag(\(tag))")
        delegate?.bridge(self, didReceiveData: data as NSData)
        
        sock.readData(withTimeout: -1, tag: 0)
    }
}

extension Bridge: NetServiceDelegate {
    public func netServiceDidPublish(_ sender: NetService) {
        bridgeDebug.log("Service Published: domain(\(sender.domain)) type(\(sender.type)) name(\(sender.name)) port(\(sender.port))")
    }
    public func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        bridgeDebug.err("Service Failed: \(errorDict)")
    }
    public func netServiceDidStop(_ sender: NetService) {
        bridgeDebug.log("Service Stopped: domain(\(sender.domain)) type(\(sender.type)) name(\(sender.name)) port(\(sender.port))")
    }
}

extension Bridge: BridgeDebugDelegate {
    func didPrintMessage(object: BridgeDebugMessage) {
        delegate?.didPrintDebugMessage(object: object)
    }
}
