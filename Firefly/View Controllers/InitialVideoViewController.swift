//
//  InitialVideoViewController.swift
//  Firefly
//
//  Created by Jeremy  on 8/28/20.
//  Copyright © 2020 Jeremy . All rights reserved.
//

import UIKit
import AVFoundation

var avPlayer = AVPlayer()
var avItem:AVPlayerItem?
var avPlayerLayer:AVPlayerLayer!
var arrayURLs: [URL] = []
var homeView = HomeViewController()

var currentIndex = 0
var lastScreen: String = "initial"

class InitialVideoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundlePath = Bundle.main.path(forResource: "LoginVideo", ofType: "mp4")
        let bundlePath2 = Bundle.main.path(forResource: "kaidClip", ofType: "mp4")
        let tempurl = URL(fileURLWithPath: bundlePath!)
        let tempurl2 = URL(fileURLWithPath: bundlePath2!)

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
        
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if lastScreen == "next" {
            currentIndex-=1
        }else if lastScreen == "last"{
            currentIndex+=1
        }
        print("initial and \(currentIndex)")
        lastScreen = "initial"
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        if currentIndex >= 0 && currentIndex < 10 {
            avItem = AVPlayerItem(url: arrayURLs[currentIndex] as URL)
            avPlayer.replaceCurrentItem(with: avItem)
        } else {
            avPlayer.replaceCurrentItem(with: nil)
        }
        avPlayer.play()
    }
    
    


}
