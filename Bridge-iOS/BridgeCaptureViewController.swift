//
//  BridgeCaptureViewController.swift
//  Bridge
//
//  Created by Blake Tsuzaki on 4/27/17.
//  Copyright © 2017 PRAHVI. All rights reserved.
//

import Foundation
import UIKit
import Bridge

class BridgeCaptureViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    internal var image: UIImage?
    internal var totalImageData = [UInt8]()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        BridgeGlobal.bridgeCoordinator.delegate = self
    }
    
    
}
extension BridgeCaptureViewController: BridgeCoordinatorDelegate {
    func bridgeCoordinator(_ coordinator: BridgeCoordinator, didReceiveData data: NSData) {
        let count = data.length/MemoryLayout<UInt8>.size
        var array = [UInt8](repeating: 0, count: count)

        if count == 4 {
            print(totalImageData)
            
            let image = imageFromByteArray(data: totalImageData, size: CGSize(width: 480, height: 640))
            
            if (image != nil) {
                totalImageData = [UInt8]()
                DispatchQueue.main.async(execute: {
                    self.imageView.image = image
                })
            }
        } else {
            data.getBytes(&array, length: count*MemoryLayout<UInt8>.size)
            totalImageData += array
        }
    }
    func imageFromByteArray(data: [UInt8], size: CGSize) -> UIImage? {
        guard data.count >= 8 else {
            print("data too small")
            return nil
        }
        
        let width  = Int(size.width)
        let height = Int(size.height)
        
        guard data.count >= width * height * 4 else {
//            print("data not large enough to hold \(width)x\(height)")
            return nil
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let msgData = NSMutableData(bytes: data, length: data.count)
        
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let bitmapContext = CGContext(data: msgData.mutableBytes, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width*4, space: colorSpace, bitmapInfo: bitmapInfo) else {
            print("context is nil")
            return nil
        }
        
        let dataPointer = bitmapContext.data?.assumingMemoryBound(to: UInt8.self)
        
        for index in 0 ..< width * height * 4  {
            dataPointer?[index] = data[index]
        }
        
        guard let cgImage = bitmapContext.makeImage() else {
            print("image is nil")
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}
