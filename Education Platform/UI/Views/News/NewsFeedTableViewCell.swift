//
//  NewsFeedTableViewCell.swift
//  Education Platform
//
//  Created by Thanh-Tam Le on 12/6/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import UIKit
import FontAwesomeKit
import Kingfisher

class NewsFeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var authorIconBtn: UIButton!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoImgView: UIImageView!
//    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var readMoreLabel: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    
    var isLike = false
    var photoImgViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.containerView.layer.cornerRadius = 3.0
        self.containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        self.containerView.layer.shadowOffset = .init(width: 0.0, height: 0.0)
        self.containerView.layer.shadowOpacity = 0.3
        
        authorIconBtn.imageView?.contentMode = .scaleAspectFill
        authorIconBtn.layer.cornerRadius = 20
        authorIconBtn.clipsToBounds = true
        
        photoImgView.kf.indicatorType = .activity
        photoImgView.backgroundColor = Global.colorBg
        photoImgView.contentMode = .scaleAspectFill
        photoImgView.clipsToBounds = true
        photoImgView.layer.cornerRadius = 3
        
//        let heartOIcon = FAKFontAwesome.heartOIcon(withSize: 30)
//        heartOIcon?.addAttribute(NSForegroundColorAttributeName, value: Global.colorMain)
//        let heartOImg  = heartOIcon?.image(with: CGSize(width: 30, height: 30))
//        likeBtn.setImage(heartOImg, for: .normal)
//        likeBtn.tintColor = Global.colorMain
//        likeBtn.addTarget(self, action: #selector(likeBtnClicked), for: .touchUpInside)
//        likeBtn.imageView?.contentMode = .scaleAspectFit
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setData(url: String) {
        photoImgView.kf.setImage(with: URL(string: url)!, placeholder: nil, options: [.transition(ImageTransition.fade(1))],
            progressBlock: { receivedSize, totalSize in
                                        print("\(receivedSize)/\(totalSize)")
        }, completionHandler: { image, error, cacheType, imageURL in
            if url == "empty_photo" {
                self.photoImgViewHeight.constant = 10
                return
            }
            else {
                self.photoImgView!.image = image
                let height = self.photoImgView.frame.width / self.photoImgView.image!.size.width * self.photoImgView.image!.size.height
                self.photoImgViewHeight.constant = height
                print(height)
            }
        })
    }
    
    func likeBtnClicked() {
//        if isLike {
//            let heartOIcon = FAKFontAwesome.heartOIcon(withSize: 30)
//            heartOIcon?.addAttribute(NSForegroundColorAttributeName, value: Global.colorMain)
//            let heartOImg  = heartOIcon?.image(with: CGSize(width: 30, height: 30))
//            likeBtn.setImage(heartOImg, for: .normal)
//            isLike = false
//        }
//        else {
//            let heartIcon = FAKFontAwesome.heartIcon(withSize: 30)
//            heartIcon?.addAttribute(NSForegroundColorAttributeName, value: Global.colorMain)
//            let heartImg  = heartIcon?.image(with: CGSize(width: 30, height: 30))
//            likeBtn.setImage(heartImg, for: .normal)
//            isLike = true
//        }
    }
}
