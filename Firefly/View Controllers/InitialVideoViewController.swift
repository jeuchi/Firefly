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
var utilities = Utilities()

var centerPage: Int = 0
var currentIndex: Int = 0
var arrIndex: Int = 0
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
        
        avItem = AVPlayerItem(url: arrayURLs[0] as URL)
        avPlayer.replaceCurrentItem(with: avItem)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        switch centerPage {
            case 1:
                arrIndex = currentIndex-1
            case 2:
                arrIndex = currentIndex+1
            default:
                arrIndex = currentIndex
        }
        
        if arrIndex == 0 {
            avPlayer.play()
            avPlayerNext.pause()
            avPlayerLast.pause()
            utilities.loopVideo(videoPlayer: avPlayer)
            
            avPlayerLast.replaceCurrentItem(with: nil)
            
            avItemNext = AVPlayerItem(url: arrayURLs[arrIndex+1] as URL)
            avPlayerNext.replaceCurrentItem(with: avItemNext)
        }
        
        if arrIndex == 9 {
            avPlayerNext.replaceCurrentItem(with: nil)
            
            avItemLast = AVPlayerItem(url: arrayURLs[arrIndex-1] as URL)
            avPlayerLast.replaceCurrentItem(with: avItemLast)
            
            avPlayer.play()
            avPlayerNext.pause()
            avPlayerLast.pause()
            utilities.loopVideo(videoPlayer: avPlayer)
        }
        
        if arrIndex < 9 && arrIndex > 0 {
           // avItem = AVPlayerItem(url: arrayURLs[currentIndex] as URL)
            //avPlayer.replaceCurrentItem(with: avItem)
            
            avItemNext = AVPlayerItem(url: arrayURLs[arrIndex+1] as URL)
            avPlayerNext.replaceCurrentItem(with: avItemNext)
            
            avItemLast = AVPlayerItem(url: arrayURLs[arrIndex-1] as URL)
            avPlayerLast.replaceCurrentItem(with: avItemLast)
            
            avPlayer.play()
            avPlayerNext.pause()
            avPlayerLast.pause()
            utilities.loopVideo(videoPlayer: avPlayer)
        }
    }

    
    
    


}
