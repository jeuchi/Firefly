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
        
        avPlayerLayerLast = AVPlayerLayer(player: avPlayerLast)
        avPlayerLayerLast.frame = view.bounds
        avPlayerLayerLast.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.insertSublayer(avPlayerLayerLast, at: 0)
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        print("Last \(currentIndex)")
        
        if currentIndex == 0 {
            avPlayerLast.replaceCurrentItem(with: nil)
        }
        
        
        if currentIndex > 0 && currentIndex < 10 {
            switch centerPage {
            case 0:
                avItemLast = AVPlayerItem(url: arrayURLs[currentIndex-1] as URL)
                avPlayerLast = AVPlayer(url: arrayURLs[currentIndex-1])
            case 1:
                avItemLast = AVPlayerItem(url: arrayURLs[currentIndex+1] as URL)
                avPlayerLast.replaceCurrentItem(with: avItemLast)
                //avPlayerLast = AVPlayer(url: arrayURLs[currentIndex+1])
            default:
                avItemLast = AVPlayerItem(url: arrayURLs[currentIndex] as URL)
                avPlayerLast = AVPlayer(url: arrayURLs[currentIndex])
            }
        }
        
        avPlayerLast.play()
    }
    
   

}
