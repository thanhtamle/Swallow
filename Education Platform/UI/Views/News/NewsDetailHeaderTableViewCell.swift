//
//  NewsDetailHeaderTableViewCell.swift
//  Education Platform
//
//  Created by Thanh-Tam Le on 2/10/17.
//  Copyright © 2017 Duy Cao. All rights reserved.
//

import UIKit

class NewsDetailHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "NewsDetailHeaderTableViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}
