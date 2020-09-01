//
//  VideoCollectionViewCell.swift
//  Firefly
//
//  Created by Jeremy  on 8/30/20.
//  Copyright © 2020 Jeremy . All rights reserved.
//

import UIKit
import AVFoundation

protocol VideoCollectionViewCellDelegate: AnyObject {
    func didTapLikeButton(with model: VideoModel)
    
    func didTapProfileButton(with model: VideoModel)
    
    func didTapShareButton(with model: VideoModel)
    
    func didTapCommentButton(with model: VideoModel)
    
}

class VideoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "VideoCollectionViewCell"
    
    // Labels
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        return label
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        return label
    }()
    
    private let audioLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        return label
    }()
    
    // Buttons
    
    private let profileButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "person.circle"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "text.bubble.fill"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "arrowshape.turn.up.right.fill"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    public let playButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .green
        return button
    }()
    
    private let videoContainer = UIView()
    
    
    // Delegate
    
    weak var delegate: VideoCollectionViewCellDelegate?
    
    // Subviews
    var player: AVPlayer?
    var playerView = AVPlayerLayer()
    
    
    private var model: VideoModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .black
        contentView.clipsToBounds = true
        addSubviews()
    }
    
    private func addSubviews() {
        
        playerView.frame = contentView.bounds
        playerView.videoGravity = .resizeAspectFill
        videoContainer.layer.addSublayer(playerView)
        
        
        contentView.addSubview(videoContainer)
        
        contentView.addSubview(usernameLabel)
        contentView.addSubview(captionLabel)
        contentView.addSubview(audioLabel)

        contentView.addSubview(profileButton)
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(shareButton)
        contentView.addSubview(playButton)

        // Add actions
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchDown)
        profileButton.addTarget(self, action: #selector(didTapProfileButton), for: .touchDown)
        commentButton.addTarget(self, action: #selector(didTapCommentButton), for: .touchDown)
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchDown)
    
        videoContainer.clipsToBounds = true
    
        contentView.sendSubviewToBack(videoContainer)
    }
    
    @objc private func didTapLikeButton() {
        guard let model = model else { return }
        delegate?.didTapLikeButton(with: model)
    }
    
    @objc private func didTapCommentButton() {
        guard let model = model else { return }
        delegate?.didTapCommentButton(with: model)
    }
    
    @objc private func didTapShareButton() {
        guard let model = model else { return }
        delegate?.didTapShareButton(with: model)
    }
    
    @objc private func didTapProfileButton() {
        guard let model = model else { return }
        delegate?.didTapProfileButton(with: model)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoContainer.frame = contentView.bounds
        
        let size = contentView.frame.size.width/11
        let width = contentView.frame.size.width
        let height = contentView.frame.size.height - 100
        
        // Buttons
        shareButton.frame = CGRect(x: width-size, y: height-size - 40, width: size, height: size)
        commentButton.frame = CGRect(x: width-size, y: height-(size*2)-60, width: size, height: size)
        likeButton.frame = CGRect(x: width-size, y: height-(size*3)-80, width: size, height: size)
        profileButton.frame = CGRect(x: width-size, y: height-(size*4)-100, width: size, height: size)
        
        playButton.frame = CGRect(x: 100, y: 100, width: 50, height: 50)
        playButton.center = contentView.center
        
        // Labels
        // username, caption, audio
        audioLabel.frame = CGRect(x: 5, y: height-30, width: width-size-10, height: 50)
        captionLabel.frame = CGRect(x: 5, y: height-80, width: width-size-10, height: 50)
        usernameLabel.frame = CGRect(x: 5, y: height-120, width: width-size-10, height: 50)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        captionLabel.text = nil
        audioLabel.text = nil
        usernameLabel.text = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with model: VideoModel) {
        self.model = model
        
        self.player?.replaceCurrentItem(with: nil)
        configureVideo()
        // labels
        captionLabel.text = model.caption
        audioLabel.text = model.audioTrackName
        usernameLabel.text = model.username
    }
    
    private func configureVideo() {
        guard let model = model else {
            return
        }
        guard let path = Bundle.main.path(forResource: model.videoFileName, ofType: model.videoFileFormat) else {
            return
        }
        player = AVPlayer(url: URL(fileURLWithPath: path))
        playerView.player = player
    }
}

