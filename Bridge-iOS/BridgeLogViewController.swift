//
//  BridgeLogViewController.swift
//  Bridge
//
//  Created by Blake Tsuzaki on 4/3/17.
//  Copyright © 2017 PRAHVI. All rights reserved.
//

import UIKit
import Bridge

class BridgeLogViewController: UIViewController {

    @IBOutlet var textView: UITextView?
    @IBOutlet var typeSelector: UISegmentedControl?
    
    internal var messageObjects = [BridgeDebugMessage]()
    internal var errorObjects: [BridgeDebugMessage] {
        return messageObjects.filter({ message -> Bool in
            return message.type == .error
        })
    }
    internal enum DebugDisplayType {
        case all, error
    }
    internal var selectedType: DebugDisplayType = .all {
        didSet { refreshLogList() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(handleLogNotification), name: Constants.bridgeNotification, object: nil)
        
        typeSelector?.addTarget(self, action: #selector(typeSelectorTapped), for: .valueChanged)
        textView?.text = ""
        logLoop(withDelay: 1)
    }
    
    @objc func typeSelectorTapped() {
        guard let selected = typeSelector?.selectedSegmentIndex else
        { return }
        switch selected {
        case 1: selectedType = .error
        case 0: fallthrough
        default:
            selectedType = .all
        }
    }
    
    @objc func handleLogNotification(_ notification: Notification) {
        if let message = notification.object as? BridgeDebugMessage {
            messageObjects.append(message)
        }
    }
    
    func logLoop(withDelay delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now()+delay) {
            self.refreshLogList()
            self.logLoop(withDelay: delay)
        }
    }
    
    func refreshLogList() {
        DispatchQueue.main.async {
            switch self.selectedType {
            case .error:
                self.textView?.text = self.errorObjects.reduce("", { (text, object) -> String in
                    return object.message + "\n\n" + text
                })
            case .all:
                self.textView?.text = self.messageObjects.reduce("", { (text, object) -> String in
                    return object.message + "\n\n" + text
                })
            }
        }
    }
}
