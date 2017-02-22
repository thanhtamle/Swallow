//
//  ProfileViewController.swift
//  Education Platform
//
//  Created by Thanh-Tam Le on 12/27/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import UIKit
import Localize_Swift
import FontAwesomeKit
import Alamofire
import STPopup
import INSPhotoGallery

class ProfileViewController: UIViewController, UITextFieldDelegate, FollowServiceDelegate, FollowUserDelegate, CameraDelegate {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var displayNameField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var followedBtn: UIButton!
    @IBOutlet weak var iconProfileImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var birthDateField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var headerImgView: UIImageView!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var calendarBtn: UIButton!
    
    let gradientView = GradientView()
    
    let displayNameBorder = UIView()
    let accountBorder = UIView()
    let emailBorder = UIView()
    let phoneBorder = UIView()
    let birthDateBorder = UIView()
    let addressBorder = UIView()
    let descriptionBorder = UIView()

    var constraintsAdded = false
    var user: RoleResult!
    var photos: [INSPhotoViewable] = [INSPhotoViewable]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Global.colorHeader
        self.view.tintColor = Global.colorSecond
        self.view.addTapToDismiss()
        
        scrollView.showsVerticalScrollIndicator = false
        user = UserDefaultManager.getInstance().getCurrentUser()
        
