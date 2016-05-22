//
//  GuideViewController.swift
//  OPSite
//
//  Created by akixie on 16/5/22.
//  Copyright © 2016年 Aki.Xie. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var startButton: UIButton!
    
    private var scrollView: UIScrollView!
    
    private let numOfPages = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = self.view.bounds
        
        scrollView = UIScrollView(frame: frame)
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.bounces = false
        scrollView.contentOffset = CGPointZero
        // 将 scrollView 的 contentSize 设为屏幕宽度的3倍(根据实际情况改变)
        scrollView.contentSize = CGSize(width: frame.size.width * CGFloat(numOfPages), height: frame.size.height)
        
        scrollView.delegate = self
        
        for index  in 0..<numOfPages {
            // 这里注意图片的命名
            let imageView = UIImageView(image: UIImage(named: "GuideImage\(index + 1)"))
            imageView.frame = CGRect(x: frame.size.width * CGFloat(index), y: 0, width: frame.size.width, height: frame.size.height)
            scrollView.addSubview(imageView)
        }
        
//        self.view.insertSubview(scrollView, atIndex: 0)
        
        // 给开始按钮设置圆角
        startButton.layer.cornerRadius = 15.0
        // 隐藏开始按钮
        startButton.alpha = 1.0
    }
    
    // 隐藏状态栏
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func startButtonAction (button : UIButton) {
        
        let mineVC = self.storyboard?.instantiateViewControllerWithIdentifier("MineViewController") as! MineViewController
        let opListVC = self.storyboard?.instantiateViewControllerWithIdentifier("OPListViewController") as! OPListViewController
        
        
        //self.navigationController?.pushViewController(homeVC, animated: true)
        
        let tabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
        
//        print("TABBAR \(tabBarController)")
        let viewControllersArray = [mineVC, opListVC];
         tabBarController.viewControllers = viewControllersArray
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window!.rootViewController = tabBarController
        
    }
   
}


// MARK: - UIScrollViewDelegate
extension GuideViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        // 随着滑动改变pageControl的状态
        pageControl.currentPage = Int(offset.x / view.bounds.width)
        
        // 因为currentPage是从0开始，所以numOfPages减1
        if pageControl.currentPage == numOfPages - 1 {
            UIView.animateWithDuration(0.5) {
                self.startButton.alpha = 1.0
            }
        } else {
            UIView.animateWithDuration(0.2) {
                self.startButton.alpha = 0.0
            }
        }
    }
}
