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
                
                //TODO: delete the next few lines
                // Create constants from NSFetchRequestResult
                let firstNameFromCoreData = data.value(forKey: "firstname") as! String
                let lastNameFromCoreData = data.value(forKey: "lastname") as! String
                let eMailFromCoreData = data.value(forKey: "email") as! String
                
               // Insert into Array
//                usersArray.insert(userStruct.init(firstName: firstNameFromCoreData,
//                                                  lastName: lastNameFromCoreData,
//                                                  eMail: eMailFromCoreData), at: usersArray.count)
                
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
        cell.detailTextLabel?.text = String(currentUserBalance)
        
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
        
        //TODO: Go to detail view (like create new user) and allow admin to change all values
        
        
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            
            
            
            
            
            
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            
                        
            //
            //
            //
            //            // Create context for context info stored in AppDelegate
            //            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            //            let context = appDelegate.persistentContainer.viewContext
            //
            //            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
            //
                        
            //            context.delete(nnnnnn)
            //
            //
            //            managedObjectContext.delete(sessions[indexPath.row])
            //              do {
            //                try managedObjectContext.save()
            //                tableView.reloadData()
            //              } catch let error as NSError {
            //                print("Could not save. \(error), \(error.userInfo)")
            //              }
            //            }
                        
                        
                        
            
            
            
            
            
            
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
