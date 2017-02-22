//
//  CommentViewController.swift
//  Education Platform
//
//  Created by Thanh-Tam Le on 1/5/17.
//  Copyright © 2017 Duy Cao. All rights reserved.
//

import UIKit
import Alamofire

protocol CommentDelegate {
    func post()
}

class CommentViewController: UIViewController {

    @IBOutlet weak var contentTV: UITextView!
    
    var news: NewsInterface!
    var user: RoleResult!
    var commentDelegate: CommentDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = UserDefaultManager.getInstance().getCurrentUser()
        
        //init navigation bar
        navigationController!.navigationBar.barTintColor = Global.colorMain
        navigationController!.navigationBar.tintColor = UIColor.white
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.navigationItem.title = "comment".localized()
        
        let doneBarBtnItem = UIBarButtonItem(title: "post".localized(), style: .done, target: self, action: #selector(postClicked))
        self.navigationItem.rightBarButtonItem = doneBarBtnItem
        
        let cancelBarBtnItem = UIBarButtonItem(title: "cancel".localized(), style: .done, target: self, action: #selector(cancelClicked))
        self.navigationItem.leftBarButtonItem = cancelBarBtnItem
        
        contentTV.keyboardType = .default
        contentTV.becomeFirstResponder()
    }

    func postClicked() {
        SwiftOverlays.showBlockingWaitOverlay()
        CommentService.postComment(newId: news.Id, userId: user.User.Id, comment: contentTV.text) { (success, message) in
            SwiftOverlays.removeAllBlockingOverlays()
            if success == true {
                self.contentTV.resignFirstResponder()
                self.commentDelegate.post()
                self.dismiss(animated: true, completion: nil)
            }
            else {
                Utils.showAlert(title: "error".localized(), message:  message, viewController: self)
            }
        }
    }
    
    func cancelClicked() {
        self.dismiss(animated: true, completion: nil)
    }
}
