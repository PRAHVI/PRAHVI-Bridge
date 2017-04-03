//
//  BridgeLogViewController.swift
//  Bridge
//
//  Created by Blake Tsuzaki on 4/3/17.
//  Copyright © 2017 PRAHVI. All rights reserved.
//

import UIKit

class BridgeLogViewController: UIViewController {
    
    @IBOutlet weak var logTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        logTextView.text = ""
    }
}
