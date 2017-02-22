//
//  IntroPageView.swift
//  Education Platform
//
//  Created by Thanh-Tam Le on 12/2/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import UIKit

class IntroPageView: UIView {

    @IBOutlet weak var getStartedBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    let gradientView = GradientView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        getStartedBtn.setTitleColor(Global.colorMain, for: .normal)
        getStartedBtn.setTitleColor(Global.colorSelected, for: .highlighted)
//        getStartedBtn.insertSubview(gradientView, at: 0)
        getStartedBtn.layer.cornerRadius = 5
        getStartedBtn.isHidden = true
        getStartedBtn.clipsToBounds = true
        getStartedBtn.backgroundColor = UIColor.white
        
//        gradientView.autoPinEdge(toSuperviewEdge: .left)
//        gradientView.autoPinEdge(toSuperviewEdge: .right)
//        gradientView.autoPinEdge(toSuperviewEdge: .top)
        if DeviceType.IS_IPAD {
            getStartedBtn.autoSetDimension(.height, toSize: 65)
        }
        else {
            getStartedBtn.autoSetDimension(.height, toSize: 45)
        }
        
        if DeviceType.IS_IPHONE_5 {
            
        }
        
        getStartedBtn.setTitle("GET_STARTED".localized(), for: .normal)
    }
}
