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

var heartButtonLast = UIButton(type: .custom)
var numberLikesLast = UILabel()

class LastVideoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        avPlayerLayerLast = AVPlayerLayer(player: avPlayerLast)
        avPlayerLayerLast.frame = view.bounds
        avPlayerLayerLast.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.insertSublayer(avPlayerLayerLast, at: 0)
        
        setUpDataButtons(heart: heartButtonLast
            , likes: numberLikesLast)
        
    }
    
    func setUpDataButtons(heart: UIButton, likes: UILabel) {
        let image = UIImage(systemName: "suit.heart")
        heart.frame = CGRect(x: self.view.frame.size.width - 60, y: self.view.frame.size.height/2, width: 50, height: 50)
        heart.setTitle("", for: .normal)
        heart.setBackgroundImage(image, for: .normal)
        heart.tintColor = UIColor.white
        heart.alpha = 1
        heart.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(heart)
        
        likes.frame = CGRect(x: self.view.frame.size.width - 35, y: (self.view.frame.size.height/2) + 40, width: 50, height: 50)
        self.view.addSubview(likes)
    }
    
    @objc func buttonAction() {
        print("hit heart")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        switch centerPage {
            case 0:
                arrIndex = currentIndex-1
            case 1:
                arrIndex = currentIndex+1
            default:
                arrIndex = currentIndex
        }
        
        if arrIndex == (maxIndex - 1)  {
            avPlayer.replaceCurrentItem(with: nil)
            
            avItemNext = AVPlayerItem(url: arrayURLs[arrIndex-1] as URL)
            avPlayerNext.replaceCurrentItem(with: avItemNext)
            
            avPlayerLast.play()
            avPlayerNext.pause()
            avPlayer.pause()
            utilities.loopVideo(videoPlayer: avPlayerLast)
        }
        
        if arrIndex < (maxIndex - 1)  && arrIndex > 0 {
           // avItemLast = AVPlayerItem(url: arrayURLs[currentIndex] as URL)
           // avPlayerLast.replaceCurrentItem(with: avItemLast)
            
            
            avItem = AVPlayerItem(url: arrayURLs[arrIndex+1] as URL)
            avPlayer.replaceCurrentItem(with: avItem)
            
            avItemNext = AVPlayerItem(url: arrayURLs[arrIndex-1] as URL)
            avPlayerNext.replaceCurrentItem(with: avItemNext)
            
            avPlayerLast.play()
            avPlayer.pause()
            avPlayerNext.pause()
            utilities.loopVideo(videoPlayer: avPlayerLast)
            
        }
    }
    
   

}
