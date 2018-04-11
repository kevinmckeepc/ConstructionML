//
//  CaptureController.swift
//  ConstructionML
//
//  Created by Kevin McKee on 4/11/18.
//  Copyright © 2018 Kevin McKee. All rights reserved.
//

import UIKit
import CoreML
import AVFoundation

class CaptureController: UIViewController {

    @IBOutlet weak var predictionLabel: UILabel? {
        didSet {
            predictionLabel?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    @IBOutlet weak var captureView: CaptureView? {
        didSet {
            captureView?.session = captureSession
        }
    }

    private let model = Inceptionv3()
    private let captureSession = AVCaptureSession()

    private lazy var numberFormatter: NumberFormatter = {
       let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }
    
    private func prepareSession() {
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.beginConfiguration()
            
            if captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
            }
            
            let dataOutput = AVCaptureVideoDataOutput()
            
            dataOutput.videoSettings = [((kCVPixelBufferPixelFormatTypeKey as NSString) as String) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange as UInt32)]
            
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if captureSession.canAddOutput(dataOutput) == true {
                captureSession.addOutput(dataOutput)
            }
            
            captureSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.procore.video-output")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
            
        } catch {
            print(error)
        }
    }
}

extension CaptureController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        guard let image = UIImage(ciImage: ciImage).resizeTo(CGSize(width: 299, height: 299)), let pixelBuffer = image.buffer() else {
            return
        }

        guard let output = try? model.prediction(image: pixelBuffer) else {
            return
        }

        DispatchQueue.main.async {
            let probability = output.classLabelProbs[output.classLabel] ?? 0
            let formatted = self.numberFormatter.string(for: probability) ?? ""
            self.predictionLabel?.text = "\(output.classLabel): \(formatted)"
        }
    }
}
