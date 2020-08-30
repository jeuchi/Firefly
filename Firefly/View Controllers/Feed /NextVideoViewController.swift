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

var playImageNext = UIButton()

class NextVideoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        avPlayerLayerNext = AVPlayerLayer(player: avPlayerNext)
        avPlayerLayerNext.frame = view.bounds
        avPlayerLayerNext.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.insertSublayer(avPlayerLayerNext, at: 0)
        
        setUpDataButtons(heart: heartButtonNext, likes: numberLikesNext, playImage: playImageNext)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if(avPlayerNext.timeControlStatus==AVPlayer.TimeControlStatus.paused)
        {
        //Paused mode
            avPlayerNext.play()
            playImageNext.alpha = 0
        }
        else if(avPlayerNext.timeControlStatus==AVPlayer.TimeControlStatus.playing)
        {
         //Play mode
            avPlayerNext.pause()
            playImageNext.alpha = 1
        }
    }
    
    func setUpDataButtons(heart: UIButton, likes: UILabel, playImage: UIButton) {
        let image = UIImage(systemName: "suit.heart")
        heart.frame = CGRect(x: self.view.frame.size.width - 60, y: self.view.frame.size.height/2, width: 50, height: 50)
        heart.setTitle("", for: .normal)
        heart.setBackgroundImage(image, for: .normal)
        heart.tintColor = UIColor.white
        heart.alpha = 1
        heart.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(heart)
        
        likes.frame = CGRect(x: self.view.frame.size.width - 45, y: (self.view.frame.size.height/2) + 40, width: 50, height: 50)
        self.view.addSubview(likes)
        
        let playimage = UIImage(systemName: "play.fill")
        playImage.frame = CGRect(x: self.view.frame.size.width, y: self.view.frame.size.height, width: 50, height: 50)
        playImage.center.x = self.view.frame.midX
        playImage.center.y = self.view.frame.midY
        playImage.setTitle("", for: .normal)
        playImage.setBackgroundImage(playimage, for: .normal)
        playImage.tintColor = UIColor.green
        playImage.alpha = 0
        self.view.addSubview(playImage)
    }
    
    @objc func buttonAction() {
        print("hit heart")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        playImageNext.alpha = 0
        
        switch centerPage {
            case 0:
                arrIndex = currentIndex+1
            case 2:
                arrIndex = currentIndex-1
            default:
                arrIndex = currentIndex
        }
        
        if arrIndex > 0 && arrIndex != (maxIndex) {
            heartButtonNext.alpha = 1
            numberLikesNext.alpha = 1
        }
        
        if arrIndex == (maxIndex - 1)  {
            avPlayerLast.replaceCurrentItem(with: nil)
            
            avItem = AVPlayerItem(url: dataCached[arrIndex - 1].url as URL)
            avPlayer.replaceCurrentItem(with: avItem)
            numberLikesInitial.text = String(dataCached[arrIndex - 1].likes)
            
            avPlayerNext.play()
            avPlayer.pause()
            avPlayerLast.pause()
            utilities.loopVideo(videoPlayer: avPlayerNext)
        }
        
        
        if arrIndex < (maxIndex - 1)  && arrIndex > 0 {
            avItem = AVPlayerItem(url: dataCached[arrIndex - 1].url as URL)
            avPlayer.replaceCurrentItem(with: avItem)
            numberLikesInitial.text = String(dataCached[arrIndex - 1].likes)
            
            avItemLast = AVPlayerItem(url: dataCached[arrIndex + 1].url as URL)
            avPlayerLast.replaceCurrentItem(with: avItemLast)
            numberLikesLast.text = String(dataCached[arrIndex + 1].likes)
            
            avPlayerNext.play()
            avPlayer.pause()
            avPlayerLast.pause()
            utilities.loopVideo(videoPlayer: avPlayerNext)
            
        }
    }
    
   

}
