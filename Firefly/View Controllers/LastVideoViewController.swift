//
//  LastVideoViewController.swift
//  Firefly
//
//  Created by Jeremy  on 8/28/20.
//  Copyright © 2020 Jeremy . All rights reserved.
//

import UIKit
import AVFoundation

var avPlayerLast = AVPlayer()
var avItemLast:AVPlayerItem?
var avPlayerLayerLast:AVPlayerLayer!

class LastVideoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if lastScreen == "next" {
            currentIndex+=1
        } else {
            currentIndex-=1
        }
        print("last and \(currentIndex)")
        lastScreen = "last"

        avPlayerLayerLast = AVPlayerLayer(player: avPlayerLast)
        avPlayerLayerLast.frame = view.bounds
        avPlayerLayerLast.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.insertSublayer(avPlayerLayerLast, at: 0)
        
        if currentIndex >= 0 && currentIndex < 10 {
            avItemLast = AVPlayerItem(url: arrayURLs[currentIndex] as URL)
            avPlayerLast.replaceCurrentItem(with: avItemLast)
        }else {
            avPlayerLast.replaceCurrentItem(with: nil)
        }
        avPlayerLast.play()
    }



}
