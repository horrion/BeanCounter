//
//  EditUserTableViewController.swift
//  BeanCounter
//
//  Created by Robert Horrion on 12/12/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit
import CoreData

class EditUserTableViewController: UITableViewController {

    var firstNameTextField: UITextField!
    var lastNameTextField: UITextField!
    var eMailTextField: UITextField!
    
    var selectUserViewController: SelectUsersTableViewController?
    var adminViewController: AdminTableViewController?
    
    var selectedManagedObject: NSManagedObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Save button setup in Navigation Bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveUserButton))
        
        self.title = "Edit User Data"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            // Section 0
            return 3
        }
        if section == 1 {
            // Section 1
            return 1
        }
        else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "inputCellIdentifier", for: indexPath)
        let cameraCell = tableView.dequeueReusableCell(withIdentifier: "cameraCellIdentifier", for: indexPath)
        
        let firstName = selectedManagedObject?.value(forKey: "firstname") as! String
        let lastName = selectedManagedObject?.value(forKey: "lastname") as! String
        let eMail = selectedManagedObject?.value(forKey: "email") as! String
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "First name"
                
                // Textfield to enable info input
                let viewWidth = Int(cell.contentView.frame.size.width)
                let textFieldWidth = 260
                
                firstNameTextField = UITextField(frame: CGRect(x: viewWidth-textFieldWidth, y: 6, width: textFieldWidth, height: 34))
                firstNameTextField.placeholder = "Enter your first name here"
                firstNameTextField.text = firstName
                
                cell.contentView.addSubview(firstNameTextField)
                
                return cell
            }
            if indexPath.row == 1 {
                cell.textLabel?.text = "Last name"
                
                // Textfield to enable info input
                let viewWidth = Int(cell.contentView.frame.size.width)
                let textFieldWidth = 260
                
                lastNameTextField = UITextField(frame: CGRect(x: viewWidth-textFieldWidth, y: 6, width: textFieldWidth, height: 34))
                lastNameTextField.placeholder = "Enter your last name here"
                lastNameTextField.text = lastName
                
                cell.contentView.addSubview(lastNameTextField)
                
                return cell
            }
            if indexPath.row == 2 {
                cell.textLabel?.text = "E-Mail Address"
                
                // Textfield to enable info input
                let viewWidth = Int(cell.contentView.frame.size.width)
                let textFieldWidth = 260
                
                eMailTextField = UITextField(frame: CGRect(x: viewWidth-textFieldWidth, y: 6, width: textFieldWidth, height: 34))
                eMailTextField.placeholder = "Enter your E-Mail Address here"
                eMailTextField.text = eMail
                
                cell.contentView.addSubview(eMailTextField)
                
                return cell
            }
            else {
                // if section == 0 && row != {1, 2, 3}
                return cell
            }
        }
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                
                //Add camera here to save user photo for login
                //cameraCell.
                
                
                return cameraCell
            }
            else {
                // if section == 1 && row != 0
                return cell
            }
        }
        else {
            // if section != 0 || 1
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    

    // MARK: - CoreData handling/saving
    
    @objc func saveUserButton() {
        
        // Create context for context info stored in AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        // Create entity, then create a newUserInfo object
        //let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        // iterate through all NSManagedObjects, look for the one that was passed to this ViewController
        request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    
                    if data == selectedManagedObject {
                        // Found the NSManagedObject that we're trying to edit, modify it, then save it
                        
                        //TODO: Save user photo
                        data.setValue(firstNameTextField.text, forKey: "firstname")
                        data.setValue(lastNameTextField.text, forKey: "lastname")
                        data.setValue(eMailTextField.text, forKey: "email")
                    }
                }
                
            } catch {
                    
                print("failed to fetch data from context")
            }
        
        // Save selectedManagedObject to CoreData
        do {
           try context.save()
            // Data was successfully saved, now pop the VC
            print("successfully saved data")
            
            // Reload AdminVC CoreData
            adminViewController?.loadDataFromCoreData()
            
            // Reload SelectUsersVC CoreData
            selectUserViewController?.loadDataFromCoreData()

            // Pop the ViewController to get back to the AdminTableViewVC
            self.navigationController?.popViewController(animated: true)

          } catch {
           print("Couldn't save to CoreData")

            //Remind user to make sure all info has been provided / all fields are populated

            let alert = UIAlertController(title: "Failed Database Operation", message: "Failed to write to the Database", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(dismissAction)
            self.present(alert, animated: true)
        }
        
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
