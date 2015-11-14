//
//  PreviewView.swift
//  CameraFunctionality
//
//  Created by Joe E. on 10/20/15.
//  Copyright © 2015 Joe E. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class PreviewView: UIView {
    var session: AVCaptureSession? {
        get {
            return (self.layer as! AVCaptureVideoPreviewLayer).session
            
        }
        
        set (session) {
        (self.layer as! AVCaptureVideoPreviewLayer).session = session
            
        }
        
    }
    
    override class func layerClass() -> AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    
}