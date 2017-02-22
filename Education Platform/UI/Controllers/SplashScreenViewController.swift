//
//  SplashScreenViewController.swift
//  Education Platform
//
//  Created by Thanh-Tam Le on 2/14/17.
//  Copyright © 2017 Duy Cao. All rights reserved.
//

import UIKit
import FontAwesomeKit
import Localize_Swift

class SplashScreenViewController: UIViewController {

    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var iconImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.iconImgView.isHidden = false
            self.iconImgView.rotate360Degrees()
        })
        appNameLabel.text = "gaijinnavi".localized()
        appNameLabel.increaseSize()
        CATransaction.commit()
        
        let result = UserDefaultManager.getInstance().getIsInitApp()
        if result {
            let user = UserDefaultManager.getInstance().getCurrentUser()
            if user != nil {
                let currrentAccountType = UserDefaultManager.getInstance().getCurrentAccountType()
                let currentToken = UserDefaultManager.getInstance().getCurrentToken()
                if currrentAccountType == "facebook" {
                    AccountService.loginSocial(token: currentToken!, type: "facebook", fullName: user!.User.DisplayName, imageUrl: user!.User.Avatar, email: user!.User.Email) { (success, message) in
                        if success == true {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                let appDelegate  = UIApplication.shared.delegate as! AppDelegate
                                appDelegate.window?.rootViewController = MainViewController()
                            }
                        }
                        else {
                            self.navToSignInPage()
                        }
                    }
                }
                else if currrentAccountType == "google" {
                    AccountService.loginSocial(token: currentToken!, type: "google", fullName: user!.User.DisplayName, imageUrl: user!.User.Avatar, email: user!.User.Email) { (success, message) in
                        if success == true {
                            let appDelegate  = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.window?.rootViewController = MainViewController()
                        }
                        else {
                            self.navToSignInPage()
                        }
                    }
                }
                else {
                    AccountService.login(username: user!.User.UserName, password: user!.User.Password) { (success, message) in
                        if success == true {
                            self.present(MainViewController(), animated: true, completion: nil)
                        }
                        else {
                            self.navToSignInPage()
                        }
                    }
                }
            }
            else {
                navToSignInPage()
            }
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let appDelegate  = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = IntroViewController()
            }
        }
    }
    
    func navToSignInPage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let nav = UINavigationController(rootViewController: SignInViewController())
            let appDelegate  = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = nav
        }
    }
}
