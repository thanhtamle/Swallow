//
//  SignInViewController.swift
//  Education Platform
//
//  Created by Thanh-Tam Le on 12/5/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import UIKit
import Localize_Swift
import PasswordTextField
import FontAwesomeKit
import Alamofire
import FacebookLogin
import FacebookCore
import Google
import JSONModel

class SignInViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate {
    
    let scrollView = UIScrollView()
    let containerView = UIView()
    
    let iconImgView = UIImageView()
    let facebookButton = UIButton()
    let googleButton = UIButton()
    let orLabel = UILabel()
    let errorLabel = UILabel()
    let userNameField = UITextField()
    let userNameBorder = UIView()
    let passwordField = PasswordTextField()
    let passwordBorder = UIView()
    let forgotButton = UIButton()
    let signInButton = UIButton()
    let newUserButton = UIButton()
    
    let gradientView = GradientView()
    let gradientSignInBtn = GradientView()
    let socialLoginService = SocialLoginService()
    
    var constraintsAdded = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //init navigation bar
        navigationController!.navigationBar.barTintColor = Global.colorMain
        navigationController!.navigationBar.tintColor = UIColor.white
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        navigationController!.navigationBar.addSubview(gradientView)
        
        self.view.backgroundColor = Global.colorHeader
        self.view.tintColor = Global.colorSecond
        self.view.addTapToDismiss()
        
        iconImgView.clipsToBounds = true
        iconImgView.image = UIImage(named: "citynow")
        
        let facebookIcon = FAKFoundationIcons.socialFacebookIcon(withSize: 30)
        facebookIcon?.addAttribute(NSForegroundColorAttributeName, value: UIColor.white)
        facebookButton.setImage(facebookIcon?.image(with: CGSize(width: 30, height: 30)), for: .normal)
        facebookIcon?.addAttribute(NSForegroundColorAttributeName, value: Global.colorSecond)
        facebookButton.setImage(facebookIcon?.image(with: CGSize(width: 30, height: 30)), for: .highlighted)
        facebookButton.setTitleColor(UIColor.white, for: .normal)
        facebookButton.setTitleColor(Global.colorSecond, for: .highlighted)
        facebookButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        facebookButton.addTarget(self, action: #selector(loginFacebook), for: .touchUpInside)
        facebookButton.backgroundColor = Global.colorFacebook
        facebookButton.layer.cornerRadius = 5
        facebookButton.clipsToBounds = true
        
        let googleIcon = FAKFoundationIcons.socialGooglePlusIcon(withSize: 30)
        googleIcon?.addAttribute(NSForegroundColorAttributeName, value: UIColor.white)
        googleButton.setImage(googleIcon?.image(with: CGSize(width: 30, height: 30)), for: .normal)
        googleIcon?.addAttribute(NSForegroundColorAttributeName, value: Global.colorSecond)
        googleButton.setImage(googleIcon?.image(with: CGSize(width: 30, height: 30)), for: .highlighted)
        googleButton.setTitleColor(UIColor.white, for: .normal)
        googleButton.setTitleColor(Global.colorSecond, for: .highlighted)
        googleButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        googleButton.addTarget(self, action: #selector(loginGoogle), for: .touchUpInside)
        googleButton.backgroundColor = Global.colorGoogle
        googleButton.layer.cornerRadius = 5
        googleButton.clipsToBounds = true
        
        orLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        orLabel.textAlignment = .center
        orLabel.textColor = Global.colorSelected
        orLabel.adjustsFontSizeToFitWidth = true
        
        errorLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        errorLabel.textAlignment = .center
        errorLabel.textColor = UIColor.red.withAlphaComponent(0.7)
        errorLabel.adjustsFontSizeToFitWidth = true
        
        userNameField.delegate = self
        userNameField.textColor = Global.colorSecond
        userNameField.addSubview(userNameBorder)
        userNameField.returnKeyType = .next
        userNameField.keyboardType = .default
        userNameField.inputAccessoryView = UIView()
        userNameField.autocorrectionType = .no
        userNameField.autocapitalizationType = .none
        userNameBorder.backgroundColor = Global.colorBg
        
        passwordField.delegate = self
        passwordField.textColor = Global.colorSecond
        passwordField.addSubview(passwordBorder)
        passwordField.returnKeyType = .go
        passwordField.keyboardType = .asciiCapable
        passwordField.inputAccessoryView = UIView()
        passwordField.autocorrectionType = .no
        passwordField.autocapitalizationType = .none
        passwordBorder.backgroundColor = Global.colorBg
        
        forgotButton.setTitleColor(Global.colorSelected, for: .normal)
        forgotButton.setTitleColor(Global.colorSecond, for: .highlighted)
        forgotButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
        forgotButton.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside)
        forgotButton.sizeToFit()
        forgotButton.contentHorizontalAlignment = .right
        
        signInButton.setTitleColor(UIColor.white, for: .normal)
        signInButton.setTitleColor(Global.colorSelected, for: .highlighted)
        signInButton.insertSubview(gradientSignInBtn, at: 0)
        signInButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        signInButton.layer.cornerRadius = 5
        signInButton.clipsToBounds = true
        
        newUserButton.setTitleColor(Global.colorSelected, for: .normal)
        newUserButton.setTitleColor(Global.colorSecond, for: .highlighted)
        newUserButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        newUserButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
        newUserButton.sizeToFit()
        newUserButton.clipsToBounds = true
        
        containerView.addSubview(iconImgView)
        containerView.addSubview(facebookButton)
        containerView.addSubview(googleButton)
        containerView.addSubview(orLabel)
        containerView.addSubview(errorLabel)
        containerView.addSubview(userNameField)
        containerView.addSubview(passwordField)
        containerView.addSubview(forgotButton)
        containerView.addSubview(signInButton)
        containerView.addSubview(newUserButton)
        scrollView.addSubview(containerView)
        view.addSubview(scrollView)

        setLanguageRuntime()
        self.view.setNeedsUpdateConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setLanguageRuntime), name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
        
