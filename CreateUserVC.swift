//
//  CreateUserVC.swift
//  Demo-App-97Eats
//
//  Created by Jahanvi Trivedi on 16/01/22.
//

import UIKit
import CRNotifications
import SKActivityIndicatorView
import Alamofire

class CreateUserVC: UIViewController {

    // MARK: Properties
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: IBAction
    @IBAction func btnBack(_ sender: AnyObject)
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddUser(_ sender: AnyObject)
    {
        if(!checkValidation())
        {
            return
        }
        self.view.endEditing(true)
        
        if(isConnectedToNetwork() == true)
        {
            SKActivityIndicator.spinnerStyle(.spinningFadeCircle)
            SKActivityIndicator.show("loaderMessage".localized, userInteractionStatus: false)
            
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                self.callCreateUserApi()
            })
        }
        else
        {
            CRNotifications.showNotification(type:CRNotifications.info, title: "noInternet".localized, message: "noInternetMessage".localized, dismissDelay: 3)
        }
    }
    
    // MARK: functions
    // Call create user api
    func callCreateUserApi()
    {
        let parameters: [String: String] = ["firstName":txtFirstName.text!, "lastName": txtLastName.text!, "email": txtEmail.text!]
                
        callPostHeaderApi(fileName: postCreateUserUrl, parameters: parameters) { [self] responseObject, errorResponse in
            if(errorResponse == nil)
            {
                if let json = responseObject as? NSDictionary
                {
                    print(json)
                    
                    if let error = json.value(forKey: "error") as? String
                    {
                        CRNotifications.showNotification(type: CRNotifications.error, title: (json.value(forKeyPath: "data.email") as? String ?? "Something went wrong"), message: error, dismissDelay: 3)
                    }
                    else
                    {
                        CRNotifications.showNotification(type: CRNotifications.success, title: "Success", message: "User added successfully!!!", dismissDelay: 3)
                    }
                }
                else
                {
                    CRNotifications.showNotification(type: CRNotifications.error, title: "noResponse".localized, message: "noResponseMessage".localized, dismissDelay: 3)
                }
            }
            else
            {
                CRNotifications.showNotification(type: CRNotifications.error, title: "noResponse".localized, message: "noResponseMessage".localized, dismissDelay: 3)
            }
            SKActivityIndicator.dismiss()
        }
    }
    
    // Check textfield validation and show error message
    func checkValidation() -> Bool
    {
        let strFirstName = txtFirstName.text?.trim()
        let strLastName = txtLastName.text?.trim()
        let strEmail = txtEmail.text?.trim()
        let isEmailAddressValid = isValidEmailAddress(emailAddressString: txtEmail.text!)
        
        if(txtFirstName.text?.count == 0 || strFirstName?.count == 0)
        {
            CRNotifications.showNotification(type: CRNotifications.error, title: "Error!", message: "firstNameMessage".localized, dismissDelay: 3)
            txtFirstName.becomeFirstResponder()
            return false
        }
        else if(txtLastName.text?.count == 0 || strLastName?.count == 0)
        {
            CRNotifications.showNotification(type: CRNotifications.error, title: "Error!", message: "lastNameMessage".localized, dismissDelay: 3)
            txtLastName.becomeFirstResponder()
            return false
        }
        else if(txtEmail.text?.count == 0 || strEmail?.count == 0)
        {
            CRNotifications.showNotification(type: CRNotifications.error, title: "Error!", message: "emailMessage".localized, dismissDelay: 3)
            txtEmail.becomeFirstResponder()
            return false
        }
        else if !isEmailAddressValid
        {
            CRNotifications.showNotification(type: CRNotifications.error, title: "Error!", message: "validEmailMessage".localized, dismissDelay: 3)
            txtEmail.becomeFirstResponder()
            return false
        }
        return true
    }
}
