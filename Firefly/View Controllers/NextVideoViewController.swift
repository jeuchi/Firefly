//
//  LastVideoViewController.swift
//  Firefly
//
//  Created by Jeremy  on 8/28/20.
//  Copyright © 2020 Jeremy . All rights reserved.
//

import UIKit
import AVFoundation

var avPlayerNext = AVPlayer()
var avItemNext:AVPlayerItem?
var avPlayerLayerNext:AVPlayerLayer!


class NextVideoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if lastScreen == "last" {
            currentIndex-=1
        } else {
            currentIndex+=1
        }
        
        lastScreen = "next"
        print("next and \(currentIndex)")
        
        avPlayerLayerNext = AVPlayerLayer(player: avPlayerNext)
        avPlayerLayerNext.frame = view.bounds
        avPlayerLayerNext.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.insertSublayer(avPlayerLayerNext, at: 0)
        
        if currentIndex < 10 && currentIndex >= 0 {
            avItemNext = AVPlayerItem(url: arrayURLs[currentIndex] as URL)
            avPlayerNext.replaceCurrentItem(with: avItemNext)
        } else {
            avPlayerNext.replaceCurrentItem(with: nil)
        }
        avPlayerNext.play()
    }
    


}
