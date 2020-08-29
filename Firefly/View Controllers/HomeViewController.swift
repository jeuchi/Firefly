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
    var avItem:AVPlayerItem?
    var avPlayerLayer:AVPlayerLayer!
    
    var avPlayerTemp = AVPlayer()
    var avPlayerLayerTemp:AVPlayerLayer!
    var avItemTemp:AVPlayerItem?
    
    var currentLayer: String = "main"
    
    var isVideoPlaying: Bool = false
    
    var initialCenter = CGPoint()
    var arrayVideos: [String] = []
    var arrayURLs: [URL] = []
    var indexOfVideos = 0
    var maxIndex = 0
    
    @IBOutlet weak var WelcomeText: UILabel!
    @IBOutlet weak var cameraUIButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        avPlayerLayerTemp = AVPlayerLayer(player: avPlayerTemp)
        //avPlayerLayerTemp.frame = view.bounds
        avPlayerLayerTemp.videoGravity = AVLayerVideoGravity.resizeAspectFill
        //view.layer.insertSublayer(avPlayerLayerTemp, at: 0)
        
        view.layoutIfNeeded()
        // Do any additional setup after loading the view.
        
        // Most viewed videos sorted
        self.WelcomeText.alpha = 1
        self.cameraUIButton.alpha = 1
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
                    
                    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panPiece(sender:)))
                    self.view.addGestureRecognizer(panGesture)
                }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("recording? \(isVideoPlaying)")
        if !isVideoPlaying {
            avPlayer.play()
            avPlayer.play()
            isVideoPlaying = true
        }
    }
    
    
    @IBAction func onClickCamera(_ sender: UIButton) {
        avPlayer.pause()
        isVideoPlaying = false
        performSegue(withIdentifier: "record", sender: nil)
    }
    
    @objc func panPiece(sender: UIPanGestureRecognizer) {
        guard sender.view != nil else {return}
        let piece = sender.view!
        
        // Get the changes in the X and Y directions relative to
        // the superview's coordinate space.
        let translation = sender.translation(in: piece.superview)
        
        if sender.state == .began {
            switch currentLayer {
            case "main":
                avPlayerLayerTemp.frame = view.bounds
                view.layer.insertSublayer(avPlayerLayerTemp, at: 0)
                if indexOfVideos < (maxIndex-1) {
                    avItemTemp = AVPlayerItem(url: arrayURLs[indexOfVideos+1] as URL)
                    avPlayerTemp.replaceCurrentItem(with: avItemTemp)
                }
            default:
                avPlayerLayer.frame = view.bounds
                view.layer.insertSublayer(avPlayerLayer, at: 0)
                if indexOfVideos < (maxIndex-1) {
                    avItem = AVPlayerItem(url: arrayURLs[indexOfVideos+1] as URL)
                    avPlayer.replaceCurrentItem(with: avItem)
                }
            }
            
        }
        
        // Update the position for the .began, .changed, and .ended states
        if sender.state != .cancelled {
           // Add the X and Y translation to the view's original position.

            switch currentLayer {
            case "main":
                avPlayerLayer.frame = CGRect(x: 0, y: 0 + translation.y, width: self.view.frame.width, height: self.view.frame.height)
            default:
                avPlayerLayerTemp.frame = CGRect(x: 0, y: 0 + translation.y, width: self.view.frame.width, height: self.view.frame.height)
            }
            
        }
        
        if sender.state == .ended {
            // All fingers are lifted.
            // print(translation.y)
            //print(avPlayerLayer.frame.minY)
            
            switch currentLayer {
            case "main":
                if avPlayerLayer.frame.minY > 450 && translation.y > 0 {
                    //print("video up")
                    avPlayerLayer.frame = CGRect(x: 1110, y: 1100, width: self.view.frame.width, height: self.view.frame.height)
                    
                    if indexOfVideos < (maxIndex-1) {
                        indexOfVideos+=1
                        if currentLayer == "main" {
                            currentLayer = "temp"
                        } else {
                            currentLayer = "main"
                        }
                        playVideo(url: arrayURLs[indexOfVideos])
                    }
                }else if avPlayerLayer.frame.minY < -450 && translation.y < 0 {
                    print("video down")
                    avPlayerLayer.frame = CGRect(x: 0, y: -1100, width: self.view.frame.width, height: self.view.frame.height)
                    if indexOfVideos >= 1 {
                        indexOfVideos-=1
                        if currentLayer == "main" {
                            currentLayer = "temp"
                        } else {
                            currentLayer = "main"
                        }
                        playVideo(url: arrayURLs[indexOfVideos])
                    }
                } else {
                    avPlayerLayer.frame = view.bounds
                }
            default:
                if avPlayerLayerTemp.frame.minY > 450 && translation.y > 0 {
                    //print("video up")
                    avPlayerLayerTemp.frame = CGRect(x: 0, y: 1100, width: self.view.frame.width, height: self.view.frame.height)
                    if indexOfVideos < (maxIndex-1) {
                        indexOfVideos+=1
                        if currentLayer == "main" {
                            currentLayer = "temp"
                        } else {
                            currentLayer = "main"
                        }
                        playVideo(url: arrayURLs[indexOfVideos])
                    }
                }else if avPlayerLayerTemp.frame.minY < -450 && translation.y < 0 {
                    print("video down")
                    avPlayerLayerTemp.frame = CGRect(x: 0, y: -1100, width: self.view.frame.width, height: self.view.frame.height)
                    if indexOfVideos >= 1 {
                        indexOfVideos-=1
                        if currentLayer == "main" {
                            currentLayer = "temp"
                        } else {
                            currentLayer = "main"
                        }
                        playVideo(url: arrayURLs[indexOfVideos])
                    }
                } else {
                    avPlayerLayerTemp.frame = view.bounds
                }
            }
            
        }
    }
    

    

    func cacheVideosAsUrls() {
        let firebaseGroup = DispatchGroup()
        
        //TEMP INSTEAD OF FETCH
        let bundlePath = Bundle.main.path(forResource: "LoginVideo", ofType: "mp4")
        let tempurl = URL(fileURLWithPath: bundlePath!)
        maxIndex = 10
        
        for index in 0...(maxIndex-1) {
            firebaseGroup.enter()
            print(arrayVideos)
            let storageRef = Storage.storage().reference(withPath: arrayVideos[0]) //CHANGE TO index
            storageRef.getData(maxSize: 20 * 1024 * 1024) { (data, error) in
                if let error = error {
                    print("Got an error fetching data: \(error.localizedDescription)")
                    
                    self.arrayURLs.append(tempurl)
                    firebaseGroup.leave()
                } else {
                    storageRef.downloadURL { (url, error) in
                        if let error = error {
                            print("Error generating URL \(error.localizedDescription)")
                            firebaseGroup.leave()
                        }
                        if let url = url {
                            self.arrayURLs.append(url)
                            firebaseGroup.leave()
                        }
                    }
                }
            }
        }
        firebaseGroup.notify(queue: .main) {
            print("Finished all requests.")
            self.WelcomeText.alpha = 0
            //print("URLS: \(self.arrayURLs)")
            self.initialVideo(url: self.arrayURLs[self.indexOfVideos])
        }
    }
    
    func initialVideo(url: URL) {
        avItem = AVPlayerItem(url: url as URL)
        avPlayer.replaceCurrentItem(with: avItem)
        avPlayer.play()
        loopVideo(videoPlayer: avPlayer)
    }
    

    func playVideo(url: URL)  {
        
        if currentLayer == "main" {
            avPlayer.play()
            
            avPlayerLayerTemp.frame = view.bounds
            view.layer.insertSublayer(avPlayerLayerTemp, at: 0)
            avPlayerTemp.pause()
            loopVideo(videoPlayer: avPlayer)
        } else {
            avPlayerTemp.play()
            
            avPlayerLayer.frame = view.bounds
            view.layer.insertSublayer(avPlayerLayer, at: 0)
            avPlayer.pause()
            loopVideo(videoPlayer: avPlayerTemp)
        }
        
        isVideoPlaying = true
    
    }
    
    @IBAction func tapPausePlay(_ sender: Any) {
        
        //TO DO: TEMP PAUSE TOO
        if isVideoPlaying {
            isVideoPlaying = false
            avPlayer.pause()
        } else {
            isVideoPlaying = true
            avPlayer.play()
        }
    }
    
    func loopVideo(videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem, queue: .main) { [weak self] _ in
            videoPlayer.seek(to: CMTime.zero)
            videoPlayer.play()
        }
    }
}
