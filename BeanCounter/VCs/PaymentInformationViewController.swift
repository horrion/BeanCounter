//
//  PaymentInformationViewController.swift
//  BeanCounter
//
//  Created by Robert Horrion on 12/5/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit

class PaymentInformationViewController: UIViewController {

    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var noInfoPresentLabel: UILabel!
    @IBOutlet weak var paymentStringLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneUserButton))
        
        displayQRCode()
    }
    
    @objc func doneUserButton() {
        self.dismiss(animated: true, completion: nil)
    }

    func displayQRCode() {
        
        // Get data from UserDefaults
        let userDefaults = UserDefaults.standard
        let paymentInfoString = userDefaults.string(forKey: "PaymentInfo")
        
        if paymentInfoString == nil {
            // No payment info has been entered yet, hide the imageView, show the label
            qrImageView.isHidden = true
            paymentStringLabel.isHidden = true
            noInfoPresentLabel.isHidden = false
        } else {
            
            // payment info has been entered, show the imageView
            qrImageView.isHidden = false
            paymentStringLabel.isHidden = false
            noInfoPresentLabel.isHidden = true
            
            let data = paymentInfoString?.data(using: String.Encoding.ascii)
            
            paymentStringLabel.text = paymentInfoString
            
            // Generate the QR code
            if let filter = CIFilter(name: "CIQRCodeGenerator") {
                filter.setValue(data, forKey: "inputMessage")
                let transform = CGAffineTransform(scaleX: 3, y: 3)
                
                if let output = filter.outputImage?.transformed(by: transform) {
                    
                    //Set the generated QR code as the image in qrImageView
                    qrImageView.image = UIImage(ciImage: output)
                }
            }
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
