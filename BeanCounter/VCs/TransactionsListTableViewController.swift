//
//  TransactionsListTableViewController.swift
//  BeanCounter
//
//  Created by Robert Horrion on 12/22/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit
import CoreData

class TransactionsListTableViewController: UITableViewController {

    var transactionsForUser: User?
    
    var transactionsArray = [TransactionsForUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load all transaction for the provided user into an array
        transactionsArray = transactionsForUser!.transactionForUserRelationship!.allObjects as! [TransactionsForUser]
        
        transactionsArray.sort(by: { $0.dateTime!.compare($1.dateTime!) == .orderedAscending})
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Export To CSV", style: .plain, target: self, action: #selector(writeBalancesToCSV))
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let transactions = transactionsForUser?.transactionForUserRelationship?.count
        return transactions ?? 0
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // if transactional value is negative set textcolor to red
        // signum() == -1 means the value is negative
        let transactionalValue = transactionsArray[indexPath.row].value
        if transactionalValue.signum() == -1 {
            cell.detailTextLabel?.textColor = UIColor.red
            cell.textLabel?.textColor = UIColor.red
        } else {
            cell.detailTextLabel?.textColor = UIColor.green
            cell.textLabel?.textColor = UIColor.green
        }
        
        
        // Write the date and time to the primary text label
        let transactionDateTime = transactionsArray[indexPath.row].dateTime
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let userReadableString = dateFormatter.string(from: transactionDateTime!)
        
        let transactionType = transactionsArray[indexPath.row].kind
        
        // Create a fractional (monetary value) by dividing cent value by 100
        let divisor = NSDecimalNumber(value: 100)
        let decimalValue = NSDecimalNumber(value: transactionalValue).dividing(by: divisor)
        
        // Set up a NumberFormatter to get monetary values
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        // TODO: Use the next 2 lines for shipping product, always sets format to the one defined in device settings
        formatter.locale = NSLocale.current
        //formatter.string(from: decimalValue)
        
        // Use this for debugging
        //formatter.locale = Locale(identifier: "de_DE")
        
        
        
        // Set all values of the cell
        cell.textLabel?.text = userReadableString + " " + transactionType!
        cell.detailTextLabel?.text = formatter.string(from: decimalValue)
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func writeBalancesToCSV() {
        
        let nameString = (transactionsForUser?.firstname!)! + " " + (transactionsForUser?.lastname!)!
        
        
        // Set fileName for the .csv file here
        let fileName = "Transaction History - " + nameString + ".csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        var csvText = "Date and Time,Transaction Type,Value\n"
                   
        // iterate through all values in usersArray and write each one to the csv file
        for transactionEntry in transactionsArray {
                       
            // Create variables from array data
            let dateTime = transactionEntry.dateTime
            let kind = transactionEntry.kind
            let value = transactionEntry.value
            
            // Create a fractional (monetary value) by dividing cent value by 100
            let divisor = NSDecimalNumber(value: 100)
            let decimalValue = NSDecimalNumber(value: value).dividing(by: divisor)
            
            // Set up a NumberFormatter to get monetary values
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            
            // TODO: Use the next 2 lines for shipping product, always sets format to the one defined in device settings
            formatter.locale = NSLocale.current
            //formatter.string(from: decimalValue)
            
            // Use this for debugging
            //formatter.locale = Locale(identifier: "de_DE")
            let balanceString = formatter.string(from: decimalValue)!
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let userReadableString = dateFormatter.string(from: dateTime!)
            
            let kindString = kind!
            
            // create new line from variables in CSV file
            let newLine = "\(userReadableString),\(kindString),\"\(String(describing: balanceString))\"\n"
            csvText.append(contentsOf: newLine)
        }
        
        do {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                            
            let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
            vc.modalPresentationStyle = UIModalPresentationStyle.popover
            vc.popoverPresentationController?.sourceView = self.view
            
            vc.excludedActivityTypes = [
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToVimeo,
                UIActivity.ActivityType.postToTencentWeibo,
                UIActivity.ActivityType.postToTwitter,
                UIActivity.ActivityType.postToFacebook,
                UIActivity.ActivityType.openInIBooks
            ]
            present(vc, animated: true, completion: nil)
            
        } catch {
            
            // an error has occurred
            print("Failed to create file")
            print("\(error)")
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
