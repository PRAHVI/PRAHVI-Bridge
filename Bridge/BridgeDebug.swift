//
//  BridgeDebug.swift
//  Bridge
//
//  Created by Blake Tsuzaki on 4/3/17.
//  Copyright © 2017 PRAHVI. All rights reserved.
//

import Foundation

class BridgeDebug: NSObject {
    class func log(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        var printout = items
        if let str = printout[0] as? String {
            printout[0] = "[Bridge-Log]" + str
        }
        
        print(printout, separator:separator, terminator: terminator)
    }
    class func err(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        var printout = items
        if let str = printout[0] as? String {
            printout[0] = "[Bridge-Error]" + str
        }
        
        print(printout, separator:separator, terminator: terminator)
    }
}
