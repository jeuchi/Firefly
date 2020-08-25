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

    
    var videoPlayer:AVPlayer?
    var videoPlayerLayer:AVPlayerLayer?
    
    @IBOutlet weak var VideoBox: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        playVideo()
        
    }

    func playVideo() {
        let storageRef = Storage.storage().reference(withPath: "videos/Firefly_Temp.mp4")
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
                        self.playVideo(url: url)
                        
                        
                        /*
                        let player = AVPlayer(url: url)
                        let playerViewController = AVPlayerViewController()
                        playerViewController.player = player
                        playerViewController.view.frame = self.VideoBox.bounds
                        self.VideoBox.addSubview(playerViewController.view)
                        self.present(playerViewController, animated: true) {
                            playerViewController.player!.play()
                        }*/
                        
                    }
                }
            }
        
        }
     
    }
    func playVideo(url: URL)  {
        // Create the video player item
        let item = AVPlayerItem(url: url)
        
        // Create the player
        videoPlayer = AVPlayer(playerItem: item)
        
        // Create the layer
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer!)

        videoPlayerLayer?.frame = CGRect(x: -self.view.frame.size.width*0.80, y: 0, width: view.frame.size.width*4, height: self.view.frame.size.height)
        
        view.layer.insertSublayer(self.videoPlayerLayer!, at: 0)
        
        // Add it to the view and play it
        videoPlayer?.playImmediately(atRate: 1)
    }
    
}
