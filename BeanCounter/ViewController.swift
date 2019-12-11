//
//  ViewController.swift
//  BeanCounter
//
//  Created by Robert Horrion on 10/8/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit
import KeychainSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        // Set up and add Navigation Bar items
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Face Recognition", style: .plain, target: self, action: #selector(faceRecognition))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Show Payment Info", style: .plain, target: self, action: #selector(showPaymentInfoButton))
        
        
        // Check if a key exists in NSUserDefaults for CoffeePrice
        if UserDefaults.standard.object(forKey: "CoffeePrice") == nil {
            
            let alertController = UIAlertController(title: "Edit Coffee price", message: "Please enter a coffee price in €", preferredStyle: .alert)
            alertController.addTextField()

            let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned alertController] _ in
                let dataToSave = alertController.textFields![0].text
                
                if Int64(dataToSave!) != nil {
                    // value is numeric
                    // Save the entered data to UserDefaults (plist)
                    
                    
                    //TODO: Convert from Euros to cents before saving
                    
                    let userDefaults = UserDefaults.standard
                    userDefaults.set(dataToSave, forKey: "CoffeePrice")
                    
                } else {
                    // value is NOT numeric
                    // Prompt the user to enter a numeric value
                    let alert = UIAlertController(title: "Non-numeric value detected", message: "Please enter a numeric value with one decimal point only", preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Ok", style: .default)
                    alert.addAction(dismissAction)
                    self.present(alert, animated: true)
                }
            }
            
            alertController.addAction(saveAction)
            present(alertController, animated: true)
            
        }
        
        // Use Keychain to see if admin Passcode has been set. If not, prompt the user to set the admin passcode
        let keychain = KeychainSwift()
        let adminPasscode = keychain.get("adminPasscode")
        
        // Check if the string obtained from the keychain is empty or nil, if so perform the Segue to the setAdminPasscode VC
        if adminPasscode?.isEmpty == true || adminPasscode == nil {
            performSegue(withIdentifier: "setAdminPasscode", sender: self)
        }
        
    }

    @objc func showPaymentInfoButton() {
        performSegue(withIdentifier: "paymentInfoSegue", sender: self)
    }
    
    @objc func faceRecognition() {
        
        // Implement face recognition here
        
    }
    
    // MARK: - Keychain stuff
    
    func setAdminPasscode(passcodeReturned: String) {
        // A Passcode has been returned, handle the keychain request here
        
        // Beware of implications when uncommenting the next line: passcode can be read by attaching a debugger -> potential hazard
        //print("Attempting to save: " + passcodeReturned)
        let keychain = KeychainSwift()
        keychain.set(passcodeReturned, forKey: "adminPasscode")
        print("Saved new Admin passcode")
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        // Tell the destination ViewController that you're trying to change the admin passcode
        if segue.identifier == "setAdminPasscode" {
            if let navigationViewController = segue.destination as? UINavigationController {
                if let passcodeViewController = navigationViewController.viewControllers[0] as? SetPasscodeViewController {
                    passcodeViewController.userLevel = .setAdmin
                    passcodeViewController.mainViewController = self
                }
            }
        }
    }
    
    
    

}

