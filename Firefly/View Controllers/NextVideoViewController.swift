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
        avPlayerLayerNext = AVPlayerLayer(player: avPlayerNext)
        avPlayerLayerNext.frame = view.bounds
        avPlayerLayerNext.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.insertSublayer(avPlayerLayerNext, at: 0)
        
    }
        override func viewWillAppear(_ animated: Bool) {
        print("Next \(currentIndex)")
        
        
        if currentIndex == 0 {
            avItemNext = AVPlayerItem(url: arrayURLs[currentIndex+1] as URL)
            avPlayerNext.replaceCurrentItem(with: avItemNext)
        }
        
        
        if currentIndex < 10 && currentIndex > 0 {
            switch centerPage {
            case 0:
                avItemNext = AVPlayerItem(url: arrayURLs[currentIndex+1] as URL)
                avPlayerNext = AVPlayer(url: arrayURLs[currentIndex+1])
            case 2:
                avItemNext = AVPlayerItem(url: arrayURLs[currentIndex-1] as URL)
                avPlayerNext = AVPlayer(url: arrayURLs[currentIndex-1])
            default:
                avItemNext = AVPlayerItem(url: arrayURLs[currentIndex] as URL)
                avPlayerNext = AVPlayer(url: arrayURLs[currentIndex])
            }
        }
        
        avPlayerNext.play()
    }
    
   

}
