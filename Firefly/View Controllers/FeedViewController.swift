//
//  FeedViewController.swift
//  Firefly
//
//  Created by Jeremy  on 8/28/20.
//  Copyright © 2020 Jeremy . All rights reserved.
//

import UIKit

class FeedViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pages = [UIViewController]()
    let pageControl = UIPageControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.dataSource = self
            self.delegate = self
            let initialPage = 0
            let page1 = InitialVideoViewController()
            let page2 = NextVideoViewController()
            let page3 = LastVideoViewController()
                    
            // add the individual viewControllers to the pageViewController
            self.pages.append(page1)
            self.pages.append(page2)
            self.pages.append(page3)
            setViewControllers([pages[initialPage]], direction: .forward, animated: true, completion: nil)

        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let viewControllerIndex = self.pages.firstIndex(of: viewController) {
            if viewControllerIndex == 0 {
                // wrap to last page in array
                return self.pages.last
            } else {
                // go to previous page in array
                return self.pages[viewControllerIndex - 1]
            }
        }
        return nil
    }
            
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let viewControllerIndex = self.pages.firstIndex(of: viewController) {
            if viewControllerIndex < self.pages.count - 1 {
                // go to next page in array
                return self.pages[viewControllerIndex + 1]
            } else {
                // wrap to first page in array
                return self.pages.first
            }
        }
        return nil
    }
    
    /*func pageViewController(_ pageViewController: UIPageViewController,
                            willTransitionTo pendingViewControllers: [UIViewController]) {
        if currentIndex == 0 && centerPage == 0 {
            print("Error")
            guard let currentViewController = self.viewControllers?.first else { return }
            guard let previousViewController = dataSource?.pageViewController( self, viewControllerBefore: currentViewController ) else { return }
            setViewControllers([previousViewController], direction: .reverse, animated: false, completion: nil)
        }
    }*/

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            
    // set the pageControl.currentPage to the index of the current viewController in pages
       /* if let viewControllers = pageViewController.viewControllers {
            if let viewControllerIndex = self.pages.firstIndex(of: viewControllers[0]) {
                self.pageControl.currentPage = viewControllerIndex
            }
        }*/
        
        if completed {
            if let viewControllers = pageViewController.viewControllers {
                if let viewControllerIndex = self.pages.firstIndex(of: viewControllers[0]) {
                    self.pageControl.currentPage = viewControllerIndex
                    newPage = viewControllerIndex
                }
            }
            
            // If user tries to go up when they are at the beginning of the list, go back to beginning
            // TO DO: Refresh videos from database when completed animation
            if currentIndex == 0 && centerPage == 0 && newPage == 2 {
                DispatchQueue.main.async {
                    self.setViewControllers([self.pages[0]], direction: .forward, animated: true, completion: nil)
                    currentIndex = 0
                    centerPage = 0
                    newPage = nil
                }
            }
            
            /* PAGE INFO
             0 - Initial
             1 - Next
             2 - Last
             */
            
            // INITIAL -> LAST
            
            if centerPage == 0 && newPage == 2 {
                centerPage = 2
                currentIndex -= 1
            } else if centerPage == 0 && newPage == 1 { // INITIAL -> NEXT
                centerPage = 1
                currentIndex += 1
            } else if centerPage == 1 && newPage == 0 { // NEXT -> INITIAL
                centerPage = 0
                currentIndex -= 1
            } else if centerPage == 1 && newPage == 2 { // NEXT -> LAST
                centerPage = 2
                currentIndex += 1
            } else if centerPage == 2 && newPage == 0 { // LAST -> INITIAL
                centerPage = 0
                currentIndex += 1
            } else if centerPage == 2 && newPage == 1 { // LAST -> NEXT
                centerPage = 1
                currentIndex -= 1
            }
            
            // Memory management
            /*
            if centerPage == 0 {
                avPlayerLayerLast?.removeFromSuperlayer()
                avPlayerLayerNext?.removeFromSuperlayer()
            } else if centerPage == 1 {
                avPlayerLayerLast?.removeFromSuperlayer()
                avPlayerLayer?.removeFromSuperlayer()
            } else if centerPage == 2 {
                avPlayerLayerNext?.removeFromSuperlayer()
                avPlayerLayer?.removeFromSuperlayer()
            }*/
            
            newPage = nil
            
            //print("current: \(currentIndex) and page: \(centerPage)")
        }
    
    }
    
    
}
        


