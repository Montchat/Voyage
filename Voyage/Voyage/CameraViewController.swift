//
//  CameraViewController.swift
//  Voyage
//
//  Created by Joe E. on 11/14/15.
//  Copyright © 2015 Joe E. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import AssetsLibrary

private let EMPTY_STRING = ""

class CameraViewController: UIViewController, UIGestureRecognizerDelegate, CLLocationManagerDelegate {
    
    //MARK: - @IBOutlets
    @IBOutlet var previewView: PreviewView!
    @IBOutlet weak var record: RecordButton!
    @IBOutlet weak var recordedPictureImageView: UIImageView!
    @IBOutlet weak var recordedView: UIView! // this is the pictureView
    @IBOutlet weak var cancelImageButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    
    //MARK: - @IBActions
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        recordedView.hidden = true
        recordedPictureImageView.image = nil
        messageTextField.hidden = true
        messageTextField.text = EMPTY_STRING
        print("hidden")
        
    }
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        toCamera()
        
    }
    
    func toCamera() {
        recordedView.hidden = true
        recordedPictureImageView.image = nil
        
    }
    
    func burnImage() {
        if messageTextField.hidden == false {
            let textLayer = CATextLayer()
            textLayer.frame = messageTextField.bounds
            textLayer.position = messageTextField.layer.position
            
            guard let message = messageTextField.text else { return }
            guard let font = messageTextField.font else { return }
            guard let fontColor = messageTextField.textColor else { return }
            
            textLayer.string = message
            textLayer.font = font
            textLayer.foregroundColor = fontColor.CGColor
            textLayer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.50).CGColor

            textLayer.wrapped = true
            textLayer.alignmentMode = kCAAlignmentCenter
            textLayer.contentsScale = UIScreen.mainScreen().scale
            
            recordedView.layer.addSublayer(textLayer)
            
            //burn into the image using CT
            
        }
        
    }
    //MARK: - Properties
    //Session
    var session: AVCaptureSession?
    //Inputs
    var visualInput: AVCaptureDeviceInput?
    var audioInput: AVCaptureInput?
    
    //Outputs
    var stillImageOutput: AVCaptureStillImageOutput?
    var movieFileOutput: AVCaptureMovieFileOutput?
    //Errors
    var error: NSError?
    //Timers
    var timer: NSTimer?
    
    var captureTime:Double = 0.0
    let maxCaptureTime: Double = 10.0
    var isCapturing = false
    
    //MARK: - sessionQueue
    var sessionQueue: dispatch_queue_t!
    
    func moveProgress(touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        record.center = touch.locationInView(view)
        print( "recordCenter: \(record.center)")
        
    }
    
    //MARK - UIGestureRecognizers
    func tappedRecordButton(gestureRecognizer: UITapGestureRecognizer) {
        print("gestureRecognized")
        if let videoConnection = self.stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (sampleBuffer, error) -> Void in
                if sampleBuffer != nil {
                    var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    var dataProvider = CGDataProviderCreateWithCFData(imageData)
                    if var cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault) {
                        var image = UIImage(CGImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.Right)
                        self.recordedPictureImageView.image = image
                        self.recordedView.hidden = false
                        print("we did it")
                    }
                    self.recordedPictureImageView.hidden = false
                    
                }
                
            })
            
        }
        
    }
    
    //MARK: - gestureRecognizers
    @IBAction func moveVertically(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .Changed {
            print("working")
            let translation = recognizer.translationInView(view)
            
            if let view = recognizer.view {
                view.center = CGPoint(x:view.center.x, y:view.center.y + translation.y)
                recognizer.setTranslation(CGPointZero, inView: view)
                
            }
            
        }
        
    }
    
    @IBAction func tapGesture(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .Ended && messageTextField.hidden == true {
            messageTextField.text = ""
            messageTextField.hidden = false
            textFieldDidBeginEditing(messageTextField)
            
        }
        
        if recognizer.state == .Ended && messageTextField.hidden == false {
            UIView.animateWithDuration(0.33, animations: { () -> Void in
                self.messageTextField.resignFirstResponder()
                
            })
            
            print("mufasa")
            
        }
        
    }
    
    @IBAction func textButtonPressed(sender: AnyObject) {
        if messageTextField.hidden == true {
            messageTextField.hidden = false
            messageTextField.center = view.center
            
            
        } else if messageTextField.hidden == false {
            messageTextField.resignFirstResponder()
        }
        
    }
    
    @IBAction func recordButtonHeld(gestureRecognizer: UILongPressGestureRecognizer) {
        print("recognized")
        isCapturing = true
        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "updateCurrentTimer", userInfo: nil, repeats: true)
        
        if gestureRecognizer.state == .Ended {
            endCapture()
            timer?.invalidate()
            record.progressAmount = 0
            
        }
        
    }
    
    func updateCurrentTimer() {
        captureTime += 0.05
        record.progressAmount = CGFloat(captureTime / maxCaptureTime) * 10
        print(record.progressAmount)
        
        if captureTime >= maxCaptureTime {
            endCapture()
            
        }
        
    }
    
    func endCapture() {
        guard isCapturing else { return }
        isCapturing = false
        timer?.invalidate()
        timer = nil
        
    }
    
    
    //MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextField.delegate = self
        record.adjustsImageWhenHighlighted = false
        record.adjustsImageWhenDisabled = false
        
        let textFieldGestureRecognizer = UIGestureRecognizer(target: self, action: "moveVertically:")
        
        //        messageTextField.addGestureRecognizer(textFieldGestureRecognizer)
        
        textButton.setTitle("T", forState: .Normal)
        textButton.setTitleColor(UIColor.blackColor().colorWithAlphaComponent(0.50), forState: .Normal)
        cancelImageButton.setTitle("X", forState: .Normal)
        cancelImageButton.setTitleColor(UIColor.blackColor().colorWithAlphaComponent(0.50), forState: .Normal)
        messageTextField.hidden = true
        
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tappedRecordButton:")
        tapGestureRecognizer.delegate = self
        
        recordedPictureImageView.hidden = true
        recordedView.hidden = true
        
        let session: AVCaptureSession = AVCaptureSession()
        self.session = session
        
        previewView.session = session
        
        let sessionQueue: dispatch_queue_t = dispatch_queue_create("sessionQueue", DISPATCH_QUEUE_SERIAL)
        self.sessionQueue = sessionQueue
        
        dispatch_async(sessionQueue) { () -> Void in
            
            let preferredPosition: AVCaptureDevicePosition = AVCaptureDevicePosition.Unspecified
            
            let videoDevice: AVCaptureDevice = CameraViewController.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: preferredPosition)
            var videoDeviceInput: AVCaptureDeviceInput?
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            } catch let error1 as NSError {
                self.error = error1
                videoDeviceInput = nil
            } catch {
                fatalError()
            }
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.visualInput = videoDeviceInput
                
            }
            
            let audioDevice: AVCaptureDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio).first as! AVCaptureDevice
            var audioDeviceInput: AVCaptureDeviceInput?
            
            do {
                audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            } catch let error2 as NSError? {
                self.error = error2
                audioDeviceInput = nil
            } catch {
                fatalError()
            }
            
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
                self.audioInput = audioDeviceInput
                
            }
            
            let movieFileOutput:AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
            if session.canAddOutput(movieFileOutput) {
                session.addOutput(movieFileOutput)
                self.movieFileOutput = movieFileOutput
            }
            
            let stillImageOutput:AVCaptureStillImageOutput = AVCaptureStillImageOutput()
            if session.canAddOutput(stillImageOutput) {
                stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                session.addOutput(stillImageOutput)
                self.stillImageOutput = stillImageOutput
                print("stillImageSet")
                print(stillImageOutput)
            }
            
            session.startRunning()
            self.record.addGestureRecognizer(tapGestureRecognizer)
            
        }
        
    }
    
    //MARK: - viewDidAppear()
    override func viewDidAppear(animated: Bool) {
        
    }
    
    //MARK: - viewDidDisappear()
    override func viewWillDisappear(animated: Bool) {
        dispatch_async(self.sessionQueue) { () -> Void in
            self.session?.stopRunning()
        }
        
    }
    
    class func deviceWithMediaType(mediaType: String, preferringPosition: AVCaptureDevicePosition) -> AVCaptureDevice {
        var devices = AVCaptureDevice.devicesWithMediaType(mediaType)
        var captureDevice: AVCaptureDevice = devices[0] as! AVCaptureDevice
        for device in devices {
            if device.position == preferringPosition {
                captureDevice = device as! AVCaptureDevice
                break
                
            }
        }
        
        return captureDevice
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}

extension CameraViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField.text == EMPTY_STRING {
            textField.hidden = true
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
        if textField.text == EMPTY_STRING {
            textField.hidden = true
            
        }
        
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        return true
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        UIView.animateWithDuration(0.33) { () -> Void in
            textField.center = self.view.center
            
        }
        
    }
    
}
