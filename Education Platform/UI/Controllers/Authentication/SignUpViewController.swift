//
//  SignUpViewController.swift
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

class SignUpViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate {
    
    let scrollView = UIScrollView()
    let containerView = UIView()
    
    let iconImgView = UIImageView()
    let facebookButton = UIButton()
    let googleButton = UIButton()
    let orLabel = UILabel()
    let errorLabel = UILabel()
    let displayNameField = UITextField()
    let displayNameBorder = UIView()
    let userNameField = UITextField()
    let userNameBorder = UIView()
    let emailField = UITextField()
    let emailBorder = UIView()
    let passwordField = PasswordTextField()
    let passwordBorder = UIView()
    let confirmPasswordField = PasswordTextField()
    let confirmPasswordBorder = UIView()
    let signUpButton = UIButton()
    let oldUserButton = UIButton()
    
    let gradientView = GradientView()
    let gradientSignInBtn = GradientView()
    let socialLoginService = SocialLoginService()

    var constraintsAdded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socialLoginService.viewController = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
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
        
        displayNameField.delegate = self
        displayNameField.textColor = Global.colorSecond
        displayNameField.addSubview(displayNameBorder)
        displayNameField.returnKeyType = .next
        displayNameField.keyboardType = .namePhonePad
        displayNameField.inputAccessoryView = UIView()
        displayNameField.autocorrectionType = .no
        displayNameField.autocapitalizationType = .none
        displayNameBorder.backgroundColor = Global.colorBg
        
        userNameField.delegate = self
        userNameField.textColor = Global.colorSecond
        userNameField.addSubview(userNameBorder)
        userNameField.returnKeyType = .next
        userNameField.keyboardType = .namePhonePad
        userNameField.inputAccessoryView = UIView()
        userNameField.autocorrectionType = .no
        userNameField.autocapitalizationType = .none
        userNameBorder.backgroundColor = Global.colorBg
        
        emailField.delegate = self
        emailField.textColor = Global.colorSecond
        emailField.addSubview(emailBorder)
        emailField.returnKeyType = .next
        emailField.keyboardType = .emailAddress
        emailField.inputAccessoryView = UIView()
        emailField.autocorrectionType = .no
        emailField.autocapitalizationType = .none
        emailBorder.backgroundColor = Global.colorBg
        
        passwordField.delegate = self
        passwordField.textColor = Global.colorSecond
        passwordField.addSubview(passwordBorder)
        passwordField.returnKeyType = .next
        passwordField.keyboardType = .asciiCapable
        passwordField.inputAccessoryView = UIView()
        passwordField.autocorrectionType = .no
        passwordField.autocapitalizationType = .none
        passwordBorder.backgroundColor = Global.colorBg
        
        confirmPasswordField.delegate = self
        confirmPasswordField.textColor = Global.colorSecond
        confirmPasswordField.addSubview(confirmPasswordBorder)
        confirmPasswordField.returnKeyType = .go
        confirmPasswordField.keyboardType = .asciiCapable
        confirmPasswordField.inputAccessoryView = UIView()
        confirmPasswordField.autocorrectionType = .no
        confirmPasswordField.autocapitalizationType = .none
        confirmPasswordBorder.backgroundColor = Global.colorBg
        
        signUpButton.setTitleColor(UIColor.white, for: .normal)
        signUpButton.setTitleColor(Global.colorSelected, for: .highlighted)
        signUpButton.insertSubview(gradientSignInBtn, at: 0)
        signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        signUpButton.layer.cornerRadius = 5
        signUpButton.clipsToBounds = true
        
        oldUserButton.setTitleColor(Global.colorSelected, for: .normal)
        oldUserButton.setTitleColor(Global.colorSecond, for: .highlighted)
        oldUserButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        oldUserButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
        oldUserButton.sizeToFit()
        oldUserButton.clipsToBounds = true
        
        containerView.addSubview(iconImgView)
        containerView.addSubview(facebookButton)
        containerView.addSubview(googleButton)
        containerView.addSubview(orLabel)
        containerView.addSubview(errorLabel)
        containerView.addSubview(displayNameField)
        containerView.addSubview(userNameField)
        containerView.addSubview(emailField)
        containerView.addSubview(passwordField)
        containerView.addSubview(confirmPasswordField)
        containerView.addSubview(signUpButton)
        containerView.addSubview(oldUserButton)
        scrollView.addSubview(containerView)
        view.addSubview(scrollView)
        
