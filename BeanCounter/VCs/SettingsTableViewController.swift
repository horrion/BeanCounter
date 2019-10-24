//
//  SettingsTableViewController.swift
//  BeanCounter
//
//  Created by Robert Horrion on 10/15/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    let settingsInTableView = ["Edit Payment methods",
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
            self.performSegue(withIdentifier: "editPaymentMethodsSegue", sender: nil)
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