        followingBtn.setTitleColor(Global.colorGray, for: .normal)
        followingBtn.setTitleColor(Global.colorSecond, for: .highlighted)
        followingBtn.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        followingBtn.titleLabel?.font = UIFont(name: (followingBtn.titleLabel?.font.fontName)!, size: 14)
        followingBtn.clipsToBounds = true
        followingBtn.backgroundColor = UIColor.clear
        followingBtn.titleLabel?.lineBreakMode = .byWordWrapping
        followingBtn.titleLabel?.textAlignment = .center
        followingBtn.setTitle("0\n" + "following".localized(), for: .normal)
        followingBtn.addTarget(self, action: #selector(showUsersFollowing), for: .touchUpInside)

        followedBtn.setTitleColor(Global.colorGray, for: .normal)
        followedBtn.setTitleColor(Global.colorSecond, for: .highlighted)
        followedBtn.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        followedBtn.titleLabel?.font = UIFont(name: (followedBtn.titleLabel?.font.fontName)!, size: 14)
        followedBtn.clipsToBounds = true
        followedBtn.backgroundColor = UIColor.clear
        followedBtn.titleLabel?.lineBreakMode = .byWordWrapping
        followedBtn.titleLabel?.textAlignment = .center
        followedBtn.setTitle("0\n" + "follower".localized(), for: .normal)
        followedBtn.addTarget(self, action: #selector(showUsersFollowed), for: .touchUpInside)
        
        updateBtn.layer.cornerRadius = 5
        updateBtn.clipsToBounds = true
        updateBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: (updateBtn.titleLabel?.font.pointSize)!)
        updateBtn.addTarget(self, action: #selector(updateBtnClicked), for: .touchUpInside)
        updateBtn.insertSubview(gradientView, at: 0)
        
        iconProfileImgView.layer.cornerRadius = 45
        iconProfileImgView.layer.borderColor = UIColor.white.cgColor
        iconProfileImgView.layer.borderWidth = 5
        iconProfileImgView.clipsToBounds = true
        iconProfileImgView.contentMode = .scaleAspectFill
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(iconProfileBtnClicked))
        iconProfileImgView.isUserInteractionEnabled = true
        iconProfileImgView.addGestureRecognizer(tapGestureRecognizer)
        
        if user.User.Avatar != "" {
            iconProfileImgView.kf.setImage(with: URL(string: user.User.Avatar))
            createPhotoFromURL(url: user.User.Avatar)
        }
        else {
            let image = UIImage(named: "ic_user")
            iconProfileImgView.image = image
            createPhotoFromImage(image: image!)
        }
    
        errorLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        errorLabel.textAlignment = .center
        errorLabel.textColor = UIColor.red.withAlphaComponent(0.7)
        errorLabel.adjustsFontSizeToFitWidth = true
        
        addressLabel.text = user.User.Address
        nameLabel.text = user.User.DisplayName
        
        displayNameField.delegate = self
        displayNameField.textColor = Global.colorSecond
        displayNameField.returnKeyType = .next
        displayNameField.keyboardType = .default
        displayNameField.inputAccessoryView = UIView()
        displayNameField.autocorrectionType = .no
        displayNameField.autocapitalizationType = .none
        displayNameBorder.backgroundColor = Global.colorBg
        displayNameField.addSubview(displayNameBorder)
        displayNameField.text = user.User.DisplayName
        displayNameField.isEnabled = false
        
        accountField.delegate = self
        accountField.textColor = Global.colorSecond
        accountField.returnKeyType = .next
        accountField.keyboardType = .default
        accountField.inputAccessoryView = UIView()
        accountField.autocorrectionType = .no
        accountField.autocapitalizationType = .none
        accountBorder.backgroundColor = Global.colorBg
        accountField.addSubview(accountBorder)
        accountField.text = user.User.UserName
        accountField.isEnabled = false

        emailField.delegate = self
        emailField.textColor = Global.colorSecond
        emailField.returnKeyType = .next
        emailField.keyboardType = .emailAddress
        emailField.inputAccessoryView = UIView()
        emailField.autocorrectionType = .no
        emailField.autocapitalizationType = .none
        emailField.isEnabled = false
        emailBorder.backgroundColor = Global.colorBg
        emailField.addSubview(emailBorder)
        emailField.text = user.User.Email

        phoneField.delegate = self
        phoneField.textColor = Global.colorGray
        phoneField.returnKeyType = .next
        phoneField.keyboardType = .phonePad
        phoneField.inputAccessoryView = UIView()
        phoneField.autocorrectionType = .no
        phoneField.autocapitalizationType = .none
        phoneBorder.backgroundColor = Global.colorBg
        phoneField.addSubview(phoneBorder)
        phoneField.text = user.User.Phone

        birthDateField.delegate = self
        birthDateField.textColor = Global.colorSecond
        birthDateField.returnKeyType = .next
        birthDateField.keyboardType = .default
        birthDateField.inputAccessoryView = UIView()
        birthDateField.autocorrectionType = .no
        birthDateField.autocapitalizationType = .none
        birthDateField.isEnabled = false
        birthDateBorder.backgroundColor = Global.colorBg
        birthDateField.addSubview(birthDateBorder)
        birthDateField.text = user.User.DOB

        addressField.delegate = self
        addressField.textColor = Global.colorSecond
        addressField.returnKeyType = .next
        addressField.keyboardType = .default
        addressField.inputAccessoryView = UIView()
        addressField.autocorrectionType = .no
        addressField.autocapitalizationType = .none
        addressBorder.backgroundColor = Global.colorBg
        addressField.addSubview(addressBorder)
        addressField.text = user.User.Address
        
        descriptionField.delegate = self
        descriptionField.textColor = Global.colorSecond
        descriptionField.returnKeyType = .done
        descriptionField.keyboardType = .default
        descriptionField.inputAccessoryView = UIView()
        descriptionField.autocorrectionType = .no
        descriptionField.autocapitalizationType = .none
        descriptionBorder.backgroundColor = Global.colorBg
        descriptionField.addSubview(descriptionBorder)
        descriptionField.text = user.User.Biography
        
        let calendarIcon = FAKFontAwesome.calendarIcon(withSize: 30)
        calendarIcon?.addAttribute(NSForegroundColorAttributeName, value: Global.colorMain)
        let calendarImg  = calendarIcon?.image(with: CGSize(width: 30, height: 30))
        calendarBtn.setImage(calendarImg, for: .normal)
        calendarBtn.tintColor = Global.colorMain
        calendarBtn.addTarget(self, action: #selector(calenderBtnClicked), for: .touchUpInside)
        calendarBtn.imageView?.contentMode = .scaleAspectFit
        
        setLanguageRuntime()
        self.view.setNeedsUpdateConstraints()
    }
    
    func createPhotoFromURL(url: String) {
        self.photos.removeAll()
        let url_go = URL.init(string: url)
        let tmppho = INSPhoto(imageURL: url_go, thumbnailImageURL: url_go)
        self.photos.append(tmppho)
    }
    
    func createPhotoFromImage(image: UIImage) {
        self.photos.removeAll()
        let tmppho = INSPhoto(image: image, thumbnailImage: image)
        self.photos.append(tmppho)
    }
    
    override func updateViewConstraints() {
        if !constraintsAdded {
            constraintsAdded = true
            
            gradientView.autoSetDimension(.height, toSize: 45)
            gradientView.autoPinEdge(toSuperviewEdge: .bottom)
            gradientView.autoPinEdge(toSuperviewEdge: .left)
            gradientView.autoPinEdge(toSuperviewEdge: .right)
            
            displayNameBorder.autoSetDimension(.height, toSize: 1)
            displayNameBorder.autoPinEdge(toSuperviewEdge: .bottom)
            displayNameBorder.autoPinEdge(toSuperviewEdge: .left)
            displayNameBorder.autoPinEdge(toSuperviewEdge: .right)
            
            accountBorder.autoSetDimension(.height, toSize: 1)
            accountBorder.autoPinEdge(toSuperviewEdge: .bottom)
            accountBorder.autoPinEdge(toSuperviewEdge: .left)
            accountBorder.autoPinEdge(toSuperviewEdge: .right)
            
            emailBorder.autoSetDimension(.height, toSize: 1)
            emailBorder.autoPinEdge(toSuperviewEdge: .bottom)
            emailBorder.autoPinEdge(toSuperviewEdge: .left)
            emailBorder.autoPinEdge(toSuperviewEdge: .right)
            
            phoneBorder.autoSetDimension(.height, toSize: 1)
            phoneBorder.autoPinEdge(toSuperviewEdge: .bottom)
            phoneBorder.autoPinEdge(toSuperviewEdge: .left)
            phoneBorder.autoPinEdge(toSuperviewEdge: .right)
            
            birthDateBorder.autoSetDimension(.height, toSize: 1)
            birthDateBorder.autoPinEdge(toSuperviewEdge: .bottom)
            birthDateBorder.autoPinEdge(toSuperviewEdge: .left)
            birthDateBorder.autoPinEdge(toSuperviewEdge: .right)
            
            addressBorder.autoSetDimension(.height, toSize: 1)
            addressBorder.autoPinEdge(toSuperviewEdge: .bottom)
            addressBorder.autoPinEdge(toSuperviewEdge: .left)
            addressBorder.autoPinEdge(toSuperviewEdge: .right)
            
            descriptionBorder.autoSetDimension(.height, toSize: 1)
            descriptionBorder.autoPinEdge(toSuperviewEdge: .bottom)
            descriptionBorder.autoPinEdge(toSuperviewEdge: .left)
            descriptionBorder.autoPinEdge(toSuperviewEdge: .right)
        }
        super.updateViewConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setLanguageRuntime), name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
    }
    
    
    func setLanguageRuntime(){
        self.navigationItem.title = "profile".localized()
        displayNameField.placeholder = "display_name".localized()
        accountField.placeholder = "username".localized()
        emailField.placeholder = "email".localized()
        phoneField.placeholder = "phone_number".localized()
        birthDateField.placeholder = "birth_date".localized()
        addressField.placeholder = "address".localized()
        descriptionField.placeholder = "description".localized()
        updateBtn.setTitle("update".localized(), for: .normal)
        
        FollowService.getFollowingList(userId: user.User.Id, followServiceDelegate: self)
        FollowService.getFollowedList(userId: user.User.Id, followServiceDelegate: self)
    }
    
