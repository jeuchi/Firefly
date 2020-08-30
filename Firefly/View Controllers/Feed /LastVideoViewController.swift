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

var playImageLast = UIButton()

class LastVideoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        avPlayerLayerLast = AVPlayerLayer(player: avPlayerLast)
        avPlayerLayerLast.frame = view.bounds
        avPlayerLayerLast.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.insertSublayer(avPlayerLayerLast, at: 0)
        
        setUpDataButtons(heart: heartButtonLast, likes: numberLikesLast, playImage: playImageLast)

        
        heartButtonLast.alpha = 0
        numberLikesLast.alpha = 0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        
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
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if(avPlayerLast.timeControlStatus==AVPlayer.TimeControlStatus.paused)
        {
        //Paused mode
            avPlayerLast.play()
            playImageLast.alpha = 0
        }
        else if(avPlayerLast.timeControlStatus==AVPlayer.TimeControlStatus.playing)
        {
         //Play mode
            avPlayerLast.pause()
            playImageLast.alpha = 1
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        playImageLast.alpha = 0
        switch centerPage {
            case 0:
                arrIndex = currentIndex-1
            case 1:
                arrIndex = currentIndex+1
            default:
                arrIndex = currentIndex
        }
        
        // bring back buttons
        if arrIndex > 0 && arrIndex != (maxIndex) {
            heartButtonLast.alpha = 1
            numberLikesLast.alpha = 1
        }
        
        // if this page is the last
        if arrIndex == (maxIndex - 1)  {
            avPlayer.replaceCurrentItem(with: nil)
            
            avItemNext = AVPlayerItem(url: dataCached[arrIndex - 1].url as URL)
            avPlayerNext.replaceCurrentItem(with: avItemNext)
            numberLikesNext.text = String(dataCached[arrIndex - 1].likes)
            
            avPlayerLast.play()
            avPlayerNext.pause()
            avPlayer.pause()
            utilities.loopVideo(videoPlayer: avPlayerLast)
        }
        
        // update this page
        if arrIndex < (maxIndex - 1)  && arrIndex > 0 {
            
            avItem = AVPlayerItem(url: dataCached[arrIndex + 1].url as URL)
            avPlayer.replaceCurrentItem(with: avItem)
            numberLikesInitial.text = String(dataCached[arrIndex + 1].likes)
            
            avItemNext = AVPlayerItem(url: dataCached[arrIndex - 1].url as URL)
            avPlayerNext.replaceCurrentItem(with: avItemNext)
            numberLikesNext.text = String(dataCached[arrIndex - 1].likes)
            
            avPlayerLast.play()
            avPlayer.pause()
            avPlayerNext.pause()
            utilities.loopVideo(videoPlayer: avPlayerLast)
            
        }
    }
    
   

}
