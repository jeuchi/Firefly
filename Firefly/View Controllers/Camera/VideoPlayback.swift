import UIKit
import AVFoundation
import AVKit

class VideoPlayback: UIViewController, UINavigationControllerDelegate & UIVideoEditorControllerDelegate {

    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!

    @IBOutlet weak var editButton: UIButton!
    
    var notificationObserver:NSObjectProtocol?
    var videoURL: [URL]!
    var editURL: URL!
    var arrayVideos: [AVAsset] = []
    var mergedURL: URL? = nil
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var discardButton: UIButton!
    
    let editController = UIVideoEditorController()
    var myCollectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoView.layer.insertSublayer(avPlayerLayer, at: 0)
    
        view.layoutIfNeeded()
    
        for url in videoURL {
            let asset = AVAsset(url: url)
            arrayVideos.append(asset)
        }
        merge(arrayVideos: arrayVideos) { (URL, Error) in
            if (Error != nil) {
                print("Error \(Error?.localizedDescription)")
            }else {
                self.mergedURL = URL!
                let playerItem = AVPlayerItem(url: URL! as URL)
                self.avPlayer.replaceCurrentItem(with: playerItem)
                
                self.editURL = URL!
                self.avPlayer.play()
                    
                self.loopVideo(videoPlayer: self.avPlayer)
            }
        }
    }
    
    func merge(arrayVideos:[AVAsset], completion:@escaping (URL?, Error?) -> ()) {

      let mainComposition = AVMutableComposition()
      let compositionVideoTrack = mainComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
      compositionVideoTrack?.preferredTransform = CGAffineTransform(rotationAngle: .pi / 2)

      let soundtrackTrack = mainComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)

        var insertTime = CMTime.zero

      for videoAsset in arrayVideos {
        try! compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .video)[0], at: insertTime)
        try! soundtrackTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .audio)[0], at: insertTime)

        insertTime = CMTimeAdd(insertTime, videoAsset.duration)
      }

      let outputFileURL = URL(fileURLWithPath: NSTemporaryDirectory() + "merge.mp4")

      let fileManager = FileManager()
      try? fileManager.removeItem(at: outputFileURL)

      let exporter = AVAssetExportSession(asset: mainComposition, presetName: AVAssetExportPresetHighestQuality)

      exporter?.outputURL = outputFileURL
      exporter?.outputFileType = AVFileType.mp4
      exporter?.shouldOptimizeForNetworkUse = true

      exporter?.exportAsynchronously {
        if let url = exporter?.outputURL{
            completion(url, nil)
        }
        if let error = exporter?.error {
            completion(nil, error)
        }
      }
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
        if UIVideoEditorController.canEditVideo(atPath: mergedURL!.path) {
            editController.videoPath = mergedURL!.path
            editController.delegate = self
            
            addChild(editController)
            editController.view.frame = CGRect(x: 0, y: view.bounds.height/2, width: view.bounds.width, height: view.bounds.height/2)
            view.addSubview(editController.view)
            didMove(toParent: self)
        }
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 60, height: 60)
        
        let collectionFrame = CGRect(x: 0, y: view.bounds.height/4, width: view.bounds.width, height: view.bounds.height/6)
        myCollectionView = UICollectionView(frame: collectionFrame, collectionViewLayout: layout)
        myCollectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
        myCollectionView?.backgroundColor = UIColor.white
        

        myCollectionView?.dataSource = self
        //myCollectionView?.delegate = self
        
        view.addSubview(myCollectionView ?? UICollectionView())
    }
    
    func videoEditorController(_ editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
    
        avPlayer.pause()
        editURL = URL(fileURLWithPath: editedVideoPath)
        let playerItem = AVPlayerItem(url: editURL as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
        
        editController.willMove(toParent: nil)
        editController.view.removeFromSuperview()
        editController.removeFromParent()
        avPlayer.play()
        loopVideo(videoPlayer: avPlayer)
        
    }
    
    func videoEditorControllerDidCancel(_ editor: UIVideoEditorController) {
        editController.willMove(toParent: nil)
        editController.view.removeFromSuperview()
        editController.removeFromParent()
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
            self.editURL = self.videoURL[0]
            let playerItem = AVPlayerItem(url: self.videoURL[0] as URL)
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

extension VideoPlayback: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9 // How many cells to display
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath)
        myCell.backgroundColor = UIColor.blue
        return myCell
    }
}
