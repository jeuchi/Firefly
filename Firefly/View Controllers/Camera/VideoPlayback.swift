import UIKit
import AVFoundation
import AVKit

class VideoPlayback: UIViewController, UINavigationControllerDelegate & UIVideoEditorControllerDelegate {

    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!

    @IBOutlet weak var editButton: UIButton!
    
    var notificationObserver:NSObjectProtocol?
    var videoURL: [URL]!
    var copyURLS: [URL] = []
    var editURL: URL!
    var arrayVideos: [AVAsset] = []
    var mergedURL: URL? = nil
    var mergedCopy: URL? = nil
    var currEdit: Int = 0
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var discardButton: UIButton!
    
    var currentEditController: UIVideoEditorController? = nil
    var myCollectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoView.layer.insertSublayer(avPlayerLayer, at: 0)
    
        view.layoutIfNeeded()
    
        arrayVideos.removeAll()
        
        for url in videoURL {
            let asset = AVAsset(url: url)
            arrayVideos.append(asset)
            copyURLS.append(url)
        }
        merge(arrayVideos: arrayVideos) { (URL, Error) in
            if (Error != nil) {
                print("Error \(Error?.localizedDescription)")
            }else {
                self.mergedURL = URL!
                self.mergedCopy = URL!
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
        
        createEditorController(url: mergedURL!)
        
        createCollection()
    }
    
    func createCollection() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 60, height: 60)
        
        let collectionFrame = CGRect(x: 0, y: view.bounds.height/4, width: view.bounds.width, height: view.bounds.height/6)
        myCollectionView = UICollectionView(frame: collectionFrame, collectionViewLayout: layout)
        myCollectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
        myCollectionView?.backgroundColor = UIColor.white
        

        myCollectionView?.dataSource = self
        myCollectionView?.delegate = self
        
        view.addSubview(myCollectionView ?? UICollectionView())
    }
    
    func videoEditorController(_ editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
    
        avPlayer.pause()
        let asset = AVAsset(url: URL(fileURLWithPath: editedVideoPath))
        
        videoURL[currEdit] = URL(fileURLWithPath: editedVideoPath)
        arrayVideos[currEdit] = asset
       
        removeCurrentEditor(controller: currentEditController!)
       
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
    
    func videoEditorControllerDidCancel(_ editor: UIVideoEditorController) {
        removeCurrentEditor(controller: currentEditController!)
        currentEditController = nil
        avPlayer.play()
    }
    
    func createEditorController(url: URL) {
        if UIVideoEditorController.canEditVideo(atPath: url.path) {
            let editController = UIVideoEditorController()
            currentEditController = editController
            editController.videoPath = url.path
            editController.delegate = self
            
            addChild(editController)
            editController.view.frame = CGRect(x: 0, y: view.bounds.height/2, width: view.bounds.width, height: view.bounds.height/2)
            view.addSubview(editController.view)
            didMove(toParent: self)
        }
    }
    
    func removeCurrentEditor(controller: UIVideoEditorController) {
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
    }
    
    @IBAction func tappedDiscard(_ sender: Any) {
        
        // Confirm if user wants to delete
        let alert = UIAlertController(title: "", message: "Are you sure you want to delete?", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action: UIAlertAction!) in
            self.mergedURL = nil
            self.arrayVideos.removeAll()
            self.videoURL.removeAll()
            self.dismiss(animated: true, completion: nil)
            //self.performSegue(withIdentifier: "goVideo", sender: nil)
          }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            return
          }))
        
        
        alert.addAction(UIAlertAction(title: "Start Over", style: .default, handler: { (action: UIAlertAction!) in
            self.arrayVideos.removeAll()
            self.videoURL = self.copyURLS
            for url in self.videoURL {
                let asset = AVAsset(url: url)
                self.arrayVideos.append(asset)
                self.copyURLS.append(url)
            }
            self.merge(arrayVideos: self.arrayVideos) { (URL, Error) in
                if (Error != nil) {
                    print("Error \(Error?.localizedDescription)")
                }else {
                    self.mergedURL = URL!
                    self.mergedCopy = URL!
                    let playerItem = AVPlayerItem(url: URL! as URL)
                    self.avPlayer.replaceCurrentItem(with: playerItem)
                    
                    self.editURL = URL!
                    self.avPlayer.play()
                        
                    self.loopVideo(videoPlayer: self.avPlayer)
                }
            }
          }))

        present(alert, animated: true, completion: nil)
    }
    
    func loopVideo(videoPlayer: AVPlayer) {
        notificationObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem, queue: .main) { [weak self] _ in
            videoPlayer.seek(to: CMTime.zero)
            videoPlayer.play()
        }
    }
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async { //1
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbImage = UIImage(cgImage: cgThumbImage) //7
                DispatchQueue.main.async { //8
                    completion(thumbImage) //9
                }
            } catch {
                print(error.localizedDescription) //10
                DispatchQueue.main.async {
                    completion(nil) //11
                }
            }
        }
    }
}

extension VideoPlayback: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoURL.count // How many cells to display
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath)
        
        let imageview:UIImageView=UIImageView(frame: CGRect(x: 50, y: 50, width: 200, height: 200));

        getThumbnailImageFromVideoUrl(url: videoURL[indexPath.row]) { (image) in
            imageview.image = image
        }

        myCell.backgroundView = imageview

           
        return myCell
    }
}

extension VideoPlayback: UICollectionViewDelegate {
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       print("User tapped on item \(indexPath.row)")
        editURL = videoURL[indexPath.row]
        currEdit = indexPath.row
        
        removeCurrentEditor(controller: currentEditController!)
        createEditorController(url: editURL)
    
    }
    
}
