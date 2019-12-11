//
//  SettingsTableViewController.swift
//  BeanCounter
//
//  Created by Robert Horrion on 10/15/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit
import CoreData
import KeychainSwift

class SettingsTableViewController: UITableViewController {

    let settingsInTableView = ["Edit Payment QR code",
                               "Change Admin Passcode",
                               "Export to CSV",
                               "Edit Coffee price",
                               "Reset all balances"]
    
    struct userStruct {
        let firstName: String
        let lastName: String
        let eMail: String
        let balance: Int64
    }
    
    var usersArray = [userStruct]()
    
    var managedObjectsArray = [NSManagedObject?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsInTableView.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellWithDisclosureIndicator", for: indexPath)

        for index in indexPath {
            cell.textLabel?.text = settingsInTableView[index]
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            // Edit Payment QR code
            // Show a UIAlertController to let the user modify the saved payment info used to generate the QR code
            
            let alertController = UIAlertController(title: "Set payment info", message: nil, preferredStyle: .alert)
            alertController.addTextField()

            let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned alertController] _ in
                let dataToSave = alertController.textFields![0].text
                
                // Save the entered String to UserDefaults (plist)
                let userDefaults = UserDefaults.standard
                userDefaults.set(dataToSave, forKey: "PaymentInfo")
            }

            let dismissAction = UIAlertAction(title: "Cancel", style: .default)
            alertController.addAction(dismissAction)
            alertController.addAction(saveAction)
            
