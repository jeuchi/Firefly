//
//  HomeFeedViewController.swift
//  Firefly
//
//  Created by Jeremy  on 8/30/20.
//  Copyright © 2020 Jeremy . All rights reserved.
//

import UIKit
import AVKit

// Each video will be a VideoModel
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
    
    private var initialCell: Bool = true //auto play first cell
    
    // When segue to another tab, pause current cell
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let indexPath = collectionView!.indexPathsForVisibleItems.first else {
            return
        }
        let cell = collectionView!.cellForItem(at: indexPath) as! VideoCollectionViewCell
        cell.player!.pause()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TESTING VIDEOS
        for _ in 0..<5 {
            let model = VideoModel(caption: "This is a nice group", username: "@jeuchi", audioTrackName: "Ios song", videoFileName: "kaidClip", videoFileFormat: "mp4")
            data.append(model)
        }
        
        for _ in 0..<5 {
            let model = VideoModel(caption: "My friends", username: "@jeuchi99", audioTrackName: "Beets by dr. d", videoFileName: "LoginVideo", videoFileFormat: "mp4")
            data.append(model)
        }
        // END TESTING
        
        // Set cell layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width, height: view.frame.size.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        
        collectionView?.isPagingEnabled = true // snap cell to view
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.bounces = true // scroll bouncing top and bottom
        view.addSubview(collectionView!)

        // Pause and play with tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let indexPath = collectionView!.indexPathsForVisibleItems.first else {
            return
        }
        
        let cell = collectionView!.cellForItem(at: indexPath) as! VideoCollectionViewCell
        
        if(cell.player!.timeControlStatus==AVPlayer.TimeControlStatus.paused)
        {
            //Play video
            cell.player!.play()
            cell.playButton.alpha = 0
        }
        else if(cell.player!.timeControlStatus==AVPlayer.TimeControlStatus.playing)
        {
            //Pause video
            cell.player!.pause()
            cell.playButton.alpha = 1
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
        
        // This controls where the index starts at (Here is first video cell)
        let indexPath = NSIndexPath(item: 0, section: 0)
        collectionView?.scrollToItem(at: indexPath as IndexPath, at: .centeredVertically, animated: true)
        
    }
}

extension HomeFeedViewController: UICollectionViewDelegate {

    // Once user starts to scroll, pause current video cell
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let iPath = collectionView?.indexPathsForVisibleItems.first {
            //print("DidStartDragging - visible cell is: ", iPath)
            
            if let videoCell = collectionView?.cellForItem(at: iPath) as? VideoCollectionViewCell {
                videoCell.playButton.alpha = 1
                videoCell.player?.pause()
            }
        }
    }
    
    // Once user finishes scrolling, play current visible cell at center of screen
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Get center of screen to get the visible cell
        let point = view.convert(collectionView!.center, to: collectionView)
        
        guard // get index of cell at the center of the screen
            let indexPath = collectionView!.indexPathForItem(at: point),
            indexPath.item < data.count
        else {
            return
        }
        
        //print("DidEndDecelerating - visible cell is: ", indexPath)
        // Auto play video
        if let videoCell = collectionView?.cellForItem(at: indexPath) as? VideoCollectionViewCell {
            videoCell.playButton.alpha = 0
            videoCell.player?.play()
            utilities.loopVideo(videoPlayer: videoCell.player!)
        }
    }
    

}

extension HomeFeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count // Number of videos
    }
    
    // Configure current cell with the video supplied by the model
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = data[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.identifier, for: indexPath) as! VideoCollectionViewCell
        cell.configure(with: model)
        cell.delegate = self
        
        cell.playButton.alpha = 0
         
        // Auto size cell to fullscreen (DOES NOT FIX BUG WHERE USER NEED TO TAP INITIAL CELL)
        cell.sizeToFit()
        
        if initialCell { // Auto play first cell since scrolling controls when cells play
            cell.player!.play()
            initialCell = false
        }
        return cell
    }
}

// Handle delegate functions from VideoCollectionViewCell
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
