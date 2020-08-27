import UIKit

import AVFoundation

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    @IBOutlet weak var camPreview: UIView!
    
    @IBOutlet weak var filterButton: UIButton!

    @IBOutlet weak var cameraButton: UIButton!
    var pulsePoint: CGPoint = CGPoint(x: 207, y: 788)
    
    var frontCamera: AVCaptureDevice?
    var backCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var whichCam: String?
    private var videoFilterOn: Bool = false
    

    let captureSession = AVCaptureSession()

    let movieOutput = AVCaptureMovieFileOutput()

    var previewLayer: AVCaptureVideoPreviewLayer!

    var activeInput: AVCaptureDeviceInput!

    var outputURL: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        if setupSession() {
            setupPreview()
            startSession()
        }
    
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right

        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        cameraButton.isUserInteractionEnabled = true
    
        let cameraButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.startCapture))
    
        cameraButton.addGestureRecognizer(cameraButtonRecognizer)

    
        camPreview.addSubview(cameraButton)
    
    }
    
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer)
    {
        if sender.direction == .left
        {
           print("Swipe left")
           // show the view from the right side
        }

        if sender.direction == .right
        {
           print("Swipe right")
           performSegue(withIdentifier: "backHome", sender: self)
        }
    }
    
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = camPreview.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        camPreview.layer.addSublayer(previewLayer)
        
    }

    //MARK:- Setup Camera

    func setupSession() -> Bool {
    
        captureSession.sessionPreset = AVCaptureSession.Preset.high
    
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:
        [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera],
        mediaType: .video, position: .unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            } else if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            }
        }
        
        currentCamera = frontCamera
        whichCam = "front"
    
        do {
        
            let input = try AVCaptureDeviceInput(device: currentCamera!)
        
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
    
        // Setup Microphone
        let microphone = AVCaptureDevice.default(for: AVMediaType.audio)!
    
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }
    
    
        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
    
        return true
    }

    func setupCaptureMode(_ mode: Int) {
        // Video Mode
    
    }

    //MARK:- Camera Session
    func startSession() {
    
        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }

    func stopSession() {
        if captureSession.isRunning {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }

    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }

    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
    
        switch UIDevice.current.orientation {
            case .portrait:
                orientation = AVCaptureVideoOrientation.portrait
           // case .landscapeRight:
                //orientation = AVCaptureVideoOrientation.landscapeLeft
         //  case .portraitUpsideDown:
              //  orientation = AVCaptureVideoOrientation.portraitUpsideDown
            default:
                 orientation = AVCaptureVideoOrientation.portrait
         }
    
         return orientation
     }

    @objc func startCapture() {
    
        startRecording()
    
    }

    //EDIT 1: I FORGOT THIS AT FIRST

    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
    
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
    
        return nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "showVideo":
                let vc = segue.destination as! VideoPlayback
                vc.videoURL = sender as? URL
            case "backHome":
                let vc = segue.destination as! HomeViewController
            default:
                break
                
        }
    }

    func startRecording() {
    
        if movieOutput.isRecording == false {
            let pulse = PulseAnimation(numberOfPulse: Float.infinity, radius: 60, postion: pulsePoint)
                   pulse.animationDuration = 1.0
                   pulse.backgroundColor = #colorLiteral(red: 0.8993218541, green: 0.1372507513, blue: 0.2670814395, alpha: 1)
                   self.view.layer.insertSublayer(pulse, below: self.view.layer)
        
            let connection = movieOutput.connection(with: AVMediaType.video)
            
        
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }
        
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
        
            let device = activeInput.device
        
            if (device.isSmoothAutoFocusSupported) {
            
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                   print("Error setting configuration: \(error)")
                }
            
            }
        
            //EDIT2: And I forgot this
            outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
        
            }
            else {
                stopRecording()
            }
    
       }

   func stopRecording() {
    
       if movieOutput.isRecording == true {
           movieOutput.stopRecording()
        self.view.layer.sublayers?.popLast()
        }
   }

    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            
            let videoRecorded = outputURL! as URL
            
            performSegue(withIdentifier: "showVideo", sender: videoRecorded)
        }
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    
        if (error != nil) {
        
            print("Error recording movie: \(error!.localizedDescription)")
        
        } else {
        
            let videoRecorded = outputURL! as URL
        
            performSegue(withIdentifier: "showVideo", sender: videoRecorded)
        
        }
    
    }

    @IBAction func doubleTapFlipCamera(_ sender: Any) {
        if movieOutput.isRecording == false {
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:
            [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera],
            mediaType: .video, position: .unspecified)
            let devices = deviceDiscoverySession.devices
            
            for device in devices {
                if device.position == AVCaptureDevice.Position.front {
                    frontCamera = device
                } else if device.position == AVCaptureDevice.Position.back {
                    backCamera = device
                }
            }
            if(whichCam == "front") {
                currentCamera = backCamera
                whichCam = "back"
            } else {
                currentCamera = frontCamera
                whichCam = "front"
            }
            
                do {
                
                    let input = try AVCaptureDeviceInput(device: currentCamera!)
                    for ii in captureSession.inputs {
                      captureSession.removeInput(ii as! AVCaptureInput)
                    }
                    if captureSession.canAddInput(input) {
                        print("yes")
                        captureSession.addInput(input)
                        activeInput = input
                    }
                    
                } catch {
                    print("Error setting device video input: \(error)")
                }
        }
    }
    
    @IBAction func tappedFilterButton(_ sender: Any) {
        videoFilterOn = !videoFilterOn
        let filteringEnabled = videoFilterOn
        
        let stateImage = UIImage(named: filteringEnabled ? "ColorFilterOn" : "ColorFilterOff")
        self.filterButton.setImage(stateImage, for: .normal)
    }
    
    
}
