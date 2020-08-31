//
//  HomeFeedViewController.swift
//  Firefly
//
//  Created by Jeremy  on 8/30/20.
//  Copyright © 2020 Jeremy . All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0..<10 {
            let model = VideoModel(caption: "This is a nice group", username: "@jeuchi", audioTrackName: "Ios song", videoFileName: "LoginVideo", videoFileFormat: "mp4")
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
        
        
        
        
        /*let mainVC = MainViewController()
        let searchVC = SearchViewController()
        let profileVC = ProfileViewController()
        tabBarCnt.viewControllers = [mainVC, searchVC, profileVC] */
        
        view.addSubview(collectionView!)

        /*
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: view.frame.size.height-100, width: view.frame.size.width, height: 100)) // Offset by 20 pixels vertically to take the status bar into account

        navigationBar.backgroundColor = .black
        navigationBar.tintColor = .black
        navigationBar.barTintColor = .black

        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        
        let rightButton = UIBarButtonItem(title: "Right", style: UIBarButtonItem.Style.plain, target: self, action: nil)
        
        rightButton.tintColor = .white

        // Create two buttons for the navigation item
        navigationItem.rightBarButtonItem = rightButton
        
        // Create camera button centered
        let cameraButton =  UIButton(type: .custom)
        cameraButton.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        cameraButton.tintColor = .green
        cameraButton.setTitle("", for: .normal)
        cameraButton.addTarget(self, action: #selector(clickOnButton), for: .touchUpInside)
        cameraButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        navigationItem.titleView = cameraButton

        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]

        // Make the navigation bar a subview of the current view controller
        navigationBar.clipsToBounds = true
    
        view.addSubview(navigationBar)*/
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    @objc func clickOnButton() {
        print("lol")
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
