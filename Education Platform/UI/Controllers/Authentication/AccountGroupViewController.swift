//
//  AccountGroupViewController.swift
//  Education Platform
//
//  Created by Thanh-Tam Le on 12/5/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import UIKit
import Localize_Swift

class AccountGroupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setLanguageRuntime()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setLanguageRuntime), name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
    }
    
    func setLanguageRuntime(){
        
    }
}
