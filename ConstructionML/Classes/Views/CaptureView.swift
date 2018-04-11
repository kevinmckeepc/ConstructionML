//
//  CaptureView.swift
//  ConstructionML
//
//  Created by Kevin McKee on 4/11/18.
//  Copyright © 2018 Kevin McKee. All rights reserved.
//

import UIKit
import AVFoundation

class CaptureView: UIView {
 
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    weak var session: AVCaptureSession? {
        didSet {
            guard let layer = layer as? AVCaptureVideoPreviewLayer else {
                return
            }
            layer.session = session
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .black
        layer.backgroundColor = UIColor.black.cgColor
        layer.masksToBounds = true
        
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            return
        }
        layer.videoGravity = .resizeAspectFill
    }
    
}
