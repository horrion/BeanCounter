//
//  UnlockedTableViewCell.swift
//  BeanCounter
//
//  Created by Robert Horrion on 12/11/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit

class UnlockedTableViewCell: UITableViewCell {

    @IBOutlet weak var numberOfCoffeeCupsLabel: UILabel!
    @IBOutlet weak var stepperToAdjustCoffeeCupsOutlet: UIStepper!
    @IBAction func stepperChanged(_ sender: UIStepper){
        print(stepperToAdjustCoffeeCupsOutlet.value)
        let valueToSave = Int(stepperToAdjustCoffeeCupsOutlet.value)+1
        
        numberOfCoffeeCupsLabel.text = String(valueToSave)
        
        // Save to NSUserDefaults,
        // could also be done using delegate. NSUserDefaults are used here to avoid having to trace the stack to see if/where/when the value gets to its intended destination.
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(valueToSave, forKey: "multiplier")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        numberOfCoffeeCupsLabel.text = "1"
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        
    }

}
