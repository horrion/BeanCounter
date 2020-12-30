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
                               "Face Authentication",
                               "Passcode protect Face Recognition",
                               "Matching Coefficient"]
    
    struct userStruct {
        let firstName: String
        let lastName: String
        let eMail: String
        let balance: Int64
    }
    
    var usersArray = [userStruct]()
    
    var managedObjectsArray = [NSManagedObject?]()
    
    var sourceViewController: AdminTableViewController?
    
    var sliderAlert: UIAlertController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

        let onOffCell = tableView.dequeueReusableCell(withIdentifier: "blankCell", for: indexPath)
        
        
        for index in indexPath {
            cell.textLabel?.text = settingsInTableView[index]
        }
        
        if indexPath.row == 4 {
            // onOffCell for setting faceAuth
            onOffCell.textLabel?.text = settingsInTableView[indexPath.row]
            
            let switchView = UISwitch(frame: .zero)

            let authIsActivated = UserDefaults.standard.bool(forKey: "faceAuth")
            if authIsActivated == true {
                switchView.setOn(true, animated: true)
            } else {
                switchView.setOn(false, animated: true)
            }
            
            // Detect which switch Changed
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(self.switchChanged(sender:)), for: .valueChanged)
            onOffCell.accessoryView = switchView
            
            return onOffCell
            
        }
        if indexPath.row == 5 {
            
            // onOffCell for setting faceRecPasscode
            onOffCell.textLabel?.text = settingsInTableView[indexPath.row]
            
            let switchViewForFaceRecPasscode = UISwitch(frame: .zero)

            let recIsActivated = UserDefaults.standard.bool(forKey: "faceRecPasscode")
            if recIsActivated == true {
                switchViewForFaceRecPasscode.setOn(true, animated: true)
            } else {
                switchViewForFaceRecPasscode.setOn(false, animated: true)
            }
            
            // Detect which switch Changed
            switchViewForFaceRecPasscode.tag = indexPath.row
            switchViewForFaceRecPasscode.addTarget(self, action: #selector(self.faceRecognitionPasscodeSwitchChanged(sender:)), for: .valueChanged)
            onOffCell.accessoryView = switchViewForFaceRecPasscode
            
            return onOffCell
            
        }
        
//        if indexPath.row == 6 {
//            // Slider cell to change the matching Coefficient threshold
//
//            //UserDefaults.standard.double(forKey: "matchingCoefficient")
//            //UserDefaults.standard.set(1.0, forKey: "matchingCoefficient")
//        }
        
        
        else {
            // indexPath.row != 4
            return cell
        }

        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            // Edit Payment QR code
            // Show a UIAlertController to let the user modify the saved payment info used to generate the QR code
            
            let alertController = UIAlertController(title: "Set payment info", message: nil, preferredStyle: .alert)
            alertController.addTextField()

            // Get data from UserDefaults
            let userDefaults = UserDefaults.standard
            let paymentInfoBeforeChangeString = userDefaults.string(forKey: "PaymentInfo")
            
            alertController.textFields![0].text = paymentInfoBeforeChangeString
            
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
            
            let alertController = UIAlertController(title: "Edit Coffee price", message: "Please enter a coffee price in €", preferredStyle: .alert)
            alertController.addTextField()
            alertController.textFields![0].keyboardType = .decimalPad
            
            // Get data from UserDefaults
            let userDefaults = UserDefaults.standard
            let coffeePriceBeforeChangeString = userDefaults.string(forKey: "CoffeePrice")
            
            // Create a fractional (monetary value) by dividing cent value by 100
            let divisor = NSDecimalNumber(value: 100)
            let decimalValue = NSDecimalNumber(string: coffeePriceBeforeChangeString).dividing(by: divisor)
            
            alertController.textFields![0].text = decimalValue.stringValue
            
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
        
        if indexPath.row == 6 {
            
            // Get the Slider values from UserDefaults
            let defaultSliderValue = UserDefaults.standard.double(forKey: "matchingCoefficient")
            
            // Create a Slider and fit within the extra message spaces
            // Add the Slider to a Subview of the sliderAlert
            let slider = UISlider(frame:CGRect(x: 10, y: 150, width: 250, height: 40))
            slider.minimumValue = 0.1
            slider.maximumValue = 1.0
            slider.value = Float(defaultSliderValue)
            slider.isContinuous = true
            slider.addTarget(self, action: #selector(updateAlertMessage), for: .valueChanged)
            
            //create the Alert message with extra return spaces
            sliderAlert = UIAlertController(title: "Matching Coefficient threshold", message: "A lower matching coefficient value means the face needs to be a more exact match to be accepted as such\n \nthreshold: " + String(slider.value) + "\n \n", preferredStyle: .alert)
            
            sliderAlert!.view.addSubview(slider)

            //OK button action
            let sliderAction = UIAlertAction(title: "OK", style: .default, handler: { (result : UIAlertAction) -> Void in
                UserDefaults.standard.set(Double(slider.value), forKey: "matchingCoefficient")
                print("Updated matching coefficient: " + String(slider.value))
            })
            
            //Cancel button action
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            
            //Add buttons to sliderAlert
            sliderAlert!.addAction(sliderAction)
            sliderAlert!.addAction(cancelAction)
            
            //present the sliderAlert message
            self.present(sliderAlert!, animated: true, completion: nil)
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
    
    @objc func updateAlertMessage(sender: UISlider) {
        sliderAlert?.message = "A lower matching coefficient value means the face needs to be a more exact match to be accepted as such\n \nthreshold: " + String(sender.value) + "\n \n"
    }
    
    @objc func switchChanged(sender : UISwitch){

        // The next line is for debugging
        //print("The switch is \(sender.isOn ? "ON" : "OFF")")
        
        if sender.isOn == true {
            UserDefaults.standard.set(true, forKey: "faceAuth")
        } else {
            UserDefaults.standard.set(false, forKey: "faceAuth")
        }
    }
    
    @objc func faceRecognitionPasscodeSwitchChanged(sender : UISwitch){

        // The next line is for debugging
        //print("The switch is \(sender.isOn ? "ON" : "OFF")")
        
        if sender.isOn == true {
            UserDefaults.standard.set(true, forKey: "faceRecPasscode")
        } else {
            UserDefaults.standard.set(false, forKey: "faceRecPasscode")
        }
    }
    
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
            
            // Create a fractional (monetary value) by dividing cent value by 100
            let divisor = NSDecimalNumber(value: 100)
            let decimalValue = NSDecimalNumber(value: userEntry.balance).dividing(by: divisor)
            
            // Set up a NumberFormatter to get monetary values
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            
            // TODO: Use the next 2 lines for shipping product, always sets format to the one defined in device settings
            formatter.locale = NSLocale.current
            //formatter.string(from: decimalValue)
            
            // Use this for debugging
            //formatter.locale = Locale(identifier: "de_DE")
            
            let balanceString = formatter.string(from: decimalValue)!
            
            // create new line from variables in CSV file
            let newLine = "\(userIDString),\"\(String(describing: balanceString))\"\n"
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
    
    func resetAllBalances() {
        //Resets all balances. Only affects the balance in user entity, use this for debugging only. This does not reset the balance in the TransactionsForUser entity
        
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
                    self.sourceViewController?.loadDataFromCoreData()
                    
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
