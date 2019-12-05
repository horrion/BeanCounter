//
//  ViewController.swift
//  BeanCounter
//
//  Created by Robert Horrion on 10/8/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Face Recognition", style: .plain, target: self, action: #selector(faceRecognition))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Show Payment Info", style: .plain, target: self, action: #selector(showPaymentInfoButton))
    }

    @objc func showPaymentInfoButton() {
        performSegue(withIdentifier: "paymentInfoSegue", sender: self)
    }
    
    @objc func faceRecognition() {
        
        // Implement face recognition here
        
    }

}

