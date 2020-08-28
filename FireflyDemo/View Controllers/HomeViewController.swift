//
//  HomeViewController.swift
//  FireflyDemo
//
//  Created by Jeremy  on 8/23/20.
//  Copyright © 2020 Jeremy . All rights reserved.
//

import UIKit
import Firebase
import AVKit

class HomeViewController: UIViewController {

    let db = Firestore.firestore()
    var avPlayer = AVPlayer()
    var avPlayerLayer:AVPlayerLayer!
    
    
    var arrayVideos: [String] = []
    var arrayURLs: [URL] = []
    var indexOfVideos = 0
    var maxIndex = 0
    
    @IBOutlet weak var WelcomeText: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        view.layoutIfNeeded()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Most viewed videos sorted
        self.WelcomeText.alpha = 1
        let videosRef = db.collection("videos")
        videosRef.order(by: "views", descending: false)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        self.arrayVideos.append(document.get("path") as! String)
                        self.maxIndex+=1
                    }
                    self.cacheVideosAsUrls()
                    
                    // recognize swipes up and down
                    let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(sender:)))
                           upSwipe.direction = .up
                    let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(sender:)))
                    upSwipe.direction = .up
                    downSwipe.direction = .down
                    self.view.addGestureRecognizer(upSwipe)
                    self.view.addGestureRecognizer(downSwipe)
                }
        }
        
    }
    
    @IBAction func onClickCamera(_ sender: UIButton) {
        performSegue(withIdentifier: "record", sender: nil)
    }
    
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            switch sender.direction {
                case .up:
                    if indexOfVideos < (maxIndex-1) {
                        indexOfVideos+=1
                        playVideo(url: arrayURLs[indexOfVideos])
                    }
                case .down:
                    if indexOfVideos >= 1 {
                        indexOfVideos-=1
                        playVideo(url: arrayURLs[indexOfVideos])
                    }
                default:
                    break
            }
        }
    }
    
    func cacheVideosAsUrls() {
        let firebaseGroup = DispatchGroup()
        
        for index in 0...(maxIndex-1) {
            firebaseGroup.enter()
            print(arrayVideos)
            let storageRef = Storage.storage().reference(withPath: arrayVideos[index])
            storageRef.getData(maxSize: 20 * 1024 * 1024) { (data, error) in
                if let error = error {
                    print("Got an error fetching data: \(error.localizedDescription)")
                    return
                } else {
                    storageRef.downloadURL { (url, error) in
                        if let error = error {
                            print("Error generating URL \(error.localizedDescription)")
                            return
                        }
                        if let url = url {
                            self.arrayURLs.append(url)
                        }
                    }
                }
                firebaseGroup.leave()
            }
        }
        firebaseGroup.notify(queue: .main) {
            print("Finished all requests.")
            self.WelcomeText.alpha = 0
            print("URLS: \(self.arrayURLs)")
            self.playVideo(url: self.arrayURLs[self.indexOfVideos])
        }
    }
    
    

    func playVideo(url: URL)  {
        let playerItem = AVPlayerItem(url: url as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
        avPlayer.play()
            
        loopVideo(videoPlayer: avPlayer)
    }
        
    func loopVideo(videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem, queue: .main) { [weak self] _ in
        videoPlayer.seek(to: CMTime.zero)
        videoPlayer.play()
        }
    }
}
