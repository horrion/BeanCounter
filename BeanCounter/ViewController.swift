//
//  ViewController.swift
//  BeanCounter
//
//  Created by Robert Horrion on 10/8/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit
import CoreData
import KeychainSwift

class ViewController: UIViewController {

    @IBOutlet weak var numberOfCoffeeCupsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        // Set up and add Navigation Bar items
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Face Recognition", style: .plain, target: self, action: #selector(faceRecognition))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Show Payment Info", style: .plain, target: self, action: #selector(showPaymentInfoButton))
        
        
        checkIfFirstLaunch()
        reloadStatsLabel()
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
    
    
    
    
    // MARK: - First time setup
    
    func checkIfFirstLaunch() {
        
        // TODO: Sync user prefs here on every start of the app
        
        
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore != true  {
            // This is the first time ever the app is launched. Set the key and go through the first launch config
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            
            setNewCoffeePrice()
            
            
            
            //TODO: sync user prefs here
        }
    }
    
    func setNewCoffeePrice() {
        
        // Check if a key exists in NSUserDefaults for CoffeePrice
        if UserDefaults.standard.object(forKey: "CoffeePrice") == nil {
            
            let alertController = UIAlertController(title: "Edit Coffee price", message: "Please enter a coffee price in €", preferredStyle: .alert)
            alertController.addTextField()
            alertController.textFields![0].keyboardType = .decimalPad
            
            let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned alertController] _ in
                let dataToSave = alertController.textFields![0].text
                
                if Float(dataToSave!) != nil {
                    // value is numeric
                    // Save the entered data to UserDefaults (plist)
                    
                    
                    // Create a fractional (monetary value) by dividing cent value by 100
                    let divisor = NSDecimalNumber(value: 100)
                    let decimalValue = NSDecimalNumber(string: dataToSave).multiplying(by: divisor)
                    
                    let intToSave = decimalValue.int64Value
                    
                    print("saving value: " + String(intToSave))
                    
                    let userDefaults = UserDefaults.standard
                    userDefaults.set(intToSave, forKey: "CoffeePrice")
                    
                    self.setNewAdminPasscode()
                    
                } else {
                    // value is NOT numeric
                    // Prompt the user to enter a numeric value
                    let alert = UIAlertController(title: "Non-numeric value detected", message: "Please enter a numeric value with one decimal point only", preferredStyle: .alert)
                    //let dismissAction = UIAlertAction(title: "Ok", style: .default)
                    let dismissAction = UIAlertAction(title: "Ok", style: .default)
                    alert.addAction(dismissAction)
                    self.present(alert, animated: true)
                }
            }
            
            alertController.addAction(saveAction)
            present(alertController, animated: true)
            
        }
    }
    
    func setNewAdminPasscode() {
        // Ask the user to set a new adminPasscode on first App launch
        performSegue(withIdentifier: "setAdminPasscode", sender: self)
    }
    
    
    // MARK: - CoreData handler // Reload stats
    func reloadStatsLabel() {
        
        // Create context for context info stored in AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
                
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Transactions")
        
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let date = Date()
        let calendar = Calendar.current
        
        let dateString = String(calendar.component(.year, from: date)+calendar.component(.month, from: date)+calendar.component(.day, from: date))
        
        var resultStringForDate: Int?
        
        
        // Iterate through all NSManagedObjects in NSFetchRequestResult
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                
                let dateStringFromCoreData = data.value(forKey: "date") as! String
                
                if dateStringFromCoreData == dateString {
                    
                    // Set string for use in label
                    resultStringForDate = (data.value(forKey: "numberOfTransactions") as! Int)
                    print("number of transactions found: " + String(resultStringForDate!))
                }
                
          }
            
        } catch {
            print("failed to fetch data from context")
        }
        
        // Modify the label depending on whether a result has been found in CoreData (== Cups have been consumed today)
        if resultStringForDate != nil {
            numberOfCoffeeCupsLabel.text = "Total Coffee cups today: " + String(resultStringForDate!)
        } else {
            numberOfCoffeeCupsLabel.text = "Total Coffee cups today: 0"
        }
        
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
        // Tell the destination ViewController that you're trying to access the admin passcode
        if segue.identifier == "selectUserSegue" {
            if let navigationViewController = segue.destination as? UINavigationController {
                if let selectUsersViewController = navigationViewController.viewControllers[0] as? SelectUsersTableViewController {
                    selectUsersViewController.mainViewController = self
                }
            }
        }
    }
    
}

