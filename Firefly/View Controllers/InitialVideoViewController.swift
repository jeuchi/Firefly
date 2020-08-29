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

var centerPage: Int = 0
var currentIndex: Int = 0
var newPage: Int? = nil

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
        
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        print("Initial \(currentIndex)")
        
        if currentIndex == 0 {
            avItem = AVPlayerItem(url: arrayURLs[currentIndex] as URL)
            avPlayer.replaceCurrentItem(with: avItem)
            
            
            //avPlayer = AVPlayer(url: arrayURLs[currentIndex])
        }
        
        if currentIndex > 0 && currentIndex < 10 {
            switch centerPage {
            case 2:
                print("HERE")
                avItem = AVPlayerItem(url: arrayURLs[currentIndex+1] as URL)
                avPlayer.replaceCurrentItem(with: avItem)
                //avPlayer = AVPlayer(url: arrayURLs[currentIndex+1])
            case 1:
                avItem = AVPlayerItem(url: arrayURLs[currentIndex-1] as URL)
                avPlayer = AVPlayer(url: arrayURLs[currentIndex-1])
            default:
                avItem = AVPlayerItem(url: arrayURLs[currentIndex] as URL)
                avPlayer = AVPlayer(url: arrayURLs[currentIndex])
            }
        }
        
        avPlayer.play()
    }
    
    
    


}
