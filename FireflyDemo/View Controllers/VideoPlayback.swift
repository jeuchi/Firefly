import UIKit
import AVFoundation

class VideoPlayback: UIViewController {

    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!

    var notificationObserver:NSObjectProtocol?
    var videoURL: URL!
    //connect this to your uiview in storyboard
    
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
    
    @IBAction func tappedDiscard(_ sender: Any) {
        
        // Confirm if user wants to delete
        let alert = UIAlertController(title: "", message: "Are you sure you want to delete?", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action: UIAlertAction!) in
            self.performSegue(withIdentifier: "goVideo", sender: nil)
          }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            return
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
