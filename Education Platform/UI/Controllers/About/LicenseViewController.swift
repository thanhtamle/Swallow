//
//  LicenseViewController.swift
//  Education Platform
//
//  Created by Thanh-Tam Le on 1/18/17.
//  Copyright © 2017 Duy Cao. All rights reserved.
//

import UIKit
import Localize_Swift

class LicenseViewController: UIViewController {

    var constraintsAdded = false
    let textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.isEditable = false
        var resourceURL: URL!
        let languageId = UserDefaultManager.getInstance().getCurrentLanguage()
        if languageId == 0 {
            resourceURL = Bundle.main.url(forResource: "Policy_en", withExtension: "rtf")!
        }
        else if languageId == 1 {
            resourceURL = Bundle.main.url(forResource: "Policy_ja", withExtension: "rtf")!
        }
        else if languageId == 2 {
            resourceURL = Bundle.main.url(forResource: "Policy_en", withExtension: "rtf")!
        }
        else {
            resourceURL = Bundle.main.url(forResource: "Policy_vi", withExtension: "rtf")!
        }
        
        try! textView.attributedText = NSAttributedString(url: resourceURL, options: [:], documentAttributes: nil)
        
        view.addSubview(textView)
        
        setLanguageRuntime()
        self.view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        if !constraintsAdded {
            constraintsAdded = true
            textView.autoPinEdgesToSuperviewEdges()
        }
        super.updateViewConstraints()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setLanguageRuntime), name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
        
        self.edgesForExtendedLayout = UIRectEdge.left
        self.extendedLayoutIncludesOpaqueBars = true
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func setLanguageRuntime() {
        self.title = "privacy_policy".localized()
    }
}
