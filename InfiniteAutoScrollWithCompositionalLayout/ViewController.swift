//
//  ViewController.swift
//  InfiniteAutoScrollWithCompositionalLayout
//
//  Created by Rachel Chen on 2022/5/13.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var demoView: InfiniteAutoScrollView!
    @IBOutlet weak var demoViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("DemoView Width \(demoView.frame.width) in viewDidLoad")
        print("DemoView Height \(demoViewHeight.constant) in viewDidLoad")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        var dataArray = [UIImage?]()
        for i in 0..<5 {
            dataArray.append(UIImage(named: "photo_\(i+1)") ?? nil)
        }

        // Create view by storyboard
        demoView.contentArray = dataArray as [AnyObject]
        demoView.isAutoScrollEnabled = true
        demoView.timeInterval = 2.0
        demoView.isPageControlShown = true
        demoView.currentPageControlColor = .orange
        demoView.pageControlTintColor = .darkGray
        demoView.delegate = self
        demoViewHeight.constant = CGFloat(getPreferBannerViewHeightBasedOnDevice())
        
        print("DemoView Width \(demoView.frame.width) in viewDidAppear")
        print("DemoView Height \(demoViewHeight.constant) in viewDidAppear")
    }
    
    func getPreferBannerViewHeightBasedOnDevice() -> Int {
        let modelName = UIDevice.modelName
        switch modelName {
        case "iPhone 5", "iPhone 5c", "iPhone 5s", "iPhone SE":
            return 158
            
        case "iPhone 6", "iPhone 6s", "iPhone 7", "iPhone 8", "iPhone SE (2nd generation)", "iPhone SE (3rd generation)":
            return 188

        case "iPhone 12", "Simulator iPhone 12",
            "iPhone 12 Pro", "Simulator iPhone 12 Pro",
            "iPhone 13", "Simulator iPhone 13",
            "iPhone 13 Pro", "Simulator iPhone 13 Pro":
            return 197
            
        case "iPhone 12 Pro Max", "Simulator iPhone 12 Pro Max",
            "iPhone 13 Pro Max", "Simulator iPhone 13 Pro Max":
            return 218
        
        default:
            return 210
        }
    }
}

// MARK: - InfiniteAutoScrollViewDelegate
extension ViewController: InfiniteAutoScrollViewDelegate {
    
    func didTapItem(_ collectionView: UICollectionView, selectedItem item: Int) {
        if collectionView == demoView.collectionView {
            print("🥑 🥑 DemoView Item \(item) is tapped")
        } else {
            print("🥑 Other \(item) is tapped")
        }
    }
}
