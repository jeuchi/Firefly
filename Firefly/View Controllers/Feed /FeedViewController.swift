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
    
    var refreshVideos = InitialVideoViewController()
    
    
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


    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let group = DispatchGroup()
        
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
                    self.refreshVideos.loadData()
                    currentIndex = 0
                    centerPage = 0
                    newPage = nil
                   // pageViewController.view.isUserInteractionEnabled = true
                }
            }
        
            
            /* PAGE INFO
             0 - Initial
             1 - Next
             2 - Last
             */
            
            if centerPage == 0 && newPage == 2 { // INITIAL -> LAST
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
            
            if currentIndex == (maxIndex-2) {
                endOfVideosLabelInitial.alpha = 0
                endOfVideosLabelLast.alpha = 0
                endOfVideosLabelNext.alpha = 0
            }
            
            // Disable button for the next screen at the end
            if currentIndex == (maxIndex-1) {
                if centerPage == 2 { // last
                    heartButtonInitial.alpha = 0
                    numberLikesInitial.alpha = 0
                    endOfVideosLabelInitial.alpha = 1
                } else if centerPage == 1 { // next
                    heartButtonLast.alpha = 0
                    numberLikesLast.alpha = 0
                    endOfVideosLabelLast.alpha = 1
                } else if centerPage == 0 { // initial
                    heartButtonNext.alpha = 0
                    numberLikesNext.alpha = 0
                    endOfVideosLabelNext.alpha = 1
                }
            }
            
            // If user tries to go down outside array of loaded videos, load more
            // TO DO: Refresh videos from database when completed animation
            if currentIndex >= maxIndex {
                pageViewController.view.isUserInteractionEnabled = false
                currentIndex = (maxIndex - 1)
                
                if centerPage == 2 { // last
                    centerPage = 1
                } else if centerPage == 1 { // next
                    centerPage = 0
                } else if centerPage == 0 { // initial
                    centerPage = 2
                }
                
                DispatchQueue.main.async {
                    self.setViewControllers([self.pages[centerPage]], direction: .reverse, animated: true, completion: nil)
                    pageViewController.view.isUserInteractionEnabled = true
                }
            }
            
            newPage = nil
            print("current: \(currentIndex) and page: \(centerPage)")
        }
    
    }
    
    
}
        


