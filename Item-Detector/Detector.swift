//
//  Detector.swift
//  Item-Detector
//
//  Created by Jerry Li on 12/28/23.
//

import UIKit
import AVFoundation // used for accessing the camera
import Vision

extension ViewController{
    func setupDetector(){
        let modelURL = Bundle.main.url(forResource: "YOLOv3TinyInt8LUT", withExtension: "mlmodelc")
        do{
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL!))
            let recoginitions = VNCoreMLRequest(model: visionModel, completionHandler: detectionDidComplete)
            self.requests = [recoginitions]
        } catch let error{
            print(error)
        }
    }
    
    
    func setupLayers(){
        detectionLayer = CALayer()
        detectionLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)     // sets it to the dimensions of the screen
        
        self.view.layer.addSublayer(detectionLayer)
//        DispatchQueue.main.async { [weak self] in
//            self!.view.layer.addSublayer(self!.detectionLayer)
//        }
    }
    
    
    func updateLayers(){
        detectionLayer?.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
    }
    
    
    // checks if any bounding boxes needs to be drawn based on the detection
    func detectionDidComplete(request: VNRequest, error: Error?){
        // adds the bounding boxes into the main queue
        DispatchQueue.main.async(execute: {
            if let results = request.results {
                self.extractDetections(results)
            }
        })
    }
    
    
    func extractDetections(_ results: [VNObservation]){
        detectionLayer.sublayers = nil
        for observation in results where observation is VNRecognizedObjectObservation{
            guard let objectObservation = observation as? VNRecognizedObjectObservation else{continue}

            if let recognizedObject = objectObservation.labels.first {
                let label = recognizedObject.identifier
                let confidence = recognizedObject.confidence
                        
                print("Found object: \(label), confidence: \(confidence)")
                
                // transformation of the VNRecognizedObjectObservation (detected bounding box location) grid to the CALayer (rectangular area that displays content like graphics) grid
                let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(screenRect.size.width), Int(screenRect.size.height))
                let transformBounds = CGRect(x: objectBounds.minX, y: screenRect.size.height - objectBounds.maxY, width: objectBounds.maxX - objectBounds.minX, height: objectBounds.maxY - objectBounds.minY)

                let boxLayer = self.drawBoundingBox(transformBounds, label: label)  // pass bounds and label to drawBoundingBox
                        
                detectionLayer.addSublayer(boxLayer)
            }
        }
    }
    
    func drawBoundingBox(_ bounds: CGRect, label: String) -> CALayer{
        // bounding box
        let boxLayer = CALayer()
        boxLayer.frame = bounds
        boxLayer.borderWidth = 3.0
        boxLayer.borderColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        boxLayer.cornerRadius = 4
        
        // text label
        let textLayer = CATextLayer()
        textLayer.string = label
        textLayer.fontSize = 12
        textLayer.foregroundColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        textLayer.frame = CGRect(x: 0, y: -15, width: bounds.width, height: 15)
        textLayer.alignmentMode = .center
        boxLayer.addSublayer(textLayer)
        
        return boxLayer
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:]) // creates a handler to perform a reuqest on the buffer
        
        do{
            try imageRequestHandler.perform(self.requests)  // schedules vision requests to be performed
        } catch {
            print(error)
        }
    }
    

}