        socialLoginService.viewController = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        Utils.setStatusBarBackgroundColor(color: Global.colorStatus)
    }
    
    
    func setLanguageRuntime(){
        self.navigationItem.title = "sign_in".localized()
        facebookButton.setTitle("Facebook", for: .normal)
        googleButton.setTitle("Google", for: .normal)
        orLabel.text = "or".localized().uppercased()
        userNameField.placeholder = "username".localized()
        passwordField.placeholder = "password".localized()
        signInButton.setTitle("sign_in".localized(), for: .normal)
        newUserButton.setTitle("do_you_have_an_account_create".localized(), for: .normal)
        forgotButton.setTitle("forgot_password".localized() + "?", for: .normal)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if !constraintsAdded {
            constraintsAdded = true
            
            scrollView.autoPinEdgesToSuperviewEdges()
            
            containerView.autoPinEdgesToSuperviewEdges()
            containerView.autoMatch(.width, to: .width, of: view)
            
            gradientView.autoPinEdge(toSuperviewEdge: .left)
            gradientView.autoPinEdge(toSuperviewEdge: .right)
            gradientView.autoPinEdge(toSuperviewEdge: .top)
            gradientView.autoSetDimension(.height, toSize: 44)
            
            iconImgView.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
            iconImgView.autoSetDimensions(to: CGSize(width: 100, height: 100))
            iconImgView.autoAlignAxis(toSuperviewAxis: .vertical)
            
            facebookButton.autoPinEdge(.top, to: .bottom, of: iconImgView, withOffset: 20)
            facebookButton.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
            facebookButton.autoSetDimension(.height, toSize: 40)
            let facebookWidth = facebookButton.autoMatch(.width, to: .width, of: view, withMultiplier: 0.5)
            facebookWidth.constant = -15
            
            googleButton.autoPinEdge(.top, to: .bottom, of: iconImgView, withOffset: 20)
            googleButton.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
            googleButton.autoSetDimension(.height, toSize: 40)
            googleButton.autoPinEdge(.left, to: .right, of: facebookButton, withOffset: 10)
            
            orLabel.autoPinEdge(toSuperviewEdge: .left)
            orLabel.autoPinEdge(toSuperviewEdge: .right)
            orLabel.autoPinEdge(.top, to: .bottom, of: facebookButton, withOffset: 10)
            orLabel.autoSetDimension(.height, toSize: 30)
            
            errorLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
            errorLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
            errorLabel.autoPinEdge(.top, to: .bottom, of: orLabel, withOffset: 1)
            errorLabel.autoSetDimension(.height, toSize: 20)
            
            userNameField.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
            userNameField.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
            userNameField.autoPinEdge(.top, to: .bottom, of: errorLabel, withOffset: 1)
            userNameField.autoSetDimension(.height, toSize: 40)
            
            userNameBorder.autoPinEdge(toSuperviewEdge: .left)
            userNameBorder.autoPinEdge(toSuperviewEdge: .right)
            userNameBorder.autoPinEdge(toSuperviewEdge: .bottom)
            userNameBorder.autoSetDimension(.height, toSize: 1)
            
            passwordField.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
            passwordField.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
            passwordField.autoPinEdge(.top, to: .bottom, of: userNameField, withOffset: 10)
            passwordField.autoSetDimension(.height, toSize: 40)
            
            passwordBorder.autoPinEdge(toSuperviewEdge: .left)
            passwordBorder.autoPinEdge(toSuperviewEdge: .right)
            passwordBorder.autoPinEdge(toSuperviewEdge: .bottom)
            passwordBorder.autoSetDimension(.height, toSize: 1)
            
            forgotButton.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
            forgotButton.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
            forgotButton.autoPinEdge(.top, to: .bottom, of: passwordField)
            forgotButton.autoSetDimension(.height, toSize: 30)
            
            signInButton.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
            signInButton.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
            signInButton.autoPinEdge(.top, to: .bottom, of: forgotButton, withOffset: 20)
            signInButton.autoSetDimension(.height, toSize: 50)
            
            gradientSignInBtn.autoPinEdge(toSuperviewEdge: .left)
            gradientSignInBtn.autoPinEdge(toSuperviewEdge: .right)
            gradientSignInBtn.autoPinEdge(toSuperviewEdge: .top)
            gradientSignInBtn.autoSetDimension(.height, toSize: 50)
            
            newUserButton.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
            newUserButton.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
            newUserButton.autoPinEdge(.top, to: .bottom, of: signInButton, withOffset: 10)
            newUserButton.autoSetDimension(.height, toSize: 50)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshView()
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)?){
        if self.presentedViewController != nil {
            super.dismiss(animated: flag, completion: completion)
        }
    }
    
    func refreshView() {
        let height : CGFloat = 510
        containerView.autoSetDimension(.height, toSize: height)
        scrollView.contentSize = CGSize(width: view.frame.width, height: height)
    }
    
    func loginFacebook() {
        socialLoginService.loginFacebook()
    }
    
    func loginGoogle() {
        socialLoginService.loginGoogle()
    }
    
    func signIn() {
        if !checkInput(textField: userNameField, value: userNameField.text) {
            return
        }
        if !checkInput(textField: passwordField, value: passwordField.text) {
            return
        }
        
        view.endEditing(true)
        
        let username = userNameField.text!
        let password = passwordField.text!
        
        SwiftOverlays.showBlockingWaitOverlay()
        AccountService.login(username: username, password: password) { (success, message) in
            if success == true {
                UserDefaultManager.getInstance().setCurrentAccountType(value: "normal")
                self.present(MainViewController(), animated:true, completion:nil)
            }
            else {
                self.errorLabel.text = message
            }
            SwiftOverlays.removeAllBlockingOverlays()
        }
    }
    
    func loginFinished(success: Bool) {
        print(success)
    }
    
    func signUp() {
        let nav = UINavigationController(rootViewController: SignUpViewController())
        self.present(nav, animated:true, completion:nil)
    }
    
    func forgotPassword() {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        _ = checkInput(textField: textField, value: newString)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case userNameField:
            if checkInput(textField: textField, value: textField.text) {
                textField.resignFirstResponder()
                passwordField.becomeFirstResponder()
                return true
            }
        default:
            if checkInput(textField: textField, value: textField.text) {
                textField.resignFirstResponder()
                signIn()
                return true
            }
        }
        return false
    }
    
    func checkInput(textField: UITextField, value: String?) -> Bool {
        switch textField {
        case userNameField:
            if value != nil && value!.isValidAccount() {
                errorLabel.text = nil
                textField.subviews.first?.backgroundColor = Global.colorBg
                return true
            }
            errorLabel.text = "invalid_username".localized()
            textField.subviews.first?.backgroundColor = UIColor.red.withAlphaComponent(0.8)
            
        default:
            if value != nil && value!.isValidPassword() {
                errorLabel.text = nil
                textField.subviews.first?.backgroundColor = Global.colorBg
                return true
            }
            errorLabel.text = "invalid_password".localized()
            textField.subviews.first?.backgroundColor = UIColor.red.withAlphaComponent(0.8)
            
        }
        return false
    }
}
