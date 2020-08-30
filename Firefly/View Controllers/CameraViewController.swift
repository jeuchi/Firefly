import UIKit

import AVFoundation


class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
//AVCaptureFileOutputRecordingDelegate {

    // Storyboard buttons and preview layer
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var backFeedButton: UIButton!
    
    @IBOutlet weak var cameraButton: UIButton!
    var cameraSquareFrame: CGFloat = 0.0
    
    var pulsePoint: CGPoint = CGPoint(x: 207, y: 788)
    private var videoFilterOn: Bool = false
    
    private var movieOutput = AVCaptureMovieFileOutput()
    var previewView: AVCaptureVideoPreviewLayer!
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    
    // MARK: Discovery session
    private let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .unspecified)
    
    // MARK: Session Management
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    private let captureSession = AVCaptureSession()
    // Communicate with the session and other session objects on this queue.
    private let sessionQueue = DispatchQueue(label: "session queue")
    private var setupResult: SessionSetupResult = .success

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // set up swipe gestures [RIGHT: Home screen]
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        // set up cameraButton
        cameraButton.isUserInteractionEnabled = true
        cameraSquareFrame = cameraButton.layer.cornerRadius
        cameraButton.layer.cornerRadius = cameraButton.bounds.size.width / 2
        cameraButton.clipsToBounds = true
        
        /*
         Check the video authorization status. Video access is required and audio
         access is optional. If the user denies audio access, AVCam won't
         record audio during movie recording.
         */
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            let foundDevice = findDevices(in: AVCaptureDevice.Position.front)
            startSession(inputDevice: foundDevice)
            break
            
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. Suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
                let foundDevice = self.findDevices(in: AVCaptureDevice.Position.front)
                self.startSession(inputDevice: foundDevice)
            })
            
        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
        }
    }
    
    func findDevices(in position: AVCaptureDevice.Position) -> AVCaptureDevice {
        let devices = discoverySession.devices
        guard !devices.isEmpty else {fatalError("Missing capture devices.")}
        
        return devices.first(where: { device in device.position == position })!
    }
    
    // set up inputs and outputs and startRunning() capture session
    func startSession(inputDevice: AVCaptureDevice) {
        print("Starting session and found -> \(inputDevice)")
        captureSession.beginConfiguration()
        
        // video input
        guard
            let videoDeviceInputTry = try? AVCaptureDeviceInput(device: inputDevice),
            captureSession.canAddInput(videoDeviceInputTry)
        else { return }
        captureSession.addInput(videoDeviceInputTry)
        videoDeviceInput = videoDeviceInputTry
        
        // microphone input
        let microphone = AVCaptureDevice.default(for: AVMediaType.audio)!
        do {
            let microphoneDeviceInputTry = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(microphoneDeviceInputTry) {
                captureSession.addInput(microphoneDeviceInputTry)
            }
        } catch {
            print("Error setting audio device: \(error)")
        }
           
    
        print("Session inputs: \(captureSession.inputs)")
        
        // video output
        guard captureSession.canAddOutput(movieOutput) else { return }
        captureSession.sessionPreset = .hd1920x1080
        captureSession.addOutput(movieOutput)
        captureSession.commitConfiguration()
        print("Session outputs: \(captureSession.outputs)")
        
        // set up live viewing
        previewView = AVCaptureVideoPreviewLayer(session: captureSession)
        previewView.frame = preview.bounds
        previewView.videoGravity = AVLayerVideoGravity.resizeAspectFill
        preview.layer.addSublayer(previewView)
        
        // start data
        captureSession.startRunning()
    }
    
    
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer)
    {
        if sender.direction == .right
        {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func tappedBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)

    }
    
    
    
    @IBAction func tapRecord(_ sender: Any) {
        // Check if not recording
        if movieOutput.isRecording == false {
            
            // Set up pulse animation to notify user that recording is in progress
            let pulse = PulseAnimation(numberOfPulse: Float.infinity, radius: 60, postion: pulsePoint)
            pulse.animationDuration = 1.0
            pulse.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            pulse.name = "pulseAnimation"
            self.view.layer.insertSublayer(pulse, below:  self.view.layer)
            
            UIView.animate(withDuration: 0.3) {
                self.cameraButton.layer.cornerRadius = self.cameraSquareFrame
                self.cameraButton.clipsToBounds = false
            }
            
            // Start recording video to a temporary file.
                let outputFileName = NSUUID().uuidString
                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                movieOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
            } else {
                // remove pulsing animation layer
                removePulse()
            
                UIView.animate(withDuration: 0.1) {
                    self.cameraButton.layer.cornerRadius = self.cameraButton.bounds.size.width / 2
                    self.cameraButton.clipsToBounds = true
                }
    
                movieOutput.stopRecording()
            }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error != nil {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            let videoRecorded = outputFileURL
    
            performSegue(withIdentifier: "showVideo", sender: videoRecorded)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           switch segue.identifier {
               case "showVideo":
                   let vc = segue.destination as! VideoPlayback
                   vc.videoURL = sender as? URL
               case "backHome":
            print("backHome segue")
                   //let vc = segue.destination as! HomeViewController
               default:
                   break
                   
           }
       }
    
    func removePulse() {
        DispatchQueue.main.async {
            if let sublayers = self.view.layer.sublayers {
                for layer in sublayers {
                    if layer.name == "pulseAnimation" {
                        layer.removeFromSuperlayer()
                    }
                }
            }
        }
    }

    // Flips between front and back cameras when user double taps screen
    @IBAction func doubleTapFlipCamera(_ sender: Any) {
        
        print("video device: \(videoDeviceInput!)")
        
        // sessionQueue to avoid main queue
        sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position
            
            let preferredPosition: AVCaptureDevice.Position
            let preferredDeviceType: AVCaptureDevice.DeviceType
            
            // figure out either front->back or back->front
            switch currentPosition {
                case .unspecified, .front:
                    preferredPosition = .back
                    preferredDeviceType = .builtInDualCamera
                    
                case .back:
                    preferredPosition = .front
                    preferredDeviceType = .builtInTrueDepthCamera
                    
                @unknown default:
                    print("Unknown capture position. Defaulting to back, dual-camera.")
                    preferredPosition = .back
                    preferredDeviceType = .builtInDualCamera
            }
            let devices = self.discoverySession.devices
            var newVideoDevice: AVCaptureDevice? = nil
            
            // First, seek a device with both the preferred position and device type. Otherwise, seek a device with only the preferred position.
            if let device = devices.first(where: { $0.position == preferredPosition && $0.deviceType == preferredDeviceType }) {
                newVideoDevice = device
            } else if let device = devices.first(where: { $0.position == preferredPosition }) {
                newVideoDevice = device
            }
            
            if let videoDevice = newVideoDevice {
                do {
                    self.removePulse()
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    
                    self.captureSession.beginConfiguration()
                    
                    // Remove the existing device input first, because AVCaptureSession doesn't support
                    // simultaneous use of the rear and front cameras.
                    self.captureSession.removeInput(self.videoDeviceInput)
                    
                    if self.captureSession.canAddInput(videoDeviceInput) {
                        self.captureSession.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        self.captureSession.addInput(self.videoDeviceInput)
                    }
                    self.captureSession.commitConfiguration()
                } catch {
                    print("Error occurred while creating video device input: \(error)")
                }
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
