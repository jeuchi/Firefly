import UIKit

import AVFoundation

class CameraViewController: UIViewController {
//AVCaptureFileOutputRecordingDelegate {

    // Storyboard buttons
    
    @IBOutlet weak var preview: UIView!
    
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    var pulsePoint: CGPoint = CGPoint(x: 207, y: 788)
    var frontCamera: AVCaptureDevice?
    var backCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var whichCam: String?
    private var videoFilterOn: Bool = false
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
       // let cameraButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.startCapture))
       // cameraButton.addGestureRecognizer(cameraButtonRecognizer)
       //camPreview.addSubview(cameraButton)
        
        // Set up the video preview view.
        //previewView.session = session
        
        /*
         Check the video authorization status. Video access is required and audio
         access is optional. If the user denies audio access, AVCam won't
         record audio during movie recording.
         */
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            //print("authorized")
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
    
    // set up inputs and outputs and startrunning()
    func startSession(inputDevice: AVCaptureDevice) {
        print("Starting session and found -> \(inputDevice)")
        captureSession.beginConfiguration()
        
        guard
            let videoDeviceInputTry = try? AVCaptureDeviceInput(device: inputDevice),
            captureSession.canAddInput(videoDeviceInputTry)
        else { return }
        captureSession.addInput(videoDeviceInputTry)
        videoDeviceInput = videoDeviceInputTry
        print("Session inputs: \(captureSession.inputs)")
        
        let movieOutput = AVCaptureMovieFileOutput()
        guard captureSession.canAddOutput(movieOutput) else { return }
        captureSession.sessionPreset = .hd1920x1080
        captureSession.addOutput(movieOutput)
        captureSession.commitConfiguration()
        print("Session outputs: \(captureSession.outputs)")
        
        previewView = AVCaptureVideoPreviewLayer(session: captureSession)
        previewView.frame = preview.bounds
        previewView.videoGravity = AVLayerVideoGravity.resizeAspectFill
        preview.layer.addSublayer(previewView)
        
        captureSession.startRunning()
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
           //performSegue(withIdentifier: "backHome", sender: self)
        }
    }
    
    
    
    
    
    

/*
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
    } */


    /*
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    
        if (error != nil) {
        
            print("Error recording movie: \(error!.localizedDescription)")
        
        } else {
        
            let videoRecorded = outputURL! as URL
        
            performSegue(withIdentifier: "showVideo", sender: videoRecorded)
        
        }
    
    }*/

    @IBAction func doubleTapFlipCamera(_ sender: Any) {
        print("video device: \(videoDeviceInput)")
        sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position
            
            let preferredPosition: AVCaptureDevice.Position
            let preferredDeviceType: AVCaptureDevice.DeviceType
            
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
