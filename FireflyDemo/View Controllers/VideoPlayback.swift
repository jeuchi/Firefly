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
        performSegue(withIdentifier: "goVideo", sender: nil)
    }
    
    func loopVideo(videoPlayer: AVPlayer) {
        notificationObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem, queue: .main) { [weak self] _ in
            videoPlayer.seek(to: CMTime.zero)
            videoPlayer.play()
        }
    }
}
