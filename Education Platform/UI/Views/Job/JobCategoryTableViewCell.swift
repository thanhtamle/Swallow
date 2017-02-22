//
//  JobCategoryTableViewCell.swift
//  Education Platform
//
//  Created by Thanh-Tam Le on 2/20/17.
//  Copyright © 2017 Duy Cao. All rights reserved.
//

import UIKit

class JobCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var backgroundCardView: UIView!
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundCardView.layer.cornerRadius = 3.0
        self.backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        self.backgroundCardView.layer.shadowOffset = .init(width: 0.0, height: 0.0)
        self.backgroundCardView.layer.shadowOpacity = 0.3
        
        self.iconImgView.clipsToBounds = true
        self.iconImgView.layer.masksToBounds = true        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    

    func bindingData() {
        
    }
}
