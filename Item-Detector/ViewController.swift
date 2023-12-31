//
//  ViewController.swift
//  Item-Detector
//
//  Created by Jerry Li on 12/24/23.
//

import UIKit
import SwiftUI
import AVFoundation // used for accessing the camera
import Vision

// LAYERS TOP TO BOTTOM
// bounding boxes
// detectionLayer
// previewLayer (live camera feed)
// self.view.layer


class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
    private var permissionGranted = false;  // checks if the device allows camera usage
    
    // let are const variables
    // these two gets the data from the camera
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    
    // displays the camera data
    private var previewLayer = AVCaptureVideoPreviewLayer()
    var screenRect: CGRect! = nil   // for view dimensions, CGRect is a UIKit rectangle object
    
    // variables for the item detector
    private var videoOutput = AVCaptureVideoDataOutput()
    var requests = [VNRequest]()    // an array of VNRequest objects
    var detectionLayer: CALayer! = nil  // before detecting anything its nil

    // once the app opens override the view with the live camera if permission is granted
    override func viewDidLoad() {
        checkPermission()   // before continuing to the async commands check if permission is granted
        
        sessionQueue.async { [unowned self] in
            guard permissionGranted else{return}
            self.setupCaptureSession()
            self.setupLayers()  // function from extention 
            self.setupDetector()   // function from extension
            self.captureSession.startRunning()
        }
    }

    // if the phone is flipped change the camera from vertical to horizontal
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        screenRect = UIScreen.main.bounds
        self.previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)

        // adjusts the camera based on orientation
        switch UIDevice.current.orientation{
            // Home button on top
        case UIDeviceOrientation.portraitUpsideDown:
            self.previewLayer.connection?.videoRotationAngle = 270

            // Home button on right
        case UIDeviceOrientation.landscapeLeft:
            self.previewLayer.connection?.videoRotationAngle = 0

            // Home button on left
        case UIDeviceOrientation.landscapeRight:
            self.previewLayer.connection?.videoRotationAngle = 180
            
            // Home button on bottom
        case UIDeviceOrientation.portrait:
            self.previewLayer.connection?.videoRotationAngle = 90
            
        default: break
        }
        
        updateLayers()  // updates the detection layer if there is a orientation change
    }
    
    func checkPermission(){
        // switch statement for prompting user for camera access
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .authorized:
        permissionGranted = true
        
        case .notDetermined:
        requestPermission()
            
        default:
            permissionGranted = false
        }
    }
    
    func requestPermission(){
        // pauses the async until the user has granted permission
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video , completionHandler: { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
            
        })
    }
    
    // sets up the capture device and provides captured data for other objects
    func setupCaptureSession(){
        // access camera
        guard let videoDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) else {return}
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {return}
        
        guard captureSession.canAddInput(videoDeviceInput) else {return}
        captureSession.addInput(videoDeviceInput)
        
        // preview layer
        screenRect = UIScreen.main.bounds
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        previewLayer.connection?.videoOrientation = .portrait
        
        // detector
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession.addOutput(videoOutput)
        
        videoOutput.connection(with: .video)?.videoOrientation = .portrait
        
        // updates the UI in the main queue
        DispatchQueue.main.async { [weak self] in
            self!.view.layer.addSublayer(self!.previewLayer)
        }
    }
}

struct HostedViewController: UIViewControllerRepresentable {
    // returns a UIViewController object
    func makeUIViewController(context: Context) -> UIViewController{
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
}

