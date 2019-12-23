//
//  CoreDataHelperClass.swift
//  BeanCounter
//
//  Created by Robert Horrion on 12/22/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHelperClass: NSObject {

    func saveNewTransaction(userForTransaction: User, dateTime: Date, monetaryValue: Int64, transactionType: String) {
        
        // Create context for context info stored in AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Create entity reference
        let entity = NSEntityDescription.entity(forEntityName: "TransactionsForUser", in: context)
            
        // Create a new transaction as an object
        let transaction = TransactionsForUser(entity: entity!, insertInto: context)
        
        // Set properties for the new transaction
        transaction.dateTime = dateTime
        transaction.kind = transactionType
        transaction.value = monetaryValue
        
        // Assign the transaction to a user by setting the relationship
        transaction.userForTransactionRelationship = userForTransaction
        
        // Save the transaction to CoreData
        do {
           try context.save()
            print("successfully saved transaction")
            
          } catch {
            print("Couldn't save transaction to CoreData")
            
        }
    }
    
}
