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
    
    var unlockedForUser: IndexPath? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Users"
        
        // Add the barButtonItems (buttons in the NavigationBar)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Admin", style: .plain, target: self, action: #selector(loadAdminVC))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(loadAddNewUserVC))
        
        
        
        
        // Load all data from CoreData and refresh the TableView
        loadDataFromCoreData()
        print("Number of users in Array: " + String(managedObjectsArray.count))
    }
    
    @objc func loadAdminVC() {
        // Load the Passcode VC here
        performSegue(withIdentifier: "getAdminPasscode", sender: self)
    }
    
    @objc func loadAddNewUserVC() {
        performSegue(withIdentifier: "createUserSegue", sender: nil)
    }
    
    // MARK: - Keychain stuff
    
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
            unlockedForUser = indexPath
            tableView.reloadData()
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
        
        
        
        
        
        
        
        
    }
    
}
