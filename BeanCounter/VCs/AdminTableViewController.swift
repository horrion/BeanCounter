//
//  AdminTableViewController.swift
//  BeanCounter
//
//  Created by Robert Horrion on 10/9/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit
import CoreData

class AdminTableViewController: UITableViewController {

//    struct userStruct {
//        let firstName: String
//        let lastName: String
//        let eMail: String
//    }
    
    //var usersArray = [userStruct]()
    
    var managedObjectsArray = [NSManagedObject?]()
    
    var sourceTableViewController: SelectUsersTableViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Admin"
        
        loadDataFromCoreData()
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    
    
    
    
    //MARK: - CoreData Support functions
    
    func loadDataFromCoreData() {
        
        // Create context for context info stored in AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        // Update title with number of registered users
            var numberOfObjects: Int = 0
            
            do {
                numberOfObjects = try context.count(for: request)
                self.title = "Admin (number of registered users: " + String(numberOfObjects) + ")"
            } catch {
                print("failed to fetch data")
            }
            
            
        
        // Reset Array to empty Array
        managedObjectsArray.removeAll()
        
        // Iterate through all NSManagedObjects in NSFetchRequestResult
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
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

    @IBAction func doneButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "adminTableViewCellIdentifier", for: indexPath)
        
        // Get managedObject from array, set as userObject
        let userObject = managedObjectsArray[indexPath.row]
        
        // Extract first name and last name from managedObject and write to variables
        let firstName = userObject?.value(forKey: "firstname") as! String
        let lastName = userObject?.value(forKey: "lastname") as! String
        
        let fullName = firstName + " " + lastName
        
        // Get user balance from managedObject
        let currentUserBalance = userObject?.value(forKey: "balanceInCents") as! Int64
        
        //TODO: Convert to Euro from cents before displaying
        
        
        // Configure cell labels
        cell.textLabel?.text = fullName
        cell.detailTextLabel?.text = String(currentUserBalance) + "€"
        
        // if balance is negative (user owes money) set textcolor to red
        // signum() == -1 means the value is negative
        if currentUserBalance.signum() == -1 {
            cell.detailTextLabel?.textColor = UIColor.red
        } else {
            cell.detailTextLabel?.textColor = UIColor.green
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        // Create UIAlertController to ask the admin whether they want to add user credit or edit user details
        
        let choiceAlertController = UIAlertController(title: "What do you want to do with the user? ", message: nil, preferredStyle: .alert)
        
        
        let dismissCancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let segueEditUserAction = UIAlertAction(title: "Edit User", style: .default) { action in
            
            // if selected, perform a Segue to EditUserViewController
            self.performSegue(withIdentifier: "editUserSegue", sender: nil)
        }
        let resetUserPasscode = UIAlertAction(title: "Set new User Passcode", style: .default) { action in
            // TODO: implement user passcode reset here
        }
        
        
        let addUserCreditAction = UIAlertAction(title: "Add User Credit", style: .default) { action in
            // if selected, trigger the whole add-credit process (many alertcontrollers!)
            
            let alertController = UIAlertController(title: "Add user credit", message: nil, preferredStyle: .alert)
            //this UIAlertController provides a textField for the user to enter a value to add
                
            alertController.addTextField()

            let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned alertController] _ in
                let dataToSave = alertController.textFields![0].text
                
                if Int64(dataToSave!) != nil {
                let Int64ValueToSave = Int64(dataToSave!)
                
                //TODO: Convert from Euro to cents here and save cents
                
                
                let userObject = self.managedObjectsArray[indexPath.row]
                
                let balanceBeforeChanges = userObject!.value(forKey: "balanceInCents") as! Int64
                //Add to userBalance
                
                let newBalance = balanceBeforeChanges + Int64ValueToSave!
                userObject?.setValue(newBalance, forKey: "balanceInCents")
                
                // Save new balance
                // Create instance of MOC
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                // Save newUserInfo to CoreData
                do {
                   try context.save()
                    // Data was successfully saved
                    print("successfully saved data")
                    
                    let newBalanceInt = self.managedObjectsArray[indexPath.row]?.value(forKey: "balanceInCents") as! Int64
                    let userFirstNameString = self.managedObjectsArray[indexPath.row]?.value(forKey: "firstname") as! String
                    let userLastNameString = self.managedObjectsArray[indexPath.row]?.value(forKey: "lastname") as! String
                    let userEmail = self.managedObjectsArray[indexPath.row]?.value(forKey: "email") as! String
                    
                    let userIDString = userFirstNameString + " " + userLastNameString + " (" + userEmail + ")"
                    
                    self.loadDataFromCoreData()
                    
                    let newBalanceString = "The new balance is " + String(newBalanceInt) + " for user " + userIDString
                    
                        // Confirm the balance has been updated
                        let alert = UIAlertController(title: "Balance has been updated", message: newBalanceString, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default)
                        alert.addAction(okAction)
                        self.present(alert, animated: true)
                    
                  } catch {
                    // Failed to write to the database
                    print("Couldn't save to CoreData")
                    
                    let alert = UIAlertController(title: "Failed Database Operation", message: "Failed to write to the Database", preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Ok", style: .default)
                    alert.addAction(dismissAction)
                    self.present(alert, animated: true)
                }
                
                } else {
                    // Non numerical value was provided, alert the user
                    let alert = UIAlertController(title: "Non-numeric value detected", message: "Please enter a numeric value with one decimal point only", preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Ok", style: .default)
                    alert.addAction(dismissAction)
                    self.present(alert, animated: true)
                }
            }

        let dismissAction = UIAlertAction(title: "Cancel", style: .default)
        alertController.addAction(dismissAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true)
        
        
    }
    
    choiceAlertController.addAction(segueEditUserAction)
    choiceAlertController.addAction(addUserCreditAction)
    choiceAlertController.addAction(resetUserPasscode)
    choiceAlertController.addAction(dismissCancelAction)
    
    self.present(choiceAlertController, animated: true)
        
        
        
        
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Create context for context info stored in AppDelegate
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            context.delete(managedObjectsArray[indexPath.row]!)
            
            managedObjectsArray.remove(at: indexPath.row)
            
            do {
                try context.save()
                
                // Delete the row from the tableView
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                // Reload SelectUsersTableView here
                sourceTableViewController?.loadDataFromCoreData()
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                
                // Show an alert to notify the user of the error
                let alert = UIAlertController(title: "Database error", message: "Could not delete the user from the database", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(dismissAction)
                self.present(alert, animated: true)
            }
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
