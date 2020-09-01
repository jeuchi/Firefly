//
//  TabBarController.swift
//  
//
//  Created by Jeremy  on 8/31/20.
//

import UIKit

// Tab bar UI is in storyboard
class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }

}

extension TabBarController: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //print("selected item")
    }
    

}
