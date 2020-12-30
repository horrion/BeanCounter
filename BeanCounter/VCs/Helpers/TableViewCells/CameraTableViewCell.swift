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

    enum originController {
        case createController
        case editController
    }
    
    var sourceController: originController?
    
    var embeddedInTableViewController: CreateNewUserTableViewController?
    var parentIsEditViewController: EditUserTableViewController?
    
    var outputImageView: UIImageView?
    
    var cellAlreadyDidLoad: Bool?
    
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var imageTaken: UIImage?
    
    //var orientationFromWindow: UIDeviceOrientation?
    var imageOrientation: UIImage.Orientation = .down

    //var flashMode = AVCaptureDevice.FlashMode.off
    var cameraPosition = AVCaptureDevice.Position.front
    var rearCameraSelected = AVCaptureDevice.DeviceType.builtInWideAngleCamera
    
    var didTakePhoto = false
    
    @IBOutlet weak var takePictureButtonOutlet: UIButton!
    
    @IBOutlet weak var previewView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //fixOrientation()
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.cellAlreadyDidLoad == nil {
            self.cellDidLoad()
            self.cellAlreadyDidLoad = true
        }
        
        fixOrientation()
        
        
    }
    
    func fixOrientation() {
        // Call function here to get orientation value
        
        if let connection =  self.previewLayer?.connection  {
            
            let previewLayerConnection : AVCaptureConnection = connection
            if previewLayerConnection.isVideoOrientationSupported {

                if let interfaceOrientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation {
                    
                    switch interfaceOrientation {
                    case .portrait:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                        
                        imageOrientation = .leftMirrored
                        print("Portrait down detected")
                        
                    case .landscapeRight:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                        
                        imageOrientation = .downMirrored
                        print("Landscape right detected")
                    
                    case .landscapeLeft:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                        
                        imageOrientation = .upMirrored
                        print("Landscape left detected")
                        
                    case .portraitUpsideDown:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                        
                        imageOrientation = .rightMirrored
                        print("Portrait upside down detected")
                        
                    default:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                        
                        imageOrientation = .up
                        print("Default detected")
                    }
                }
            }
        }
    }
    
    // Helper function for getting the videoLayer orientation right
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        
        layer.videoOrientation = orientation
        previewLayer.frame = previewView.bounds
    }
    
    // Use this as a viewDidLoad method to load the camera cell after the ViewController has been loaded to prevent long load times for the ViewController
    func cellDidLoad() {
        
        loadCameraPreview()
        
        if didTakePhoto == false {
            // Set button label appropriately
            takePictureButtonOutlet.titleLabel?.text = "Try Again"
            
        } else {
            // Set button label appropriately
            takePictureButtonOutlet.titleLabel?.text = "Take Picture"
            
        }
    }
    
    func loadCameraPreview() {
        // Do camera setup here
        captureSession = AVCaptureSession()
        cameraOutput = AVCapturePhotoOutput()
        previewLayer = AVCaptureVideoPreviewLayer()
        
        
        let device = AVCaptureDevice.default(rearCameraSelected, for: AVMediaType.video, position: cameraPosition)
        
        if captureSession?.inputs.first != nil {
            captureSession?.removeInput((captureSession?.inputs.first!)!)
        }
        
        if let input = try? AVCaptureDeviceInput(device: device!) {
            if ((captureSession?.canAddInput(input))!) {
                captureSession?.addInput(input)
                if ((captureSession?.canAddOutput(cameraOutput!))!) {
                    
                    //cameraOutput.availableRawPhotoFileTypes =
                    captureSession?.addOutput(cameraOutput!)
                    
                    
                    // Next, the previewLayer is setup to show the camera content with the size of the view.
                    
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                    previewLayer?.frame = previewView.bounds
                    previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    previewView.clipsToBounds = true
                    previewView.layer.addSublayer(previewLayer!)
                    captureSession?.startRunning()
                }
            } else {
                print("Cannot add output")
            }
        }
    }
    
    @IBAction func didPressTakePhoto(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        
        if didTakePhoto == false {
            // Set button label appropriately
            takePictureButtonOutlet.titleLabel?.text = "Try Again"
            
            // Capture the photo
            cameraOutput?.capturePhoto(with: settings, delegate: self)
            
        } else {
            // Set button label appropriately
            takePictureButtonOutlet.titleLabel?.text = "Take Picture"
            
            // Remove the view from previewView
            outputImageView?.removeFromSuperview()
            
            // Then restore the camera preview
            previewView.layer.addSublayer(previewLayer!)
            
            // Restore ability to take photos again
            didTakePhoto = false
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Image Picker helper
    
    func setImagePreview(imageToPreview: UIImage) {
        // Remove preview first, then add photo taken
        previewLayer.removeFromSuperlayer()
        
        outputImageView = UIImageView(image: imageToPreview)
        outputImageView!.contentMode = .scaleAspectFill
        outputImageView!.frame = CGRect(x: 0, y: 0, width: previewView.frame.size.width, height: previewView.frame.size.height)
        previewView.addSubview(outputImageView!)
        
        didTakePhoto = true
        
        // Set button label appropriately
        takePictureButtonOutlet.titleLabel?.text = "Try Again"
    }
    
    // MARK: Photo Capture Delegate handling
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("output registered")
        
        if let error = error {
            print(error.localizedDescription)
        }
        
        // Create the CGImage from AVCapturePhoto
        let cgImage = photo.cgImageRepresentation()!.takeUnretainedValue()
        
        // Create the UIImage
        let imageFromDeviceOrientation = UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation)
        
        // Show photo preview in previewView after photo has been taken
        // Remove preview first, then add photo taken
        previewLayer.removeFromSuperlayer()
        
        outputImageView = UIImageView(image: imageFromDeviceOrientation)
        outputImageView!.contentMode = .scaleAspectFill
        outputImageView!.frame = CGRect(x: 0, y: 0, width: previewView.frame.size.width, height: previewView.frame.size.height)
        previewView.addSubview(outputImageView!)
        
        didTakePhoto = true
        
        // Pass the UIImage on to the originating VC
        if sourceController == .createController {
            
            // embeddedInTableViewController is parent VC
            embeddedInTableViewController?.saveImageData(imageToSave: imageFromDeviceOrientation)
            
        } else {
            
            // parentIsEditViewController is parent VC
            parentIsEditViewController?.saveImageData(imageToSave: imageFromDeviceOrientation)
            
        }
    }

}
