//
//  FaceRecognitionViewController.swift
//  BeanCounter
//
//  Created by Robert Horrion on 12/13/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit

class FaceRecognitionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneUserButton))
    }
    
    @objc func doneUserButton() {
        self.dismiss(animated: true, completion: nil)
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
