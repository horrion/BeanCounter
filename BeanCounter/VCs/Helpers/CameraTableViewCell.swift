//
//  CameraTableViewCell.swift
//  BeanCounter
//
//  Created by Robert Horrion on 11/14/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit
import AVFoundation

class CameraTableViewCell: UITableViewCell, AVCapturePhotoCaptureDelegate {

    var captureSession = AVCaptureSession()
    var cameraOutput = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var currentImage: (image: Data, imageName: String)?

    var flashMode = AVCaptureDevice.FlashMode.off
    var cameraPosition = AVCaptureDevice.Position.front
    var rearCameraSelected = AVCaptureDevice.DeviceType.builtInWideAngleCamera
    
    @IBOutlet weak var previewView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        
        let device = AVCaptureDevice.default(rearCameraSelected, for: AVMediaType.video, position: cameraPosition)
        
        if captureSession.inputs.first != nil {
            captureSession.removeInput(captureSession.inputs.first!)
        }
        
        if let input = try? AVCaptureDeviceInput(device: device!) {
            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
                if (captureSession.canAddOutput(cameraOutput)) {
                    
                    //cameraOutput.availableRawPhotoFileTypes =
                    captureSession.addOutput(cameraOutput)
                    
                    
                    // Next, the previewLayer is setup to show the camera content with the size of the view.
                    
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer.frame = previewView.bounds
                    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    previewView.clipsToBounds = true
                    previewView.layer.addSublayer(previewLayer)
                    captureSession.startRunning()
                }
            } else {
                print("Cannot add output")
            }
        }
    }

    @IBAction func didPressTakePhoto(_ sender: UIButton) {
        var settings = AVCapturePhotoSettings()
        
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        if captureSession.isRunning {
//            captureSession.stopRunning()
//        } else {
//            //captureSession.startRunning()
//        }
//    }

}
