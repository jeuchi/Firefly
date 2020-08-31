//
//  HomeFeedViewController.swift
//  Firefly
//
//  Created by Jeremy  on 8/30/20.
//  Copyright © 2020 Jeremy . All rights reserved.
//

import UIKit
import AVKit

struct VideoModel {
    let caption: String
    let username: String
    let audioTrackName: String
    let videoFileName: String
    let videoFileFormat: String
}

class HomeFeedViewController: UIViewController {
    
    private var collectionView: UICollectionView?
    
    private var data = [VideoModel]()
    
    private var currentCell: VideoCollectionViewCell? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0..<10 {
            let model = VideoModel(caption: "This is a nice group", username: "@jeuchi", audioTrackName: "Ios song", videoFileName: "kaidClip", videoFileFormat: "mp4")
            data.append(model)
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width, height: view.frame.size.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        
        collectionView?.isPagingEnabled = true
        collectionView?.dataSource = self
        collectionView?.delegate = self

        
        view.addSubview(collectionView!)
        
        // Pause and play with tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        print("CUR: \(currentCell)")
        if(currentCell?.player!.timeControlStatus==AVPlayer.TimeControlStatus.paused)
        {
        //Paused mode
            currentCell?.player!.play()
        }
        else if(currentCell?.player!.timeControlStatus==AVPlayer.TimeControlStatus.playing)
        {
         //Play mode
            currentCell?.player!.pause()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    @objc func clickOnButton() {
        print("lol")
    }

}

extension HomeFeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
      if let videoCell = cell as? VideoCollectionViewCell {
            videoCell.player?.pause()
      }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let videoCell = cell as? VideoCollectionViewCell {
            currentCell = videoCell
            videoCell.player?.play()
            utilities.loopVideo(videoPlayer: videoCell.player!)
        }
    }

}


extension HomeFeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = data[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.identifier, for: indexPath) as! VideoCollectionViewCell
        cell.configure(with: model)
        cell.delegate = self
        
        return cell
    }
}

extension HomeFeedViewController: VideoCollectionViewCellDelegate {
    func didTapLikeButton(with model: VideoModel) {
        print("like button tapped")
    }
    
    func didTapProfileButton(with model: VideoModel) {
        print("profile button tapped")
    }
    
    func didTapShareButton(with model: VideoModel) {
        print("share button tapped")
    }
    
    func didTapCommentButton(with model: VideoModel) {
        print("comment button tapped")
    }
    
    func didTapCameraButton(with model: VideoModel) {
        performSegue(withIdentifier: "record", sender: self)
    }
}
