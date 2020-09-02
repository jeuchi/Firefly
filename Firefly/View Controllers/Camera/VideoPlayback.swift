import UIKit
import AVFoundation

class VideoPlayback: UIViewController, UINavigationControllerDelegate & UIVideoEditorControllerDelegate {

    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!

    @IBOutlet weak var editButton: UIButton!
    
    var notificationObserver:NSObjectProtocol?
    var videoURL: URL!
    var editURL: URL!
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var discardButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoView.layer.insertSublayer(avPlayerLayer, at: 0)
    
        view.layoutIfNeeded()
    
        let playerItem = AVPlayerItem(url: videoURL as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
    
        editURL = videoURL
        avPlayer.play()
        
        loopVideo(videoPlayer: avPlayer)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self.notificationObserver)
        avPlayer.pause()
        avPlayerLayer.player = nil
        avPlayerLayer.removeFromSuperlayer()
    }
    
    @IBAction func tappedEdit(_ sender: Any) {
        avPlayer.pause()
        if UIVideoEditorController.canEditVideo(atPath: editURL.path) {
            let editController = UIVideoEditorController()
            editController.videoPath = editURL.path
            editController.delegate = self
            
            var topMostViewController = UIApplication.shared.keyWindow?.rootViewController

            while let presentedViewController = topMostViewController?.presentedViewController {
                topMostViewController = presentedViewController
            }
            topMostViewController?.present(editController, animated: true) {
                print("edit now")
            }
        }
    }
    
    func videoEditorController(_ editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
        avPlayer.pause()
        editURL = URL(fileURLWithPath: editedVideoPath)
        let playerItem = AVPlayerItem(url: editURL as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
        avPlayer.play()
        loopVideo(videoPlayer: avPlayer)
        
    }
    
    func videoEditorControllerDidCancel(_ editor: UIVideoEditorController) {
        dismiss(animated: true, completion: nil)
        avPlayer.play()
    }
    
    @IBAction func tappedDiscard(_ sender: Any) {
        
        // Confirm if user wants to delete
        let alert = UIAlertController(title: "", message: "Are you sure you want to delete?", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
            //self.performSegue(withIdentifier: "goVideo", sender: nil)
          }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            return
          }))
        
        
        alert.addAction(UIAlertAction(title: "Start Over", style: .default, handler: { (action: UIAlertAction!) in
            self.editURL = self.videoURL
            let playerItem = AVPlayerItem(url: self.videoURL as URL)
            self.avPlayer.replaceCurrentItem(with: playerItem)
            self.avPlayer.play()
            self.loopVideo(videoPlayer: self.avPlayer)
          }))

        present(alert, animated: true, completion: nil)
    }
    
    func loopVideo(videoPlayer: AVPlayer) {
        notificationObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem, queue: .main) { [weak self] _ in
            videoPlayer.seek(to: CMTime.zero)
            videoPlayer.play()
        }
    }
}
