//
//  FeedHelperViewController.swift
//  Firefly
//
//  Created by Jeremy  on 8/29/20.
//  Copyright © 2020 Jeremy . All rights reserved.
//

import UIKit

// Container view for navigation bar on the bottom to appear on all pages
class FeedHelperViewController: UIViewController {
    
    @IBOutlet weak var cameraButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
 
    }
    
    
    @IBAction func tappedCamera(_ sender: Any) {
        switch centerPage {
        case 0:
            avPlayer.pause()
            avPlayerNext.pause()
            avPlayerLast.pause()
            performSegue(withIdentifier: "record", sender: FeedViewController.self)
        case 1:
            avPlayerNext.pause()
            avPlayer.pause()
            avPlayerLast.pause()
            performSegue(withIdentifier: "record", sender: FeedViewController.self)
        case 2:
            avPlayerLast.pause()
            avPlayerNext.pause()
            avPlayer.pause()
            performSegue(withIdentifier: "record", sender: FeedViewController.self)
        default:
            return
        }
    }
    

}
