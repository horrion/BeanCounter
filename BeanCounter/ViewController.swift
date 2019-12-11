//
//  ViewController.swift
//  BeanCounter
//
//  Created by Robert Horrion on 10/8/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit

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
            
            let dismissAction = UIAlertAction(title: "Cancel", style: .default)
            alertController.addAction(dismissAction)
            alertController.addAction(saveAction)
            present(alertController, animated: true)
            
        }
        
    }

    @objc func showPaymentInfoButton() {
        performSegue(withIdentifier: "paymentInfoSegue", sender: self)
    }
    
    @objc func faceRecognition() {
        
        // Implement face recognition here
        
    }

}

