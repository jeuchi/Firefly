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

var heartButtonNext = UIButton(type: .custom)
var numberLikesNext = UILabel()

class NextVideoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        avPlayerLayerNext = AVPlayerLayer(player: avPlayerNext)
        avPlayerLayerNext.frame = view.bounds
        avPlayerLayerNext.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.insertSublayer(avPlayerLayerNext, at: 0)
        
        setUpDataButtons(heart: heartButtonNext, likes: numberLikesNext)
        
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
                arrIndex = currentIndex+1
            case 2:
                arrIndex = currentIndex-1
            default:
                arrIndex = currentIndex
        }
        
        if arrIndex == (maxIndex - 1)  {
            avPlayerLast.replaceCurrentItem(with: nil)
            
            avItem = AVPlayerItem(url: arrayURLs[arrIndex-1] as URL)
            avPlayer.replaceCurrentItem(with: avItem)
            
            avPlayerNext.play()
            avPlayer.pause()
            avPlayerLast.pause()
            utilities.loopVideo(videoPlayer: avPlayerNext)
        }
        
        
        if arrIndex < (maxIndex - 1)  && arrIndex > 0 {
            //avItemNext = AVPlayerItem(url: arrayURLs[currentIndex] as URL)
            //avPlayerNext.replaceCurrentItem(with: avItemNext)
            
            avItem = AVPlayerItem(url: arrayURLs[arrIndex-1] as URL)
            avPlayer.replaceCurrentItem(with: avItem)
            
            avItemLast = AVPlayerItem(url: arrayURLs[arrIndex+1] as URL)
            avPlayerLast.replaceCurrentItem(with: avItemLast)
            
            avPlayerNext.play()
            avPlayer.pause()
            avPlayerLast.pause()
            utilities.loopVideo(videoPlayer: avPlayerNext)
            
        }
    }
    
   

}