            present(alertController, animated: true)
        }
        if indexPath.row == 1 {
            // Change Admin Passcode
            
            // Just perform the Segue, the logic happens in 
            performSegue(withIdentifier: "changeAdminPasscodeSegue", sender: self)
            
        }
        if indexPath.row == 2 {
            // Export to CSV
            readFromCoreData()
            
        }
        if indexPath.row == 3 {
            //Edit Coffee price
            
            let alertController = UIAlertController(title: "Edit Coffee price", message: nil, preferredStyle: .alert)
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
        if indexPath.row == 4 {
            // Reset all balances (to 0)
            
            
            // Set up the alertController to ask the user if they'd really, actually like to reset all balances before doing so
            let alertController = UIAlertController(title: "Reset all balances?", message: "Do you really want to reset all balances?", preferredStyle: .alert)

            // The deleteAction contains all the code to reset the balances, should the user choose to do so
            let deleteAction = UIAlertAction(title: "Yes", style: .destructive) { action in
                
                    // Create context for context info stored in AppDelegate
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                            
                    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
                            
                    request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
                    
                    
                    // Check if number of registered users is greater than 0, if not ask user to create new user
                    var numberOfObjects: Int = 0
                            
                    do {
                        numberOfObjects = try context.count(for: request)
                    } catch {
                        print("failed to fetch data")
                    }
                            
                    // Ask user to create a new user if no userdata is present
                    if numberOfObjects == 0 {
                        let alert = UIAlertController(title: "No users found", message: "No users were found, please register a user first", preferredStyle: .alert)
                        let dismissAction = UIAlertAction(title: "Ok", style: .default)
                        alert.addAction(dismissAction)
                        self.present(alert, animated: true)
                    }
                        
                     
                    // Reset Array to empty Array
                    self.managedObjectsArray.removeAll()
                            
                    // Iterate through all NSManagedObjects in NSFetchRequestResult and store them in the managedObjectsArray
                    request.returnsObjectsAsFaults = false
                    do {
                        let result = try context.fetch(request)
                        for data in result as! [NSManagedObject] {
                                    
                            // New method, just save the whole NSManagedObject, then read from it later on
                            self.managedObjectsArray.insert(data, at: self.managedObjectsArray.count)
                        }
                                
                        } catch {
                                
                            print("failed to fetch data from context")
                        }
                    
                    for users in self.managedObjectsArray {
                        
                        // Read old values first and log them
                        let firstNameFromCoreData = users?.value(forKey: "firstname") as! String
                        let lastNameFromCoreData = users?.value(forKey: "lastname") as! String
                        let eMailFromCoreData = users?.value(forKey: "email") as! String
                        let balanceBeforeReset = users?.value(forKey: "balanceInCents") as! Int64
                        
                        
                        // Print to Console for Debugging
                        print("First Name: " + firstNameFromCoreData)
                        print("Last Name: " + lastNameFromCoreData)
                        print("eMail: " + eMailFromCoreData)
                        print("Balance before reset: " + String(balanceBeforeReset))
                        print(" ")
                        
                        users?.setValue(0, forKey: "balanceInCents")
                        
                    }
                    
                    // Save new User Info to CoreData
                    do {
                       try context.save()
                        // Data was successfully saved
                        print("successfully saved data")
                        
                      } catch {
                        // Failed to write to the database
                        
                        print("Couldn't save to CoreData")
                        
                        let alert = UIAlertController(title: "Failed Database Operation", message: "Failed to write to the Database", preferredStyle: .alert)
                        let dismissAction = UIAlertAction(title: "Ok", style: .default)
                        alert.addAction(dismissAction)
                        self.present(alert, animated: true)
                    }
                    
                    
                    // Print new balance after changes have been saved, just for validation
                    for user in self.managedObjectsArray {
                        let balanceAfterChanges = user?.value(forKey: "balanceInCents") as! Int64
                        print("balance after changes: " + String(balanceAfterChanges))
                    }
                    
                    
                    
                    
                }
                
                let dismissAction = UIAlertAction(title: "Cancel", style: .default)
                alertController.addAction(dismissAction)
                alertController.addAction(deleteAction)
                present(alertController, animated: true)
                
        }
    }
    
    // MARK: - Keychain stuff
    
    func changeAdminPasscode(passcodeReturned: String) {
        // A Passcode has been returned, handle the keychain request here
        
        // Beware of implications when uncommenting the next line: passcode can be read by attaching a debugger -> potential hazard
        //print("Attempting to save: " + passcodeReturned)
        let keychain = KeychainSwift()
        keychain.set(passcodeReturned, forKey: "adminPasscode")
        
        let alert = UIAlertController(title: "Saved!", message: "The new passcode has been successfully saved!", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(dismissAction)
        self.present(alert, animated: true)
        
        print("Saved new Admin passcode")
    }
    

    // MARK: - helper functions
    
    func readFromCoreData() {
        
        // Create context for context info stored in AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        // Check if number of registered users is greater than 0, if not display an alert
            var numberOfObjects: Int = 0
            
            do {
                numberOfObjects = try context.count(for: request)
            } catch {
                print("failed to fetch data")
            }
            
            
            if numberOfObjects == 0 {
                // Display an alert here telling the user that no data is present
                
                let alert = UIAlertController(title: "No user data present", message: "No user data could be found. Please create a new user!", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(dismissAction)
                self.present(alert, animated: true)
                
            }
        
        
        // Reset Array to empty Array
        usersArray.removeAll()
        
        // Iterate through all NSManagedObjects in NSFetchRequestResult
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                // Create variables for values from NSManagedObject
                let firstNameFromCoreData = data.value(forKey: "firstname") as! String
                let lastNameFromCoreData = data.value(forKey: "lastname") as! String
                let eMailFromCoreData = data.value(forKey: "email") as! String
                let balanceFromCoreData = data.value(forKey: "balanceInCents") as! Int64
                
                // insert all variables into struct, NSManagedObject can be discarded at this point; All required data has been gathered
                usersArray.insert(userStruct.init(firstName: firstNameFromCoreData,
                                                  lastName: lastNameFromCoreData,
                                                  eMail: eMailFromCoreData,
                                                  balance: balanceFromCoreData), at: usersArray.count)
          
            }
            
            // After the data has been written to the array, write it to the csv file
            writeBalancesToCSV()
            
        } catch {
            
            print("failed to fetch data from context")
        }
        
    }


    func writeBalancesToCSV() {
        
        // Set fileName for the .csv file here
        let fileName = "BeanCounter - " + Date().description + ".csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
                   
        var csvText = "User,Balance\n"
                   
        // iterate through all values in usersArray and write each one to the csv file
        for userEntry in usersArray {
                       
            // Create variables from array data
            let firstName = userEntry.firstName
            let lastName = userEntry.lastName
            let eMail = userEntry.eMail
                       
            // Create User ID String (Name + Email) and balance String
            let userIDString = firstName + " " + lastName + " (" + eMail + ")"
            let balanceString = String(userEntry.balance) + "€"
                       
            //TODO: convert from cent to euro value before saving
            
            // create new line from variables in CSV file
            let newLine = "\(userIDString),\(balanceString)\n"
            csvText.append(contentsOf: newLine)
        }
        
        do {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                            
            let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
            vc.modalPresentationStyle = UIModalPresentationStyle.popover
            vc.popoverPresentationController?.sourceView = self.view
            
            vc.excludedActivityTypes = [
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToVimeo,
                UIActivity.ActivityType.postToTencentWeibo,
                UIActivity.ActivityType.postToTwitter,
                UIActivity.ActivityType.postToFacebook,
                UIActivity.ActivityType.openInIBooks
            ]
            present(vc, animated: true, completion: nil)
            
        } catch {
            
            // an error has occurred
            print("Failed to create file")
            print("\(error)")
        }
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        // Tell the destination ViewController that you're trying to change the admin passcode
        if segue.identifier == "changeAdminPasscodeSegue" {
            if let navigationViewController = segue.destination as? UINavigationController {
                if let passcodeViewController = navigationViewController.viewControllers[0] as? SetPasscodeViewController {
                    passcodeViewController.userLevel = .changeAdmin
                    passcodeViewController.settingsTVController = self
                }
            }
        }
    }
    

}
