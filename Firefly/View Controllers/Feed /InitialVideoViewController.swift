//
//  InitialVideoViewController.swift
//  Firefly
//
//  Created by Jeremy  on 8/28/20.
//  Copyright © 2020 Jeremy . All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

var avPlayer = AVPlayer()
var avItem:AVPlayerItem?
var avPlayerLayer:AVPlayerLayer!

var utilities = Utilities()

var centerPage: Int = 0 // current page 0 -> initial, 1 -> next, 2 -> last
var currentIndex: Int = 0
var arrIndex: Int = 0
var newPage: Int? = nil
var maxIndex = 0

// Data object received from db
class data {
    var likes: Int
    var path: String
    var url: URL
    
    init(likes: Int, path: String, url: URL) {
        self.likes = likes
        self.path = path
        self.url = url
    }
}

var dataCached: [data] = []

var heartButtonInitial = UIButton(type: .custom)
var numberLikesInitial = UILabel()
var playImageInitial = UIButton()

var endOfVideosLabelInitial = UILabel()

class InitialVideoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        avItem = AVPlayerItem(url: dataCached[0].url as URL)
        avPlayer.replaceCurrentItem(with: avItem)
        
        setUpDataButtons(heart: heartButtonInitial, likes: numberLikesInitial, playImage: playImageInitial)
        numberLikesInitial.text = String(dataCached[arrIndex].likes)
        
        endOfVideosLabelInitial.frame = CGRect(x: view.frame.size.width, y: view.frame.size.height, width: 100, height: 100)
        endOfVideosLabelInitial.center.x = view.frame.midX
        endOfVideosLabelInitial.center.y = view.frame.midY
        view.addSubview(endOfVideosLabelInitial)
        endOfVideosLabelInitial.alpha = 0
        endOfVideosLabelInitial.numberOfLines = 0
        endOfVideosLabelInitial.text = "No more videos :("
        
        // Pause and play with tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        
    }
    
   func loadData() {
        // TESTING (NO DATA RETRIEVAL)
        dataCached.removeAll()
        let bundlePath = Bundle.main.path(forResource: "LoginVideo", ofType: "mp4")
        let bundlePath2 = Bundle.main.path(forResource: "kaidClip", ofType: "mp4")
        let tempurl = URL(fileURLWithPath: bundlePath!)
        let tempurl2 = URL(fileURLWithPath: bundlePath2!)

        maxIndex = 10
        let video1 = data(likes: 25, path: bundlePath!, url: tempurl)
        let video2 = data(likes: 55, path: bundlePath2!, url: tempurl2)
        let video3 = data(likes: 155, path: bundlePath2!, url: tempurl2)
        let video4 = data(likes: 0, path: bundlePath!, url: tempurl)
        let video5 = data(likes: 1155, path: bundlePath2!, url: tempurl2)
        let video6 = data(likes: 22255, path: bundlePath2!, url: tempurl2)
        let video7 = data(likes: 5, path: bundlePath!, url: tempurl)
        let video8 = data(likes: 100, path: bundlePath!, url: tempurl)
        let video9 = data(likes: 26, path: bundlePath2!, url: tempurl2)
        let video10 = data(likes: 867, path: bundlePath2!, url: tempurl2)
        dataCached.append(video1)
        dataCached.append(video2)
        dataCached.append(video3)
        dataCached.append(video4)
        dataCached.append(video5)
        dataCached.append(video6)
        dataCached.append(video7)
        dataCached.append(video8)
        dataCached.append(video9)
        dataCached.append(video10)
        // TESTING
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if(avPlayer.timeControlStatus==AVPlayer.TimeControlStatus.paused)
        {
        //Paused mode
            avPlayer.play()
            playImageInitial.alpha = 0
        }
        else if(avPlayer.timeControlStatus==AVPlayer.TimeControlStatus.playing)
        {
         //Play mode
            avPlayer.pause()
            playImageInitial.alpha = 1
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
    
    // TO DO FILL HEART AND UPLOAD 'liked'
    @objc func buttonAction() {
        print("hit heart")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        playImageInitial.alpha = 0

        switch centerPage {
            case 1:
                arrIndex = currentIndex-1
            case 2:
                arrIndex = currentIndex+1
            default:
                arrIndex = currentIndex
        }
        
        
        if arrIndex > 0 && arrIndex != (maxIndex) {
            heartButtonInitial.alpha = 1
            numberLikesInitial.alpha = 1
        }
        
        if arrIndex == 0 {
            avPlayer.play()
            avPlayerNext.pause()
            avPlayerLast.pause()
            utilities.loopVideo(videoPlayer: avPlayer)
            
            avPlayerLast.replaceCurrentItem(with: nil)
            heartButtonLast.alpha = 0
            numberLikesLast.alpha = 0
            
            avItemNext = AVPlayerItem(url: dataCached[arrIndex + 1].url as URL)
            avPlayerNext.replaceCurrentItem(with: avItemNext)
            
            numberLikesNext.text = String(dataCached[arrIndex + 1].likes)
        }
        
        if arrIndex == (maxIndex - 1) {
            avPlayerNext.replaceCurrentItem(with: nil)
            
            avItemLast = AVPlayerItem(url: dataCached[arrIndex - 1].url as URL)
            avPlayerLast.replaceCurrentItem(with: avItemLast)
            numberLikesLast.text = String(dataCached[arrIndex - 1].likes)
            
            avPlayer.play()
            avPlayerNext.pause()
            avPlayerLast.pause()
            utilities.loopVideo(videoPlayer: avPlayer)
        }
        
        if arrIndex < (maxIndex - 1)  && arrIndex > 0 {
            avItemNext = AVPlayerItem(url: dataCached[arrIndex + 1].url as URL)
            avPlayerNext.replaceCurrentItem(with: avItemNext)
            numberLikesNext.text = String(dataCached[arrIndex + 1].likes)
            
            avItemLast = AVPlayerItem(url: dataCached[arrIndex - 1].url as URL)
            avPlayerLast.replaceCurrentItem(with: avItemLast)
            numberLikesLast.text = String(dataCached[arrIndex - 1].likes)
            
            avPlayer.play()
            avPlayerNext.pause()
            avPlayerLast.pause()
            utilities.loopVideo(videoPlayer: avPlayer)
        }
    }

    
    
    


}
