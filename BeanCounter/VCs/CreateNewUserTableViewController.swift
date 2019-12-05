//
//  CreateNewUserTableViewController.swift
//  BeanCounter
//
//  Created by Robert Horrion on 10/8/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit
import CoreData

class CreateNewUserTableViewController: UITableViewController {
    
    var firstNameTextField: UITextField!
    var lastNameTextField: UITextField!
    var eMailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Save button setup in Navigation Bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveUserButton))
        
        
    }
    
    // MARK: - CoreData handling/saving
    
    @objc func saveUserButton() {
        
        // Create context for context info stored in AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Create entity, then create a newUserInfo object
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        let newUserInfo = NSManagedObject(entity: entity!, insertInto: context)
        
        
        //TODO: Modify this to save data from TableView
        // Provide newUserInfo object with properties
        newUserInfo.setValue(firstNameTextField.text, forKey: "firstname")
        newUserInfo.setValue(lastNameTextField.text, forKey: "lastname")
        newUserInfo.setValue(eMailTextField.text, forKey: "email")
        newUserInfo.setValue(Date(), forKey: "createdAt")
        
        // Save newUserInfo to CoreData
        do {
           try context.save()
            // Data was successfully saved, now pop the VC
            print("successfully saved data")
            self.navigationController?.popViewController(animated: true)
          } catch {
           print("Couldn't save to CoreData")
            
            //Remind user to make sure all info has been provided / all fields are populated
            //TODO: Provide popup for failed save to CoreData
        }
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
        
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "First name"
                
                // Textfield to enable info input
                let viewWidth = Int(cell.contentView.frame.size.width)
                let textFieldWidth = 260
                
                firstNameTextField = UITextField(frame: CGRect(x: viewWidth-textFieldWidth, y: 6, width: textFieldWidth, height: 34))
                firstNameTextField.placeholder = "Enter your first name here"
                
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
    
    
    
//    func bsfunction() {
//
//
//
//        guard let device = AVCaptureDevice.devices().filter({ $0.position == .Front })
//            .first as? AVCaptureDevice else {
//                fatalError("No front facing camera found")
//        }
//
//
//
//
//    }
    

  
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}