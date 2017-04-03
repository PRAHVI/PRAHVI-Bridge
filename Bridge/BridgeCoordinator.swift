//
//  BridgeCoordinator.swift
//  Bridge
//
//  Created by Blake Tsuzaki on 2/16/17.
//  Copyright © 2017 PRAHVI. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

public class BridgeCoordinator: NSObject {
    private let bridgeDelegateQueueName = "BridgeDelegateQueue"
    private let bridgeDomain = "local."
    private let bridgeType = "_PRAHVI._tcp."
    private var netService: NetService?
    private var asyncSocket: GCDAsyncSocket?
    internal var connectedSockets = [GCDAsyncSocket]()
    
    public override init() {
        super.init()
        let delegateQueue = DispatchQueue(label: bridgeDelegateQueueName)
        self.asyncSocket = GCDAsyncSocket(delegate: self, delegateQueue: delegateQueue)
    }
    
    public func startService(completion: ((Bool, Error?)->())?) {
        guard let asyncSocket = asyncSocket else { return }
        
        do {
            try asyncSocket.accept(onPort: 0)
            let port = asyncSocket.localPort
            let netService = NetService(domain: bridgeDomain, type: bridgeType, name: "", port: Int32(port))
            
            netService.delegate = self
            netService.publish()
            
            if let completion = completion { completion(true, nil) }
        } catch {
            if let completion = completion { completion(false, error) }
        }
    }
}

extension BridgeCoordinator: GCDAsyncSocketDelegate {
    public func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        BridgeDebug.log("Bridge Service Connected: host(\(String(describing: newSocket.connectedHost))) port(\(newSocket.connectedPort))")
        
        connectedSockets.append(newSocket)
    }
    
    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        BridgeDebug.log("Bridge Service Disconnected: host(\(String(describing: sock.connectedHost))) port(\(sock.connectedPort))")
        
        let idx = connectedSockets.index(of: sock)
        if let idx = idx { connectedSockets.remove(at: idx) }
    }
}

extension BridgeCoordinator: NetServiceDelegate {
    public func netServiceDidPublish(_ sender: NetService) {
        BridgeDebug.log("Bridge Service Published: domain(\(sender.domain)) type(\(sender.type)) name(\(sender.name)) port(\(sender.port))")
    }
    public func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        BridgeDebug.err("Bridge Service Failed: \(errorDict)")
    }
    public func netServiceDidStop(_ sender: NetService) {
        BridgeDebug.log("Bridge Service Stopped: domain(\(sender.domain)) type(\(sender.type)) name(\(sender.name)) port(\(sender.port))")
    }
}
