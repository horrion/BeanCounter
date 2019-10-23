//
//  SelectUsersTableViewController.swift
//  BeanCounter
//
//  Created by Robert Horrion on 10/8/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit
import CoreData

class SelectUsersTableViewController: UITableViewController {
    
    struct userStruct {
        let firstName: String
        let lastName: String
        let eMail: String
    }
    
    var usersArray = [userStruct]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Users"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Admin", style: .plain, target: self, action: #selector(loadAdminVC))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(loadAddNewUserVC))
        
        
        
        
        // Load all data from CoreData and refresh the TableView
        loadDataFromCoreData()
        print("Number of users in Array: " + String(usersArray.count))
    }
    
    @objc func loadAdminVC() {
        performSegue(withIdentifier: "adminSegue", sender: nil)
    }

    @objc func loadAddNewUserVC() {
        performSegue(withIdentifier: "createUserSegue", sender: nil)
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
        usersArray.removeAll()
        
        // Iterate through all NSManagedObjects in NSFetchRequestResult
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                
                // Create constants from NSFetchRequestResult
                let firstNameFromCoreData = data.value(forKey: "firstname") as! String
                let lastNameFromCoreData = data.value(forKey: "lastname") as! String
                let eMailFromCoreData = data.value(forKey: "email") as! String
                
               // Insert into Array
                usersArray.insert(userStruct.init(firstName: firstNameFromCoreData,
                                                  lastName: lastNameFromCoreData,
                                                  eMail: eMailFromCoreData), at: usersArray.count)
                
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
        return usersArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lockedCell", for: indexPath)

        
        
        let userObject = usersArray[indexPath.row]
        
        let firstName = userObject.firstName
        let lastName = userObject.lastName
        
        let fullName = firstName + " " + lastName
        
        
        // Configure Cell
        cell.textLabel?.text = fullName
        
        
        

        return cell
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
