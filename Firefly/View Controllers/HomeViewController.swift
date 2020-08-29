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
    var setVideoIndex: String = "none"
    
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
            switch currentLayer {
            case "main":
                avPlayer.play()
                avPlayer.play()
            default:
                avPlayerTemp.play()
                avPlayerTemp.play()
            }
            isVideoPlaying = true
        }
    }
    
    
    @IBAction func onClickCamera(_ sender: UIButton) {
        avPlayer.pause()
        avPlayerTemp.pause()
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
            setVideoIndex = "none"
            switch currentLayer {
            case "main":
                avPlayerTemp.replaceCurrentItem(with: nil)
                avPlayerLayerTemp.frame = view.bounds
                view.layer.insertSublayer(avPlayerLayerTemp, at: 0)
            
                /*if indexOfVideos < (maxIndex-1) {
                    avItemTemp = AVPlayerItem(url: arrayURLs[indexOfVideos+1] as URL)
                    avPlayerTemp.replaceCurrentItem(with: avItemTemp)
                }*/
            default:
                avPlayer.replaceCurrentItem(with: nil)
                avPlayerLayer.frame = view.bounds
                view.layer.insertSublayer(avPlayerLayer, at: 0)
                /*if indexOfVideos < (maxIndex-1) {
                    avItem = AVPlayerItem(url: arrayURLs[indexOfVideos+1] as URL)
                    avPlayer.replaceCurrentItem(with: avItem)
                }*/
            }
            
        }
        
        // Update the position for the .began, .changed, and .ended states
        if sender.state != .cancelled {
           // Add the X and Y translation to the view's original position.

            switch currentLayer {
            case "main":
                if setVideoIndex == "none" {
                    if translation.y > 0 {
                        setVideoIndex = "positive"
                        if indexOfVideos < (maxIndex-1) {
                            avItemTemp = AVPlayerItem(url: arrayURLs[indexOfVideos+1] as URL)
                            avPlayerTemp.replaceCurrentItem(with: avItemTemp)
                        } else {
                            avPlayerTemp.replaceCurrentItem(with: nil)
                        }
                    } else if translation.y < 0 {
                        setVideoIndex = "negative"
                        if indexOfVideos >= 1 {
                            avItemTemp = AVPlayerItem(url: arrayURLs[indexOfVideos-1] as URL)
                            avPlayerTemp.replaceCurrentItem(with: avItemTemp)
                        } else {
                            avPlayerTemp.replaceCurrentItem(with: nil)
                        }
                    }
                } else if setVideoIndex == "positive" {
                    if translation.y < 0 {
                         setVideoIndex = "negative"
                         if indexOfVideos >= 1 {
                             avItemTemp = AVPlayerItem(url: arrayURLs[indexOfVideos-1] as URL)
                             avPlayerTemp.replaceCurrentItem(with: avItemTemp)
                         } else {
                            avPlayerTemp.replaceCurrentItem(with: nil)
                        }
                    }
                } else if setVideoIndex == "negative" {
                    if translation.y > 0 {
                         setVideoIndex = "positive"
                         if indexOfVideos < (maxIndex-1) {
                             avItemTemp = AVPlayerItem(url: arrayURLs[indexOfVideos+1] as URL)
                             avPlayerTemp.replaceCurrentItem(with: avItemTemp)
                         } else {
                            avPlayerTemp.replaceCurrentItem(with: nil)
                        }
                    }
                }
                
                avPlayerLayer.frame = CGRect(x: 0, y: 0 + translation.y, width: self.view.frame.width, height: self.view.frame.height)
            default:
                if setVideoIndex == "none" {
                    if translation.y > 0 {
                       // print("Temp layer: above 0")
                        setVideoIndex = "positive"
                        if indexOfVideos < (maxIndex-1) {
                            avItem = AVPlayerItem(url: arrayURLs[indexOfVideos+1] as URL)
                            avPlayer.replaceCurrentItem(with: avItem)
                        } else {
                            avPlayer.replaceCurrentItem(with: nil)
                        }
                    } else if translation.y < 0 {
                       // print("Temp layer: below 0")
                        setVideoIndex = "negative"
                        if indexOfVideos >= 1 {
                            avItem = AVPlayerItem(url: arrayURLs[indexOfVideos-1] as URL)
                            avPlayer.replaceCurrentItem(with: avItem)
                        } else {
                            avPlayer.replaceCurrentItem(with: nil)
                        }
                    }
                } else if setVideoIndex == "positive" {
                    if translation.y < 0 {
                     setVideoIndex = "negative"
                         if indexOfVideos >= 1 {
                             avItem = AVPlayerItem(url: arrayURLs[indexOfVideos-1] as URL)
                             avPlayer.replaceCurrentItem(with: avItem)
                         } else {
                            avPlayer.replaceCurrentItem(with: nil)
                        }
                    }
                } else if setVideoIndex == "negative" {
                    if translation.y > 0 {
                     setVideoIndex = "positive"
                         if indexOfVideos < (maxIndex-1) {
                             avItem = AVPlayerItem(url: arrayURLs[indexOfVideos+1] as URL)
                             avPlayer.replaceCurrentItem(with: avItem)
                         } else {
                            avPlayer.replaceCurrentItem(with: nil)
                        }
                    }
                }
                avPlayerLayerTemp.frame = CGRect(x: 0, y: 0 + translation.y, width: self.view.frame.width, height: self.view.frame.height)
            }
            
        }
        
        if sender.state == .ended {
            // All fingers are lifted.
            // print(translation.y)
            //print(avPlayerLayer.frame.minY)
            
            switch currentLayer {
            case "main":
                if avPlayerLayer.frame.minY > 450 && translation.y > 0 && indexOfVideos < (maxIndex-1) {
                    avPlayerLayer.frame = CGRect(x: 1110, y: 1100, width: self.view.frame.width, height: self.view.frame.height)
                        indexOfVideos+=1
                        currentLayer = "temp"
                        playVideo(url: arrayURLs[indexOfVideos])
                    
                }else if avPlayerLayer.frame.minY < -450 && translation.y < 0 && indexOfVideos >= 1 {
                        avPlayerLayer.frame = CGRect(x: 0, y: -1100, width: self.view.frame.width, height: self.view.frame.height)
                        indexOfVideos-=1
                        currentLayer = "temp"
                        playVideo(url: arrayURLs[indexOfVideos])
                } else {
                    avPlayerLayer.frame = view.bounds
                }
            default:
                if avPlayerLayerTemp.frame.minY > 450 && translation.y > 0 && indexOfVideos < (maxIndex-1) {

                    avPlayerLayerTemp.frame = CGRect(x: 0, y: 1100, width: self.view.frame.width, height: self.view.frame.height)
                        indexOfVideos+=1
                        currentLayer = "main"
                        playVideo(url: arrayURLs[indexOfVideos])
                    
                }else if avPlayerLayerTemp.frame.minY < -450 && translation.y < 0 && indexOfVideos >= 1 {
                    avPlayerLayerTemp.frame = CGRect(x: 0, y: -1100, width: self.view.frame.width, height: self.view.frame.height)
                        indexOfVideos-=1
                        currentLayer = "main"
                        playVideo(url: arrayURLs[indexOfVideos])
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
        let bundlePath2 = Bundle.main.path(forResource: "kaidClip", ofType: "mp4")
        let tempurl = URL(fileURLWithPath: bundlePath!)
        let tempurl2 = URL(fileURLWithPath: bundlePath2!)
        maxIndex = 10
        arrayURLs.append(tempurl)
        arrayURLs.append(tempurl)
        arrayURLs.append(tempurl)
        arrayURLs.append(tempurl2)
        arrayURLs.append(tempurl2)
        arrayURLs.append(tempurl2)
        arrayURLs.append(tempurl)
        arrayURLs.append(tempurl)
        arrayURLs.append(tempurl)
        arrayURLs.append(tempurl2)
        
        for index in 0...(maxIndex-1) {
            firebaseGroup.enter()
            print(arrayVideos)
            let storageRef = Storage.storage().reference(withPath: arrayVideos[0]) //CHANGE TO index
            storageRef.getData(maxSize: 20 * 1024 * 1024) { (data, error) in
                if let error = error {
                    print("Got an error fetching data: \(error.localizedDescription)")
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
        switch currentLayer {
        case "main":
            if isVideoPlaying {
                isVideoPlaying = false
                avPlayer.pause()
            } else {
                isVideoPlaying = true
                avPlayer.play()
            }
        default:
            if isVideoPlaying {
                isVideoPlaying = false
                avPlayerTemp.pause()
            } else {
                isVideoPlaying = true
                avPlayerTemp.play()
            }
        }
    }
    
    func loopVideo(videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem, queue: .main) { [weak self] _ in
            videoPlayer.seek(to: CMTime.zero)
            videoPlayer.play()
        }
    }
}
