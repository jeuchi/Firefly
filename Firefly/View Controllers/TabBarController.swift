//
//  TabBarController.swift
//  
//
//  Created by Jeremy  on 8/31/20.
//

import UIKit

class TabBarController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("loaded")
        view.backgroundColor = .red
        var tabBarCnt = UITabBarController()
        tabBarCnt = UITabBarController()
        tabBarCnt.tabBar.barStyle = .black
        
        view.addSubview(tabBarCnt.view)
    }

}
