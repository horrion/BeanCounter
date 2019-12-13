//
//  EmailHelperClass.swift
//  BeanCounter
//
//  Created by Robert Horrion on 12/13/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit
import CoreData

class EmailHelperClass: NSObject {

    var managedObjectsArray = [NSManagedObject?]()
    
    func sendReminderEmail() {
        // This function is only called once every 24 hours at most, and won't be called until someone opens SelectUsersTableViewController at least 24 hours after the last time SelectUsersTableViewController was opened
        // Iterate through user array, figure out which ones owe money, then send an eMail to the affected users
        
        // Use managedObjectsArray as user data source

        print("Email Helper function has been executed")
    }
    
}
