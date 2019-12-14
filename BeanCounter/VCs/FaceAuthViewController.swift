//
//  FaceAuthViewController.swift
//  BeanCounter
//
//  Created by Robert Horrion on 12/14/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit
import AVFoundation
import SFaceCompare

class FaceAuthViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    var imageToMatch: UIImage?
    var selectedIndexPath: IndexPath?
    
    var selectUsersTVController: SelectUsersTableViewController?
    
    var cameraTimer: Timer?
    
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var imageTaken: UIImage?
    
    var orientationFromWindow: UIDeviceOrientation?

    var cameraPosition = AVCaptureDevice.Position.front
    var rearCameraSelected = AVCaptureDevice.DeviceType.builtInWideAngleCamera
    
    @IBOutlet weak var previewView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // This will rotate the camera when the device orientation changes
        let didRotate: (Notification) -> Void = { notification in
            self.fixOrientation()
        }
        
        // Device orientation has changed, update the camera
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main, using: didRotate)
        
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
        
            
            fixOrientation()
        
            cameraTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                                    target: self,
                                                    selector: #selector(timerCalled),
                                                    userInfo: nil,
                                                    repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cameraTimer?.invalidate()
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
                        orientationFromWindow = .landscapeLeft
                        print("Portrait down detected")
                        
                    case .landscapeRight:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                        orientationFromWindow = .portrait
                        print("Landscape right detected")
                    
                    case .landscapeLeft:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                        orientationFromWindow = .landscapeRight
                        print("Landscape left detected")
                        
                    case .portraitUpsideDown:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                        orientationFromWindow = .portraitUpsideDown
                        print("Portrait upside down detected")
                        
                    default:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                        orientationFromWindow = .portrait
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

    //MARK: Compare Faces here
    @objc func timerCalled() {
        // Take a photo here, this happens once a second
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        
        cameraOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: Photo Capture Delegate handling
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
        }
        
        // Create the CGImage from AVCapturePhoto
        let cgImage = photo.cgImageRepresentation()!.takeUnretainedValue()
        
        // Get the orientation from Window
        let altOrientation = (orientationFromWindow?.rawValue)!
        let uiImageOrientation = UIImage.Orientation(rawValue: altOrientation)!
        
        // Create the UIImage
        let imageFromDeviceOrientation = UIImage(cgImage: cgImage, scale: 1, orientation: uiImageOrientation)
        
        // Take the resulting image and compare it with the ones on record
        compareFaces(faceFromCamera: imageFromDeviceOrientation)
    }
    
    func compareFaces(faceFromCamera: UIImage) {
        
        // Compare userPhoto from CoreData with photo from camera
        let faceComparator = SFaceCompare(on: imageToMatch!, and: faceFromCamera)
                
            faceComparator.compareFaces(succes: { results in
                // faces match
                print("Faces Match! ")
                
                // invalidate the timer, found the person!
                self.cameraTimer?.invalidate()
                
                //Save indexPath to SelectUserVC & reload table
                self.selectUsersTVController!.unlockUser(indexPathToUnlock: self.selectedIndexPath!)
                
                // When it's all said and done, dismiss the ViewController
                self.navigationController?.popViewController(animated: true)
                    
            }, failure: {  error in
                print("Faces don't match!")
            })
            
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
