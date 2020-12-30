//
//  CreateNewUserTableViewController.swift
//  BeanCounter
//
//  Created by Robert Horrion on 10/8/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit
import CoreData
import KeychainSwift

class CreateNewUserTableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var firstNameTextField: UITextField!
    var lastNameTextField: UITextField!
    var eMailTextField: UITextField!
    
    var sourceViewController: SelectUsersTableViewController?
    
    var uuidForCoreData: UUID?
    
    var userImage: UIImage?
    
    var cameraCell: CameraTableViewCell?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Save button setup in Navigation Bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveUserButton))
        
        self.title = "Create a new user"
    }
    
    // MARK: - CoreData handling/saving
    
    @objc func saveUserButton() {
        // Save userdata to CoreData here, then set passcode later in setUserPasscode(passcodeReturned: String)
        
        uuidForCoreData = UUID()
        
        // Create context for context info stored in AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Create entity, then create a newUserInfo object
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        
        if userImage != nil {
            
            let newUserInfo = NSManagedObject(entity: entity!, insertInto: context)
            
            // Provide newUserInfo object with properties
            newUserInfo.setValue(firstNameTextField.text, forKey: "firstname")
            newUserInfo.setValue(lastNameTextField.text, forKey: "lastname")
            newUserInfo.setValue(eMailTextField.text, forKey: "email")
            newUserInfo.setValue(Date(), forKey: "createdAt")
            newUserInfo.setValue(0, forKey: "balanceInCents")
            newUserInfo.setValue(uuidForCoreData, forKey: "userUUID")
            
            
            // Create Data object from UIImage for CoreData
            let imageData = userImage?.pngData()
            
            // Save the data to CoreData
            newUserInfo.setValue(imageData, forKey: "photo")
            
            // Save newUserInfo to CoreData
            do {
               try context.save()
                // Data was successfully saved, now pop the VC
                print("successfully saved data")
                sourceViewController?.loadDataFromCoreData()
                self.setUserPasscode()
                
              } catch {
               print("Couldn't save to CoreData")
                
                //Remind user to make sure all info has been provided / all fields are populated
                
                let alert = UIAlertController(title: "Failed Database Operation", message: "Failed to write to the Database", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(dismissAction)
                self.present(alert, animated: true)
            }
            
        } else {
            // No user image has been set, ask the user to set one!
            
            let alertController = UIAlertController(title: "No photo has been taken", message: "Would you really like to create this account without taking a photo? You won't be able to use any Face Recognition related features if you don't choose to take a photo now!", preferredStyle: .alert)
            
            let saveAction = UIAlertAction(title: "Create the account", style: .default) { action in
                
                let newUserInfo = NSManagedObject(entity: entity!, insertInto: context)
                
                // Provide newUserInfo object with properties
                newUserInfo.setValue(self.firstNameTextField.text, forKey: "firstname")
                newUserInfo.setValue(self.lastNameTextField.text, forKey: "lastname")
                newUserInfo.setValue(self.eMailTextField.text, forKey: "email")
                newUserInfo.setValue(Date(), forKey: "createdAt")
                newUserInfo.setValue(0, forKey: "balanceInCents")
                newUserInfo.setValue(self.uuidForCoreData, forKey: "userUUID")
                
                do {
                   try context.save()
                    // Data was successfully saved, now pop the VC
                    print("successfully saved data")
                    self.sourceViewController?.loadDataFromCoreData()
                    self.setUserPasscode()
                    
                  } catch {
                   print("Couldn't save to CoreData")
                    
                    //Remind user to make sure all info has been provided / all fields are populated
                    
                    let alert = UIAlertController(title: "Failed Database Operation", message: "Failed to write to the Database", preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Ok", style: .default)
                    alert.addAction(dismissAction)
                    self.present(alert, animated: true)
                }
                
            }
            let dismissAction = UIAlertAction(title: "Take a photo", style: .default)
            
            alertController.addAction(dismissAction)
            alertController.addAction(saveAction)
            present(alertController, animated: true)
        }
    }
    
    func setUserPasscode() {
        performSegue(withIdentifier: "setUserPasscode", sender: self)
    }
    
    // MARK: - Keychain handling
    
    func setUserPasscode(passcodeReturned: String) {
        // A Passcode has been returned, handle the keychain request here
        
        
        
        // Beware of implications when uncommenting the next line: passcode can be read by attaching a debugger -> potential hazard
        //print("Attempting to save: " + passcodeReturned)
        let keychain = KeychainSwift()
        keychain.set(passcodeReturned, forKey: uuidForCoreData!.uuidString)
        print("Saved new Admin passcode")
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // Save picture here if one is provided by CameraTableViewCell
    func saveImageData(imageToSave: UIImage) {
        
        //print("Received image data: ")
        //print(imageToSave)
        
        // Save the data to an instance variable, later access the instance var when trying to save the image
        userImage = imageToSave
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
            return 2
        }
        else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "inputCellIdentifier", for: indexPath)
        cameraCell = tableView.dequeueReusableCell(withIdentifier: "cameraCellIdentifier", for: indexPath) as? CameraTableViewCell
        
        
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
                cameraCell!.embeddedInTableViewController = self
                cameraCell!.sourceController = .createController
                
                return cameraCell!
            }
            if indexPath.row == 1 {
                cell.textLabel?.text = "Add photo from photo library"
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = UIColor.systemBlue
                
                return cell
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
        
        if indexPath.section == 1 {
            if indexPath.row == 1 {
                let pickerController = UIImagePickerController()
                pickerController.delegate = self
                pickerController.allowsEditing = true
                pickerController.mediaTypes = ["public.image"]
                pickerController.sourceType = .photoLibrary
                
                present(pickerController, animated: true, completion: nil)
            }
        }
        
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            // Image was selected, assign this to the userImage variable
            userImage = pickedImage
            
            // Causes a crash, need to fix
            //cameraCell?.setImagePreview(imageToPreview: pickedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        
        // Tell the destination ViewController that you're trying to set the user passcode
        if segue.identifier == "setUserPasscode" {
            if let navigationViewController = segue.destination as? UINavigationController {
                if let passcodeViewController = navigationViewController.viewControllers[0] as? SetPasscodeViewController {
                    passcodeViewController.userLevel = .setUser
                    passcodeViewController.createNewUserTVController = self
                }
            }
        }
    }
    

}
