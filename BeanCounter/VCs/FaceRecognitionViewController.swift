//
//  FaceRecognitionViewController.swift
//  BeanCounter
//
//  Created by Robert Horrion on 12/13/19.
//  Copyright © 2019 Robert Horrion. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import SFaceCompare
import KeychainSwift

class FaceRecognitionViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    var managedObjectsArray = [NSManagedObject?]()
    var imagesFromCoreDataArray = [UIImage?]()
    
    var transactionsManagedObjectsArray = [NSManagedObject?]()
    
    var mainViewController: ViewController?
    
    var indexSelected: Int?
    
    var cameraTimer: Timer?
    
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var imageTaken: UIImage?
    
    var orientationFromWindow: UIDeviceOrientation?

    var cameraPosition = AVCaptureDevice.Position.front
    var rearCameraSelected = AVCaptureDevice.DeviceType.builtInWideAngleCamera
    
    
    @IBOutlet weak var previewView: UIView!
    
    
    //MARK: - App Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // UINavigationBar Setup
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneUserButton))
        
        // This will rotate the camera when the device orientation changes
        let didRotate: (Notification) -> Void = { notification in
            self.fixOrientation()
        }
        
        // Device orientation has changed, update the camera
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main, using: didRotate)
        
        
        getDataFromCoreData()
        loadTransactionsFromCoreData()
    
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
    
    @objc func doneUserButton() {
        self.dismiss(animated: true, completion: nil)
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
    
    func performPasscodeSegue() {
        performSegue(withIdentifier: "getUserPasscodeForFaceRecognition", sender: self)
    }
    
    //MARK: - CoreData helper
    
    // Get images for Face compare from CoreData and save them to an Array for faster access
    func getDataFromCoreData() {
        
        // Create context for context info stored in AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        // Reset Array to empty Array
        managedObjectsArray.removeAll()
        
        // Iterate through all NSManagedObjects in NSFetchRequestResult
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                let index = managedObjectsArray.count
                
                // New method, just save the whole NSManagedObject, then read from it later on
                managedObjectsArray.insert(data, at: index)
                
                // next few lines are for debugging
                let firstName = data.value(forKey: "firstname") as! String
                let lastName = data.value(forKey: "lastname") as! String
                let eMail = data.value(forKey: "email") as! String
                
                // Check if user saved a photo
                if data.value(forKey: "photo") != nil {
                    
                    // Get photos and save them in a separate array as UIImages with matching array index values
                    let imageFromCoreData = data.value(forKey: "photo") as! Data

                    let uiImageValue = UIImage(data: imageFromCoreData)
                    imagesFromCoreDataArray.insert(uiImageValue, at: index)
                    
                    print("photo was found for user: " + firstName + " " + lastName + " (" + eMail + ")")
                    
                } else {
                    // User didn't save a photo
                    imagesFromCoreDataArray.insert(nil, at: index)
                    
                    print("photo wasn't found for user: " + firstName + " " + lastName + " (" + eMail + ")")
                }
            }
            
        } catch {
            print("failed to fetch data from context")
        }
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
        
        // Set up an attempt counter to count how many accounts have been checked
        var attemptCounter = 0
        
        // Get the MatchingCoefficient from UserDefaults to determine the minimum matching likelihood required
        let matchingCoefficientFromUserDefaults = UserDefaults.standard.double(forKey: "matchingCoefficient")
        
        // Create a dict to save all matching coefficients
        var matchingCoeffDict = [Int:Double]()
        
        // Compare the photo captured with the ones in imagesFromCoreDataArray
        for (index, userPhoto) in imagesFromCoreDataArray.enumerated() {
            
            // Weed out the users who didn't save a profile picture
            if userPhoto != nil {
                
                print("Firstname: ")
                print(self.managedObjectsArray[index]?.value(forKey: "firstname") as! String)
                
                // Compare userPhoto from array with photo from camera
                let faceComparator = SFaceCompare(on: userPhoto!, and: faceFromCamera)
                
                faceComparator.compareFaces { [self] result in
                    switch result {
                    case .failure(let error):
                      
                        // Add matching coefficient value to the dictionary
                        matchingCoeffDict[index] = 1.1
                        
                        // Raise attemptCounter by 1
                        attemptCounter += 1
                        
//                        print("Faces don't match with more than 1.0 matching coefficient!")
                        print(error)
                        
                        print("AttemptCounter: " + String(attemptCounter))
                        
                        if attemptCounter == imagesFromCoreDataArray.count {
                            
                            print("Dict: ")
                            print(matchingCoeffDict)
                            
                            // All images in the array have been checked
                            self.pickUserWithBestMatch(matchingCoeffDict: matchingCoeffDict)
                        }
                    
                    case .success(let data):
                        // faces match
                        
                        // If the matchingCoefficient is smaller than the one defined in UserDefaults, a likely match is found
                        if data.probability <= matchingCoefficientFromUserDefaults {
                            
                            // Add matching coefficient value to the dictionary
                            matchingCoeffDict[index] = data.probability
                            
                            // Raise attemptCounter by 1
                            attemptCounter += 1
                            
//                            print("Matching probability: " + String(data.probability))
                            
                            print("AttemptCounter: " + String(attemptCounter))
                            
                            if attemptCounter == imagesFromCoreDataArray.count {
                                
                                print("Dict: ")
                                print(matchingCoeffDict)
                                
                                // All images in the array have been checked
                                self.pickUserWithBestMatch(matchingCoeffDict: matchingCoeffDict)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func pickUserWithBestMatch(matchingCoeffDict: Dictionary<Int, Double>) {
        
        if matchingCoeffDict.isEmpty == false {
            // If the dictionary contains data at least one match has been found
            
            
            
            
            // TODO: Remove after debugging
            print("MatchingCoeffDict:")
            print(matchingCoeffDict)
            
            
            
            
            // Lower matchingCoefficient means higher matching likelihood
            let bestMatch = matchingCoeffDict.min { a, b in a.value < b.value }
            
            if bestMatch!.value <= 1 {
                
            
                print("Best Match coefficient: " + String(bestMatch!.value))
                
                // Save indexSelected for later access when billing the user for coffee and when checking the Passcode
                self.indexSelected = bestMatch?.key
                
                // Set variables from managedObject
                let firstName = self.managedObjectsArray[bestMatch!.key]?.value(forKey: "firstname") as! String
                let lastName = self.managedObjectsArray[bestMatch!.key]?.value(forKey: "lastname") as! String
                let eMail = self.managedObjectsArray[bestMatch!.key]?.value(forKey: "email") as! String
                
                let userIDString = firstName + " " + lastName + " (" + eMail + ")"
                
                
                print("Faces Match! ")
                print("Hello, : " + userIDString)
                
                let alertController = UIAlertController(title: "Would you like some coffee?", message: "Hi, " + userIDString, preferredStyle: .alert)
                
                let dismissAction = UIAlertAction(title: "No", style: .default)
                let coffeeAction = UIAlertAction(title: "Yes", style: .default) { action in
                    
                    // invalidate the timer, you found the person!
                    self.cameraTimer?.invalidate()
                    
                    // Get "faceRecPasscode" to determine whether to require a passcode when using face recognition
                    let recIsActivated = UserDefaults.standard.bool(forKey: "faceRecPasscode")
                    
                    // Ask for user passcode if enabled in settings
                    if recIsActivated == true {
                        // Passcode protection is enabled
                        self.performPasscodeSegue()
                    } else {
                        // Passcode protection isn't enabled
                        self.writeBilledCoffeeToDatabase()
                    }
                    
                }
                
                alertController.addAction(dismissAction)
                alertController.addAction(coffeeAction)
                self.present(alertController, animated: true)
            }
        }
    }
    
    func billUserForCoffee(passcodeReturned: String) {
        
        // Get UUID from managed object
        let uuidFromManagedObject = managedObjectsArray[indexSelected!]!.value(forKey: "userUUID") as! NSUUID
        
        // Get keychain value using UUID
        let keychain = KeychainSwift()
        let userPasscode = keychain.get(uuidFromManagedObject.uuidString)
        
        // Check to see if passcode entered matches the one in the keychain
        if userPasscode == passcodeReturned {
            // The passcodes matched, bill the user for coffee!
            
            writeBilledCoffeeToDatabase()
            
            
        } else {
         // Provided passcode was wrong, alert the user
            
            let alert = UIAlertController(title: "Wrong passcode", message: "You entered the wrong passcode, please try again!", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(dismissAction)
            self.present(alert, animated: true)
        }
    }
    
    func writeBilledCoffeeToDatabase() {
        
        // Get current coffee price from NSUserDefaults
        let userDefaults = UserDefaults.standard
        let coffeePriceAsInt = userDefaults.integer(forKey: "CoffeePrice")
        let coffeePriceAsInt64 = Int64(coffeePriceAsInt)
        
        // Read and print balance before making changes to saved data
        let balanceBeforeChanges = managedObjectsArray[indexSelected!]?.value(forKey: "balanceInCents") as! Int64
        print("balance before changes: " + String(balanceBeforeChanges))
        
        
        // Save new balance
        let newBalance = balanceBeforeChanges - coffeePriceAsInt64
        managedObjectsArray[indexSelected!]?.setValue(newBalance, forKey: "balanceInCents")
        
        
        // Write the transaction to the TransactionsForUser entity in CoreData
        CoreDataHelperClass.init().saveNewTransaction(userForTransaction: managedObjectsArray[indexSelected!] as! User,
                                                      dateTime: Date(),
                                                      monetaryValue: -coffeePriceAsInt64,
                                                      transactionType: "Coffee")
        
        // Read and print balance before making changes to saved data
        let balanceAfterChanges = managedObjectsArray[indexSelected!]?.value(forKey: "balanceInCents") as! Int64
        print("balance after changes: " + String(balanceAfterChanges))
        
        // Save number of coffee cups for stats screen
        saveCurrentNumberOfTransactionsToCoreData(numberOfCups: 1)
        
        // Create instance of MOC
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Save newUserInfo to CoreData
        do {
           try context.save()
            // Data was successfully saved
            print("successfully saved data")
            
            self.dismiss(animated: true, completion: nil)
            
            // This viewcontroller is already in the process of being dismissed. Call the alertview on mainViewController to avoid viewController hierarchy issues.
            mainViewController?.billedForCoffeeSuccessfullyAlert()
            
            
          } catch {
            // Failed to write to the database
            print("Couldn't save to CoreData")

            let alert = UIAlertController(title: "Failed Database Operation", message: "Failed to write to the Database", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(dismissAction)
            self.present(alert, animated: true)
        }
    }
    
    
    //MARK: - Transaction helpers
    func loadTransactionsFromCoreData() {
        
        // Create context for context info stored in AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
                
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Transactions")
        
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        // Reset Array to empty Array
        transactionsManagedObjectsArray.removeAll()
        
        // Iterate through all NSManagedObjects in NSFetchRequestResult
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                // Save the whole NSManagedObject, then read from it later on
                transactionsManagedObjectsArray.insert(data, at: transactionsManagedObjectsArray.count)
                
                
          }
            
        } catch {
            print("failed to fetch data from context")
        }
    }
    
    func saveCurrentNumberOfTransactionsToCoreData(numberOfCups: Int64) {
        
        // Create context for context info stored in AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Load all transactions to always have access to the current data
        loadTransactionsFromCoreData()
        
        let date = Date()
        let calendar = Calendar.current
        
        let dateString = String(calendar.component(.year, from: date)+calendar.component(.month, from: date)+calendar.component(.day, from: date))
        
        
        if let matchingIndex = transactionsManagedObjectsArray.firstIndex(where: {$0!.value(forKey: "date") as! String == dateString}) {
            // Object was found, this is not the first cup today!
            let priorTransactions = transactionsManagedObjectsArray[matchingIndex]?.value(forKey: "numberOfTransactions") as! Int64
            let sumOfCupsToday = priorTransactions + numberOfCups
            
            print("Sum of cups today is: " + String(sumOfCupsToday))
            
            transactionsManagedObjectsArray[matchingIndex]?.setValue(sumOfCupsToday, forKey: "numberOfTransactions")
            
        } else {
            // item could not be found
            
            // Create entity, then create a transactionInfo object
            let entity = NSEntityDescription.entity(forEntityName: "Transactions", in: context)
            let transactionInfo = NSManagedObject(entity: entity!, insertInto: context)

            // Provide newUserInfo object with properties
            transactionInfo.setValue(dateString, forKey: "date")
            transactionInfo.setValue(numberOfCups, forKey: "numberOfTransactions")
        }
        
        // Save transactionInfo to CoreData
        do {
           try context.save()
            // Data was successfully saved, now pop the VC
            print("successfully saved stats data")
            mainViewController!.reloadStatsLabel()
            
          } catch {
           print("Couldn't save stats to CoreData")
            
            //Remind user to make sure all info has been provided / all fields are populated
            
            let alert = UIAlertController(title: "Failed Database Operation", message: "Failed to write stats to the Database", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(dismissAction)
            self.present(alert, animated: true)
        }
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        // Tell the destination ViewController that you're trying to access the user passcode
        if segue.identifier == "getUserPasscodeForFaceRecognition" {
            if let navigationViewController = segue.destination as? UINavigationController {
                if let passcodeViewController = navigationViewController.viewControllers[0] as? SetPasscodeViewController {
                    passcodeViewController.userLevel = .getUserForFaceRecognition
                    passcodeViewController.faceRecognitionController = self
                }
            }
        }
    }
    

}