    func getFollowingListOwnerFinished(success: Bool, message: String, result: [UserResult]) {
    }
    
    func getFollowingListFinished(success: Bool, message: String, result: [UserResult]) {
        if success {
            self.followingBtn.setTitle(String(result.count) + "\n" + "following".localized(), for: .normal)
        }
    }
    
    func getFollowedListFinished(success: Bool, message: String, result: [UserResult]) {
        if success {
            self.followedBtn.setTitle(String(result.count) + "\n" + "follower".localized(), for: .normal)
        }
    }
    
    func followFinised(success: Bool, message: String) {
 
    }
    
    func unFollowFinised(success: Bool, message: String) {

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
     
        headerImgView.addBlurEffect()
    }
    
    func iconProfileBtnClicked() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let takePhotoAction = UIAlertAction(title: "take_photos".localized(), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let cameraViewController = CameraViewController()
            cameraViewController.cameraDelegate = self
            self.present(cameraViewController, animated: false, completion: nil)
        })
        
        let photoLibraryAction = UIAlertAction(title: "photo_library".localized(), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let cameraViewController = CameraViewController()
            cameraViewController.cameraDelegate = self
            cameraViewController.pickImage = 1
            self.present(cameraViewController, animated: false, completion: nil)
        })
        
        let viewProfilePictureAction = UIAlertAction(title: "view_profile_picture".localized(), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            let galleryPreview = INSPhotosViewController(photos: self.photos)
            let overlayViewBar = (galleryPreview.overlayView as! INSPhotosOverlayView).navigationBar
            
            overlayViewBar?.autoPin(toTopLayoutGuideOf: galleryPreview, withInset: 0.0)
            
            galleryPreview.view.backgroundColor = UIColor.black
            galleryPreview.view.tintColor = Global.colorMain
            self.present(galleryPreview, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })

        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(photoLibraryAction)
        optionMenu.addAction(viewProfilePictureAction)
        optionMenu.addAction(cancelAction)
        optionMenu.popoverPresentationController?.sourceView = self.iconProfileImgView
        optionMenu.popoverPresentationController?.sourceRect = self.iconProfileImgView.bounds
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func tookPicture(url: String) {
        user.User.Avatar = url
        print(url)
        iconProfileImgView.kf.setImage(with: URL(string: url))
    }
    
    func updateBtnClicked() {
        
        if !checkInput(textField: displayNameField, value: displayNameField.text) {
            return
        }
        
        if !checkInput(textField: phoneField, value: phoneField.text) {
            return
        }
        
        if !checkInput(textField: birthDateField, value: birthDateField.text) {
            return
        }
        
        if !checkInput(textField: addressField, value: addressField.text) {
            return
        }
        
        if !checkInput(textField: descriptionField, value: descriptionField.text) {
            return
        }
        
        view.endEditing(true)
     
        SwiftOverlays.showBlockingWaitOverlay()
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        let body = ["Id": user.User.Id, "UserName": user.User.UserName, "Password": user.User.Password, "DisplayName": displayNameField.text!, "Email": user.User.Email, "Biography": descriptionField.text!, "DOB": birthDateField.text!, "Gender": 1, "Phone": phoneField.text!, "Address": addressField.text!, "RoleId": user.User.RoleId, "Active" : 1, "Avatar" : user.User.Avatar, "Token": user.User.Token] as [String : Any]
        print(body)

        Alamofire.request(Global.baseURL + "api/user/registerOrUpdate", method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                SwiftOverlays.removeAllBlockingOverlays()
                let responseResult = ResponseResult(data: response.data!)
                if responseResult.success == 0 {
                    self.errorLabel.text = "could_not_update_profile_please_try_again".localized()
                }
                else {
                    self.nameLabel.text = self.displayNameField.text
                    self.addressLabel.text = self.addressField.text
                    let userResult = UserResult(data: response.data!)
                    self.user.User = userResult
                    UserDefaultManager.getInstance().setCurrentUser(roleResult: self.user)
                    Utils.showAlert(title: "profile".localized(), message: "update_profile_successfully".localized(), viewController: self)
                }
            case .failure(_):
                SwiftOverlays.removeAllBlockingOverlays()
                self.errorLabel.text = "could_not_update_profile_please_try_again".localized()
            }
        }
    }
    
    var fromDate : NSDate? {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            if fromDate != nil {
                birthDateField.text = dateFormatter.string(from: fromDate! as Date)
            } else {
                birthDateField.text = user.User.DOB
            }
        }
    }
    
    func calenderBtnClicked(sender: UIButton) {
        phoneField.resignFirstResponder()
        addressField.resignFirstResponder()
        descriptionField.resignFirstResponder()

        var date = NSDate()
        if(fromDate != nil) {
            date = fromDate!
        }
        
        var datePickerViewController : UIViewController!
        datePickerViewController = AIDatePickerController.picker(with: date as Date!, selectedBlock: {
            newDate in
            self.fromDate = newDate as NSDate?
            datePickerViewController.dismiss(animated: true, completion: nil)
        }, cancel: {
            datePickerViewController.dismiss(animated: true, completion: nil)
        }) as! UIViewController
        
        present(datePickerViewController, animated: true, completion: nil)
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
                phoneField.becomeFirstResponder()
                return true
            }
        case phoneField:
            if checkInput(textField: textField, value: textField.text) {
                textField.resignFirstResponder()
                addressField.becomeFirstResponder()
                return true
            }
        case addressField:
            if checkInput(textField: textField, value: textField.text) {
                textField.resignFirstResponder()
                descriptionField.becomeFirstResponder()
                return true
            }
        default:
            if checkInput(textField: textField, value: textField.text) {
                textField.resignFirstResponder()
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
            
        case phoneField:
            if value != nil && value!.isValidPhone() {
                errorLabel.text = nil
                textField.subviews.first?.backgroundColor = Global.colorBg
                return true
            }
            errorLabel.text = "invalid_phone".localized()
            textField.subviews.first?.backgroundColor = UIColor.red.withAlphaComponent(0.8)
       
        case birthDateField:
            if value != nil && value!.isValidName() {
                errorLabel.text = nil
                birthDateBorder.backgroundColor = Global.colorBg
                return true
            }
            errorLabel.text = "invalid_birth_date".localized()
            birthDateBorder.backgroundColor = UIColor.red.withAlphaComponent(0.8)
            
        case addressField:
            if value != nil && value!.isValidAddress() {
                errorLabel.text = nil
                textField.subviews.first?.backgroundColor = Global.colorBg
                return true
            }
            errorLabel.text = "invalid_address".localized()
            textField.subviews.first?.backgroundColor = UIColor.red.withAlphaComponent(0.8)

        default:
            if value != nil && value!.isValidDescription() {
                errorLabel.text = nil
                textField.subviews.first?.backgroundColor = Global.colorBg
                return true
            }
            errorLabel.text = "password_description".localized()
            textField.subviews.first?.backgroundColor = UIColor.red.withAlphaComponent(0.8)
        }
        return false
    }
    
    var viewPopupController: STPopupController!
    
    func showUsersFollowing() {
        STPopupNavigationBar.appearance().tintColor = UIColor.white
        STPopupNavigationBar.appearance().barTintColor = Global.colorMain
        STPopupNavigationBar.appearance().barStyle = .default
        
        if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
            STPopupNavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.white]
        }
        
        let viewController = UsersFollowingViewController()
        viewController.user = user.User
        viewController.followUserDelegate = self
        viewPopupController = STPopupController(rootViewController: viewController)
        viewPopupController.containerView.layer.cornerRadius = 4
        viewPopupController.present(in: self)
    }
    
    func showUsersFollowed() {
        STPopupNavigationBar.appearance().tintColor = UIColor.white
        STPopupNavigationBar.appearance().barTintColor = Global.colorMain
        STPopupNavigationBar.appearance().barStyle = .default
        
        if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
            STPopupNavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.white]
        }
        
        let viewController = UsersFollowedViewController()
        viewController.user = user.User
        viewController.followUserDelegate = self
        viewPopupController = STPopupController(rootViewController: viewController)
        viewPopupController.containerView.layer.cornerRadius = 4
        viewPopupController.present(in: self)
    }
    
    func userProfileClicked(user: UserResult) {
        viewPopupController.dismiss()
        let nav = UserDetailViewController()
        nav.user = user
        self.navigationController?.pushViewController(nav, animated: true)
    }
}
