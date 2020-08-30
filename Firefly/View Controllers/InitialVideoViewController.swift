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
var maxIndex = 0



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

class InitialVideoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TESTING (NO DATA RETRIEVAL)
        let bundlePath = Bundle.main.path(forResource: "LoginVideo", ofType: "mp4")
        let bundlePath2 = Bundle.main.path(forResource: "kaidClip", ofType: "mp4")
        let tempurl = URL(fileURLWithPath: bundlePath!)
        let tempurl2 = URL(fileURLWithPath: bundlePath2!)

        
        maxIndex = 10
        
        let video1 = data(likes: 25, path: bundlePath!, url: tempurl)
        let video2 = data(likes: 55, path: bundlePath2!, url: tempurl2)
        dataCached.append(video1)
        dataCached.append(video2)
    
        
        arrayURLs.append(dataCached[0].url)
        arrayURLs.append(dataCached[0].url)
        arrayURLs.append(dataCached[0].url)
        arrayURLs.append(dataCached[1].url)
        arrayURLs.append(dataCached[1].url)
        arrayURLs.append(dataCached[1].url)
        arrayURLs.append(dataCached[0].url)
        arrayURLs.append(dataCached[0].url)
        arrayURLs.append(dataCached[0].url)
        arrayURLs.append(dataCached[1].url)
        
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds

        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        avItem = AVPlayerItem(url: arrayURLs[0] as URL)
        avPlayer.replaceCurrentItem(with: avItem)
        
        
        setUpDataButtons(heart: heartButtonInitial, likes: numberLikesInitial)
        
        numberLikesInitial.text = String(dataCached[arrIndex].likes)
        
        
        //numberLikesInitial.text = String(dataCached[arrIndex].likes)
        
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
        
        if arrIndex == (maxIndex - 1) {
            avPlayerNext.replaceCurrentItem(with: nil)
            
            avItemLast = AVPlayerItem(url: arrayURLs[arrIndex-1] as URL)
            avPlayerLast.replaceCurrentItem(with: avItemLast)
            
            avPlayer.play()
            avPlayerNext.pause()
            avPlayerLast.pause()
            utilities.loopVideo(videoPlayer: avPlayer)
        }
        
        if arrIndex < (maxIndex - 1)  && arrIndex > 0 {
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
