//
//  NewFeatureIntroView.swift
//  Education Platform
//
//  Created by nquan on 2/9/17.
//  Copyright © 2017 Duy Cao. All rights reserved.
//

import UIKit

class NewFeatureIntroView: UIView {
    @IBOutlet weak var featureLabel: UILabel!
    @IBOutlet weak var buttonNext: UIButton!
    
    @IBOutlet weak var featureImage: UIImageView!
    
    let gradientView = GradientView()
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttonNext.setTitleColor(UIColor.white, for: .normal)
        buttonNext.setTitleColor(Global.colorSelected, for: .highlighted)
        buttonNext.insertSubview(gradientView, at: 0)
        buttonNext.layer.cornerRadius = 5
        buttonNext.isHidden = true
        buttonNext.clipsToBounds = true
        
        buttonNext.isHidden = true
 
        gradientView.autoPinEdge(toSuperviewEdge: .left)
        gradientView.autoPinEdge(toSuperviewEdge: .right)
        gradientView.autoPinEdge(toSuperviewEdge: .top)
        gradientView.autoSetDimension(.height, toSize: 40)
        
        if DeviceType.IS_IPHONE
        {
            featureLabel.font = featureLabel.font.withSize(18)

        }else {
            featureLabel.font = featureLabel.font.withSize(26)

        }
        
        
    }
}
