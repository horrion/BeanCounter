//
//  AddUserCreditViewController.swift
//  BeanCounter
//
//  Created by Robert Horrion on 12/22/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit
import CoreData

class AddUserCreditViewController: UIViewController {

    @IBOutlet weak var transactionValueTextBox: UITextField!
    @IBOutlet weak var selectPaymentAmountSegmentedControl: UISegmentedControl!
    @IBOutlet weak var selectPaymentTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var datePickerOutlet: UIDatePicker!
    
    var transactionType: String = "PayPal"
    var userObjectForTransaction: NSManagedObject?
    
    var adminTableViewController: AdminTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        // Check that the data in the textfield is numeric
        let dataToSave = transactionValueTextBox.text

        if Float(dataToSave!) != nil {
            // value is numeric
            // Save the entered data
        
            // Create a fractional (monetary value) by dividing cent value by 100
            let divisor = NSDecimalNumber(value: 100)
            let decimalValue = NSDecimalNumber(string: dataToSave).multiplying(by: divisor)
            
            let int64ToSave = decimalValue.int64Value
            
            print("saving value: " + String(int64ToSave))

            let balanceBeforeChanges = userObjectForTransaction!.value(forKey: "balanceInCents") as! Int64
            
            //Add to userBalance
            let newBalance = balanceBeforeChanges + int64ToSave
            userObjectForTransaction?.setValue(newBalance, forKey: "balanceInCents")

            
            let transactionDateTime = datePickerOutlet.date
            
            
            // Save the coffee transaction here
            CoreDataHelperClass.init().saveNewTransaction(userForTransaction: userObjectForTransaction as! User,
                                                          dateTime: transactionDateTime,
                                                          monetaryValue: int64ToSave,
                                                          transactionType: transactionType)
            
            
            // Save new balance
            // Create instance of MOC
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            // Save newUserInfo to CoreData
            do {
               try context.save()
                // Data was successfully saved
                print("successfully saved data")
                
                let newBalanceInt = userObjectForTransaction?.value(forKey: "balanceInCents") as! Int64
                let userFirstNameString = userObjectForTransaction?.value(forKey: "firstname") as! String
                let userLastNameString = userObjectForTransaction?.value(forKey: "lastname") as! String
                let userEmail = userObjectForTransaction?.value(forKey: "email") as! String
                
                let userIDString = userFirstNameString + " " + userLastNameString + " (" + userEmail + ")"
                
                // Refresh AdminTableViewController's tableview
                adminTableViewController?.loadDataFromCoreData()
                
                // Create a fractional (monetary value) by dividing cent value by 100
                let divisorForAlert = NSDecimalNumber(value: 100)
                let decimalValueForAlert = NSDecimalNumber(value: newBalanceInt).dividing(by: divisorForAlert)
                
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                
                // TODO: Use the next 2 lines for shipping product, always sets format to the one defined in device settings
                //formatter.locale = NSLocale.current
                //formatter.string(from: decimalValue)
                
                formatter.locale = Locale(identifier: "de_DE")
                
                let balanceString = formatter.string(from: decimalValueForAlert)!
                
                
                let newBalanceString = "The new balance is " + balanceString + " for user " + userIDString
                
                    // Confirm the balance has been updated
                    let alert = UIAlertController(title: "Balance has been updated", message: newBalanceString, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default) { action in
                    // When it's all said and done, dismiss the ViewController
                    self.navigationController?.popViewController(animated: true)
                }
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
    
    // The upper Segmented Control changed its value
    @IBAction func paymentAmountIndexChanged(_ sender: Any) {
        
        switch selectPaymentAmountSegmentedControl.selectedSegmentIndex {
            
        case 0:
            transactionValueTextBox.text = String(5)
        case 1:
            transactionValueTextBox.text = String(10)
        case 2:
            transactionValueTextBox.text = String(15)
        case 3:
            transactionValueTextBox.text = String(20)
        default:
            break
        }
        
    }
    
    // The lower Segmented Control changed its value
    @IBAction func paymentTypeIndexChanged(_ sender: Any) {
        
        switch selectPaymentTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            transactionType = "PayPal"
        case 1:
            transactionType = "Cash"
        case 2:
            transactionType = "Coffee Beans"
        default:
            break
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
