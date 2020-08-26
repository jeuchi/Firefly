import UIKit
import AVFoundation

class VideoPlayback: UIViewController {

    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!

    var videoURL: URL!
    //connect this to your uiview in storyboard
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var toolTip: UILabel!
    @IBOutlet weak var gestureImages: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.toolTip.center = CGPoint(x: 50, y: 10)

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
    @IBAction func showToolTip(_ sender: Any) {
        toolTip.alpha = 1

        UIView.animate(withDuration: 1) {
            self.gestureImages.alpha = 1
            self.gestureImages.transform = CGAffineTransform(rotationAngle: -1.6)
            self.toolTip.center = CGPoint(x: 90, y: 90)
        }
    }
    
    func loopVideo(videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem, queue: .main) { [weak self] _ in
        videoPlayer.seek(to: CMTime.zero)
        videoPlayer.play()
        }
    }
}
