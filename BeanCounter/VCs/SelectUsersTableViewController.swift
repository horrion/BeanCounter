//
//  SelectUsersTableViewController.swift
//  BeanCounter
//
//  Created by Robert Horrion on 10/8/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit
import CoreData
import KeychainSwift

class SelectUsersTableViewController: UITableViewController {
    
    var managedObjectsArray = [NSManagedObject?]()
    var transactionsManagedObjectsArray = [NSManagedObject?]()
    
    var unlockedForUser: IndexPath?
    var selectedUser: IndexPath?
    
    var imageForSelectedUser: UIImage?
    
    var mainViewController: ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Users"
        
        // Add the barButtonItems (buttons in the NavigationBar)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Admin", style: .plain, target: self, action: #selector(loadAdminVC))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(loadAddNewUserVC))
        
        // Load all data from CoreData and refresh the TableView
        loadDataFromCoreData()
        loadTransactionsFromCoreData()
        
        print("Number of users in Array: " + String(managedObjectsArray.count))
        
        // Prep for Email function that executes every 24 hours
        let userDefaults = UserDefaults.standard
        let lastExecuted = userDefaults.value(forKey: "lastRefresh") as! Date
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour]
        let differenceBetweenLastExecutionAndNow = Int(formatter.string(from: lastExecuted, to: Date())!)
        
        print("Difference between now and then: " + String(differenceBetweenLastExecutionAndNow!))

        
        // This runs every 24 hours
        if differenceBetweenLastExecutionAndNow! >= 24 {
            // Set current time as the last time the function was executed
            userDefaults.set(Date(), forKey: "lastRefresh")
            
            // Send the email
            let emailHelper = EmailHelperClass()
            emailHelper.managedObjectsArray = managedObjectsArray
            emailHelper.sendReminderEmail()
        }
    }
    
    @objc func loadAdminVC() {
        // Load the Passcode VC here
        performSegue(withIdentifier: "getAdminPasscode", sender: self)
    }
    
    @objc func loadAddNewUserVC() {
        performSegue(withIdentifier: "createUserSegue", sender: nil)
    }
    
    // MARK: - Keychain handler
    
    func compareAdminPasscode(passcodeReturned: String) {
        // Beware of implications when uncommenting the next line: passcode can be read by attaching a debugger -> potential hazard
        //print("Comparing passcode: " + passcodeReturned)
        
        let keychain = KeychainSwift()
        let adminPasscode = keychain.get("adminPasscode")
        
        
        if adminPasscode == passcodeReturned {
            // Passcode matches, fire the Segue
            print("the passcodes match up")
            performSegue(withIdentifier: "adminSegue", sender: nil)
            
        } else {
            // Wrong passcode, tell the user!
            let alert = UIAlertController(title: "Wrong Passcode", message: "You entered the wrong passcode, please try again!", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(dismissAction)
            self.present(alert, animated: true)
        }
        
    }
    
    
    // MARK: - CoreData handlers
    
    func loadDataFromCoreData() {
        
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
                performSegue(withIdentifier: "createUserSegue", sender: nil)
            }
        
        
        // Reset Array to empty Array
        managedObjectsArray.removeAll()
        
        // Iterate through all NSManagedObjects in NSFetchRequestResult
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                // New method, just save the whole NSManagedObject, then read from it later on
                managedObjectsArray.insert(data, at: managedObjectsArray.count)
                
                // Create constants from NSFetchRequestResult
                let firstNameFromCoreData = data.value(forKey: "firstname") as! String
                let lastNameFromCoreData = data.value(forKey: "lastname") as! String
                let eMailFromCoreData = data.value(forKey: "email") as! String
                
                // Print to Console for Debugging
                print("First Name: " + firstNameFromCoreData)
                print("Last Name: " + lastNameFromCoreData)
                print("eMail: " + eMailFromCoreData)
                
          }
            self.tableView.reloadData()
            
        } catch {
            
            print("failed to fetch data from context")
        }
        
    }
    
    func loadTransactionsFromCoreData() {
        
        // Create context for context info stored in AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
                
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Transactions")
        
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        // Reset Array to empty Array
        transactionsManagedObjectsArray.removeAll()
        
        // Iterate through all NSManagedObjects in NSFetchRequestResult
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                // Save the whole NSManagedObject, then read from it later on
                transactionsManagedObjectsArray.insert(data, at: transactionsManagedObjectsArray.count)
                
                
          }
            
        } catch {
            print("failed to fetch data from context")
        }
    }
    
    func saveCurrentNumberOfTransactionsToCoreData(numberOfCups: Int64) {
        
        // Create context for context info stored in AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let date = Date()
        let calendar = Calendar.current
        
        let dateString = String(calendar.component(.year, from: date)+calendar.component(.month, from: date)+calendar.component(.day, from: date))
        
        
        if let matchingIndex = transactionsManagedObjectsArray.firstIndex(where: {$0!.value(forKey: "date") as! String == dateString}) {
            // Object was found, this is not the first cup today!
            let priorTransactions = transactionsManagedObjectsArray[matchingIndex]?.value(forKey: "numberOfTransactions") as! Int64
            let sumOfCupsToday = priorTransactions + numberOfCups
            
            print("Sum of cups today is: " + String(sumOfCupsToday))
            
            transactionsManagedObjectsArray[matchingIndex]?.setValue(sumOfCupsToday, forKey: "numberOfTransactions")
            
        } else {
            // item could not be found
            
            
            // Create entity, then create a transactionInfo object
            let entity = NSEntityDescription.entity(forEntityName: "Transactions", in: context)
            let transactionInfo = NSManagedObject(entity: entity!, insertInto: context)

            // Provide newUserInfo object with properties
            transactionInfo.setValue(dateString, forKey: "date")
            transactionInfo.setValue(numberOfCups, forKey: "numberOfTransactions")
        }
        
        // Save transactionInfo to CoreData
        do {
           try context.save()
            // Data was successfully saved, now pop the VC
            print("successfully saved stats data")
            mainViewController!.reloadStatsLabel()
            
          } catch {
           print("Couldn't save stats to CoreData")
            
            //Remind user to make sure all info has been provided / all fields are populated
            
            let alert = UIAlertController(title: "Failed Database Operation", message: "Failed to write stats to the Database", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(dismissAction)
            self.present(alert, animated: true)
        }
        
    }
    

    // MARK: - Table view data source

    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return managedObjectsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell?
        
        // Get the user object (NSManagedObject) from managedObjectsArray
        let userObject = managedObjectsArray[indexPath.row]
        
        let firstName = userObject?.value(forKey: "firstname") as! String
        let lastName = userObject?.value(forKey: "lastname") as! String
        let eMail = userObject?.value(forKey: "email") as! String
        
        // Assemble the string to be shown
        let fullName = firstName + " " + lastName + " (" + eMail + ")"
        
        
        
        
        if unlockedForUser != nil {
            // There's one user that is currently unlocked, check which one it is!
            
            if unlockedForUser == indexPath {
                // The indexPath matched the one saved previously, therefore the user is now unlocked. Show the appropriate cell!
                
                cell = tableView.dequeueReusableCell(withIdentifier: "unlockedCell", for: indexPath)
                
                // Configure Cell
                cell?.textLabel?.text = fullName
            } else {
                // The cell is locked, show the same cell that locked users are always shown
                
                cell = tableView.dequeueReusableCell(withIdentifier: "lockedCell", for: indexPath)
                
                
                // Configure Cell
                cell?.textLabel?.text = fullName
                
            }
            
        } else {
            // Everybody is currently locked, show everyone as locked!
            
            cell = tableView.dequeueReusableCell(withIdentifier: "lockedCell", for: indexPath)
            
            
            // Configure Cell
            cell?.textLabel?.text = fullName
        
        }
        
        // return the cell
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if unlockedForUser == nil {
            
            // Save the currently selected indexPath to a variable so that it can be used anywhere in the instance
            if selectedUser != indexPath {
                    selectedUser = indexPath
            }
            
            
            let imageDataForSelectedUser = managedObjectsArray[indexPath.row]?.value(forKey: "photo")
            let pngImageForSelectedUser = imageDataForSelectedUser as! Data
            imageForSelectedUser = UIImage(data: pngImageForSelectedUser)
            
            
            // Check if FaceAuth is enabled, if so, use face recognition to unlock the cell
            let userDefaults = UserDefaults.standard
            let faceAuthEnabled = userDefaults.bool(forKey: "faceAuth")
            
            
            print("FaceAuth Value: ")
            print(faceAuthEnabled)
            
            
            
            if faceAuthEnabled == true && imageDataForSelectedUser != nil {
                // FaceAuth is ENABLED
                // Load FaceAuthViewController through segue
                performSegue(withIdentifier: "faceAuthSegue", sender: self)
                
            } else {
                // FaceAuth is DISABLED
                // Fire the segue to prompt the user for their passcode
                performSegue(withIdentifier: "getUserPasscode", sender: self)
            }
            
            
        } else {

            if unlockedForUser == indexPath {
                //The user is unlocked, let them bill a coffee to their account

                // next few lines are for debugging
                let firstName = managedObjectsArray[indexPath.row]?.value(forKey: "firstname") as! String
                let lastName = managedObjectsArray[indexPath.row]?.value(forKey: "lastname") as! String
                let eMail = managedObjectsArray[indexPath.row]?.value(forKey: "email") as! String

                print("Will mutate the following user: " + firstName + " " + lastName + " (" + eMail + ")")


                // Read and print balance before making changes to saved data
                let balanceBeforeChanges = managedObjectsArray[indexPath.row]?.value(forKey: "balanceInCents") as! Int64
                print("balance before changes: " + String(balanceBeforeChanges))


                // Get current coffee price from NSUserDefaults
                let userDefaults = UserDefaults.standard
                let coffeePriceAsInt = userDefaults.integer(forKey: "CoffeePrice")
                let coffeePriceAsInt64 = Int64(coffeePriceAsInt)

                // Set a multiplier for multiple cups of coffee
                let paymentInfoInt = userDefaults.integer(forKey: "multiplier")
                let multiplier = Int64(paymentInfoInt)
                print("User is being billed for " + String(multiplier) + " cups of coffee")
                
                // Save new balance
                let newBalance = balanceBeforeChanges - (coffeePriceAsInt64 * multiplier)
                managedObjectsArray[indexPath.row]?.setValue(newBalance, forKey: "balanceInCents")

                // Save number of coffee cups for stats screen
                saveCurrentNumberOfTransactionsToCoreData(numberOfCups: multiplier)
                
                // Create instance of MOC
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext

                // Save newUserInfo to CoreData
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

                // Print new balance after changes have been saved
                let balanceAfterChanges = managedObjectsArray[indexPath.row]?.value(forKey: "balanceInCents") as! Int64
                print("balance after changes: " + String(balanceAfterChanges))

                // Execute IoT function
                IoTHelperClass().userHasBeenBilledForCoffee()

                // Reset the cell to a locked state and reflect the changed in the UI by reloading the TableView
                unlockedForUser = nil
                tableView.reloadData()

                // Reset the NSUserDefaults value for "multiplier" to 0
                userDefaults.set(0, forKey: "multiplier")
            }
        }
    }
    
    func unlockUser(indexPathToUnlock: IndexPath) {
        // Assign the indexPath for the user to unlock and reload the tableView to reflect the changes
        unlockedForUser = indexPathToUnlock
        tableView.reloadData()
    }
    
    func loadTableViewCellsAfterUnlock(passcodeReturned: String) {
        
        // Get UUID from managed object
        let uuidFromManagedObject = managedObjectsArray[selectedUser!.row]!.value(forKey: "userUUID") as! NSUUID
        
        // Get keychain value using UUID
        let keychain = KeychainSwift()
        let userPasscode = keychain.get(uuidFromManagedObject.uuidString)
        
        // Check to see if passcode entered matches the one in the keychain
        if userPasscode == passcodeReturned {
         
            // The passcodes matched, tell the table to unlock the cell at the selected indexPath, then reload the table
            unlockedForUser = selectedUser
            tableView.reloadData()
            
            
        } else {
         // Provided passcode was wrong, alert the user
            
            let alert = UIAlertController(title: "Wrong passcode", message: "You entered the wrong passcode, please try again!", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(dismissAction)
            self.present(alert, animated: true)
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        
        
        
        // Tell the destination ViewController that you're trying to access the admin passcode
        if segue.identifier == "getAdminPasscode" {
            if let navigationViewController = segue.destination as? UINavigationController {
                if let passcodeViewController = navigationViewController.viewControllers[0] as? SetPasscodeViewController {
                    passcodeViewController.userLevel = .getAdmin
                    passcodeViewController.selectUsersTVController = self
                }
            }
        }
        // Tell the destination ViewController that you're trying to access the user passcode
        if segue.identifier == "getUserPasscode" {
            if let navigationViewController = segue.destination as? UINavigationController {
                if let passcodeViewController = navigationViewController.viewControllers[0] as? SetPasscodeViewController {
                    passcodeViewController.userLevel = .getUser
                    passcodeViewController.selectUsersTVController = self
                }
            }
        }
        if segue.identifier == "adminSegue" {
            if let navigationViewController = segue.destination as? UINavigationController {
                if let adminViewController = navigationViewController.viewControllers[0] as? AdminTableViewController {
                    adminViewController.sourceTableViewController = self
                }
            }
        }
        if segue.identifier == "createUserSegue" {
            if let createUserVC = segue.destination as? CreateNewUserTableViewController {
                createUserVC.sourceViewController = self
            }
        }
        
        if segue.identifier == "faceAuthSegue" {
            if let faceAuthVC = segue.destination as? FaceAuthViewController {
                faceAuthVC.imageToMatch = imageForSelectedUser
                faceAuthVC.selectedIndexPath = selectedUser
                faceAuthVC.selectUsersTVController = self
            }
        }
        
        
        
        
        
        
    }
    
}
