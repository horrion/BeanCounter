//
//  SettingsTableViewController.swift
//  BeanCounter
//
//  Created by Robert Horrion on 10/15/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    let settingsInTableView = ["Edit Payment QR code",
                               "Change Admin Passcode",
                               "Export to CSV",
                               "Edit Coffee price"]
    
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

            alertController.addAction(saveAction)
            present(alertController, animated: true)
        }
        if indexPath.row == 1 {
            // Change Admin Passcode
            
            
            
            
            
            // Modify Keychain entry here
            
            
            
        }
        if indexPath.row == 2 {
            // Export to CSV
            
            
            
            // Enter CoreData operation here
            
            
            
            
            
        }
        if indexPath.row == 3 {
            //Edit Coffee price
            
            let alertController = UIAlertController(title: "Edit Coffee price", message: nil, preferredStyle: .alert)
            alertController.addTextField()

            let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned alertController] _ in
                let dataToSave = alertController.textFields![0].text
                
                if Float(dataToSave!) != nil {
                    // value is numeric
                    // Save the entered data to UserDefaults (plist)
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

            alertController.addAction(saveAction)
            present(alertController, animated: true)
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