        setLanguageRuntime()
        self.view.setNeedsUpdateConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setLanguageRuntime), name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
    }
    
    func setLanguageRuntime(){
        self.navigationItem.title = "sign_up".localized()
        facebookButton.setTitle("Facebook", for: .normal)
        googleButton.setTitle("Google", for: .normal)
        orLabel.text = "or".localized().uppercased()
        displayNameField.placeholder = "display_name".localized()
        userNameField.placeholder = "username".localized()
        emailField.placeholder = "email".localized()
        passwordField.placeholder = "new_password".localized()
        confirmPasswordField.placeholder = "confirm_new_password".localized()
        signUpButton.setTitle("register".localized(), for: .normal)
        oldUserButton.setTitle("already_have_an_account_login".localized(), for: .normal)
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
            
            displayNameField.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
            displayNameField.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
            displayNameField.autoPinEdge(.top, to: .bottom, of: errorLabel, withOffset: 1)
            displayNameField.autoSetDimension(.height, toSize: 40)
            
            displayNameBorder.autoPinEdge(toSuperviewEdge: .left)
            displayNameBorder.autoPinEdge(toSuperviewEdge: .right)
            displayNameBorder.autoPinEdge(toSuperviewEdge: .bottom)
            displayNameBorder.autoSetDimension(.height, toSize: 1)
            
            userNameField.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
            userNameField.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
            userNameField.autoPinEdge(.top, to: .bottom, of: displayNameField, withOffset: 10)
            userNameField.autoSetDimension(.height, toSize: 40)
            
            userNameBorder.autoPinEdge(toSuperviewEdge: .left)
            userNameBorder.autoPinEdge(toSuperviewEdge: .right)
            userNameBorder.autoPinEdge(toSuperviewEdge: .bottom)
            userNameBorder.autoSetDimension(.height, toSize: 1)
            
            emailField.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
            emailField.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
            emailField.autoPinEdge(.top, to: .bottom, of: userNameField, withOffset: 10)
            emailField.autoSetDimension(.height, toSize: 40)
            
            emailBorder.autoPinEdge(toSuperviewEdge: .left)
            emailBorder.autoPinEdge(toSuperviewEdge: .right)
            emailBorder.autoPinEdge(toSuperviewEdge: .bottom)
            emailBorder.autoSetDimension(.height, toSize: 1)
            
            passwordField.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
            passwordField.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
            passwordField.autoPinEdge(.top, to: .bottom, of: emailField, withOffset: 10)
            passwordField.autoSetDimension(.height, toSize: 40)
            
            passwordBorder.autoPinEdge(toSuperviewEdge: .left)
            passwordBorder.autoPinEdge(toSuperviewEdge: .right)
            passwordBorder.autoPinEdge(toSuperviewEdge: .bottom)
            passwordBorder.autoSetDimension(.height, toSize: 1)
            
            confirmPasswordField.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
            confirmPasswordField.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
            confirmPasswordField.autoPinEdge(.top, to: .bottom, of: passwordField, withOffset: 10)
            confirmPasswordField.autoSetDimension(.height, toSize: 40)
            
            confirmPasswordBorder.autoPinEdge(toSuperviewEdge: .left)
            confirmPasswordBorder.autoPinEdge(toSuperviewEdge: .right)
            confirmPasswordBorder.autoPinEdge(toSuperviewEdge: .bottom)
            confirmPasswordBorder.autoSetDimension(.height, toSize: 1)
            
            signUpButton.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
            signUpButton.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
            signUpButton.autoPinEdge(.top, to: .bottom, of: confirmPasswordField, withOffset: 20)
            signUpButton.autoSetDimension(.height, toSize: 50)
            
            gradientSignInBtn.autoPinEdge(toSuperviewEdge: .left)
            gradientSignInBtn.autoPinEdge(toSuperviewEdge: .right)
            gradientSignInBtn.autoPinEdge(toSuperviewEdge: .top)
            gradientSignInBtn.autoSetDimension(.height, toSize: 50)
            
            oldUserButton.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
            oldUserButton.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
            oldUserButton.autoPinEdge(.top, to: .bottom, of: signUpButton, withOffset: 10)
            oldUserButton.autoSetDimension(.height, toSize: 50)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshView()
    }
    
    func refreshView() {
        let height : CGFloat = 630
        containerView.autoSetDimension(.height, toSize: height)
        scrollView.contentSize = containerView.bounds.size
    }
    
    func loginFacebook() {
        socialLoginService.loginFacebook()
    }
    
    func loginGoogle() {
        socialLoginService.loginGoogle()
    }
    
    func signIn() {
        dismiss(animated: true, completion: nil)
    }
    
    func signUp() {
        if !checkInput(textField: displayNameField, value: displayNameField.text) {
            return
        }
        if !checkInput(textField: userNameField, value: userNameField.text) {
            return
        }
        if !checkInput(textField: emailField, value: emailField.text) {
            return
        }
        if !checkInput(textField: passwordField, value: passwordField.text) {
            return
        }
        if !checkInput(textField: confirmPasswordField, value: confirmPasswordField.text) {
            return
        }
        
        view.endEditing(true)
        
        let displayName = displayNameField.text!
        let userName = userNameField.text!
        let email = emailField.text!
        let password = passwordField.text!
        
        let userResult = UserResult()
        userResult.DisplayName = displayName
        userResult.UserName = userName
        userResult.Email = email
        userResult.Password = password
        
        SwiftOverlays.showBlockingWaitOverlay()
        AccountService.signup(userResult: userResult) { (success, message) in
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
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        _ = checkInput(textField: textField, value: newString)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case displayNameField:
            if checkInput(textField: textField, value: textField.text) {
                textField.resignFirstResponder()
                userNameField.becomeFirstResponder()
                return true
            }
        case userNameField:
            if checkInput(textField: textField, value: textField.text) {
                textField.resignFirstResponder()
                emailField.becomeFirstResponder()
                return true
            }
        case emailField:
            if checkInput(textField: textField, value: textField.text) {
                textField.resignFirstResponder()
                passwordField.becomeFirstResponder()
                return true
            }
        case passwordField:
            if checkInput(textField: textField, value: textField.text) {
                textField.resignFirstResponder()
                confirmPasswordField.becomeFirstResponder()
                return true
            }
        default:
            if checkInput(textField: textField, value: textField.text) {
                textField.resignFirstResponder()
                signUp()
                return true
            }
        }
        
        return false
    }

    func checkInput(textField: UITextField, value: String?) -> Bool {
        switch textField {
        case displayNameField:
            if value != nil && value!.isValidName() {
                errorLabel.text = nil
                textField.subviews.first?.backgroundColor = Global.colorBg
                return true
            }
            errorLabel.text = "invalid_display_name".localized()
            textField.subviews.first?.backgroundColor = UIColor.red.withAlphaComponent(0.8)
            
        case userNameField:
            if value != nil && value!.isValidAccount() {
                errorLabel.text = nil
                textField.subviews.first?.backgroundColor = Global.colorBg
                return true
            }
            errorLabel.text = "invalid_username".localized()
            textField.subviews.first?.backgroundColor = UIColor.red.withAlphaComponent(0.8)
            
        case emailField:
            if value != nil && value!.isValidEmail() {
                errorLabel.text = nil
                textField.subviews.first?.backgroundColor = Global.colorBg
                return true
            }
            errorLabel.text = "invalid_email_address".localized()
            textField.subviews.first?.backgroundColor = UIColor.red.withAlphaComponent(0.8)
            
        case passwordField:
            if value != nil && value!.isValidPassword() {
                errorLabel.text = nil
                textField.subviews.first?.backgroundColor = Global.colorBg
                return true
            }
            errorLabel.text = "invalid_new_password".localized()
            textField.subviews.first?.backgroundColor = UIColor.red.withAlphaComponent(0.8)
            
        default:
            if value != nil && passwordField.text != nil && value! == passwordField.text! {
                errorLabel.text = nil
                textField.subviews.first?.backgroundColor = Global.colorBg
                return true
            }
            errorLabel.text = "new_password_mismatch".localized()
            textField.subviews.first?.backgroundColor = UIColor.red.withAlphaComponent(0.8)
        }
        return false
    }
    
}
