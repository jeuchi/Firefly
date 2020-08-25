//
//  DisplayVideo.swift
//  FireflyDemo
//
//  Created by Jeremy  on 8/25/20.
//  Copyright © 2020 Jeremy . All rights reserved.
//

import Foundation
import Firebase
import AVKit

/*
struct FullScreenVideoUI: UIViewControllerRepresentable {
    let storage = Storage.storage()
    @State var player1: AVPlayer? = nil
    func makeUIViewController(context: Context) -> UIViewController {
    //let controller = AVPlayerLayer()
    let videoReference = storage.reference().child(“video/\(videoID).mp4”)
    let view = UIViewController()
    videoReference.getData(maxSize: 50 * 1024 * 1024) { data, error in
    if let error = error {
    print(“ERROR: \(error)”)
    print(“Did not find video!”)
    } else {
    let tmpFileURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("video").appendingPathExtension(“mp4”)
    do{
    try data!.write(to: tmpFileURL, options: [.atomic])
    }catch{
    print(“error with video!”)
    }
    let rect = CGRect(
    origin: CGPoint(x: 0, y: 0),
    size: UIScreen.main.bounds.size
    )
    self.player1 = AVPlayer(url: tmpFileURL)
    let controller = AVPlayerLayer(player: self.player1)
    controller.player = self.player1
    self.player1!.isMuted = false
    do {
    try AVAudioSession.sharedInstance().setCategory(.playback)
    } catch(let error) {
    print(error.localizedDescription)
    }
    self.player1!.play()
    controller.videoGravity = AVLayerVideoGravity.resizeAspectFill
    controller.frame = rect
    view.view.layer.addSublayer(controller)
    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player1?.currentItem, queue: .main) { _ in
    self.player1!.seek(to: CMTime.zero)
    self.player1!.play()
    }
    }
    }
    return view
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
 
}
*/
