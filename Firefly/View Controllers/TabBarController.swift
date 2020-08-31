//
//  TabBarController.swift
//  
//
//  Created by Jeremy  on 8/31/20.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("loaded")
        
        self.delegate = self
    }

}

extension TabBarController: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("selected item")
    }

}
