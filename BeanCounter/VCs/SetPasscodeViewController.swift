//
//  SetPasscodeViewController.swift
//  BeanCounter
//
//  Created by Robert Horrion on 12/11/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit
import SVPinView

class SetPasscodeViewController: UIViewController, UIAdaptivePresentationControllerDelegate {

    enum userPermissionLevel {
        case setAdmin
        case setUser
        case getAdmin
        case getUser
        case changeAdmin
        case changeUser
    }
    
    var setPasscode: Bool?
    var userLevel: userPermissionLevel?
    
    //var sourceTableViewController: UITableViewController?
    var mainViewController: ViewController?
    var selectUsersTVController: SelectUsersTableViewController?
    var settingsTVController: SettingsTableViewController?
    
    @IBOutlet weak var passcodeView: SVPinView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Prevent dismissing the VC by swiping down to force the user to set a passcode
        self.isModalInPresentation = true
        
        passcodeView.becomeFirstResponderAtIndex = 0
        
        self.title = "Passcode ViewController"
        
        if userLevel! == .setAdmin {
            self.title = "Set the Admin Passcode"
        } else if userLevel == .setUser {
            self.title = "Set the User Passcode"
        } else if userLevel == .getAdmin {
            self.title = "Enter the Admin Passcode"
        } else if userLevel == .getUser {
            self.title = "Enter the User Passcode"
        } else if userLevel == .changeAdmin {
            self.title = "Change the Admin Passcode"
        } else if userLevel == .changeUser {
            self.title = "Change the User Passcode"
        }
        
        
        
        passcodeView.didFinishCallback = { pin in
            // Pin has been entered, handle calls here
            
            if self.userLevel! == .setAdmin {
                // Set the Admin passcode for the first time
                self.mainViewController?.setAdminPasscode(passcodeReturned: pin)
                self.dismiss(animated: true, completion: nil)
                
            } else if self.userLevel == .setUser {
                // Set the User passcode for the first time
                self.dismiss(animated: true, completion:{
                    
                })
                
            } else if self.userLevel == .getAdmin {
                // Access the Admin passcode
                self.dismiss(animated: true, completion:{
                    self.selectUsersTVController?.compareAdminPasscode(passcodeReturned: pin)
                })
                
            } else if self.userLevel == .getUser {
                // Access the User passcode
                self.dismiss(animated: true, completion:{
                    
                })
                
            } else if self.userLevel == .changeAdmin {
                // Change an existing Admin passcode
                self.dismiss(animated: true, completion:{
                    self.settingsTVController?.changeAdminPasscode(passcodeReturned: pin)
                })
                
            } else if self.userLevel == .changeUser {
                // Change an existing User passcode
                self.dismiss(animated: true, completion:{
                    
                })
            }
        }
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
