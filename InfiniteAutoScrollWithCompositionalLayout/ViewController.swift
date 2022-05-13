//
//  ViewController.swift
//  InfiniteAutoScrollWithCompositionalLayout
//
//  Created by Rachel Chen on 2022/5/13.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var demoView2: InfiniteAutoScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var dataArray = [UIImage?]()
        for i in 0..<5 {
            dataArray.append(UIImage(named: "photo_\(i+1)") ?? nil)
        }
        
        // Create view programmatically
        let screenWidth = UIScreen.main.bounds.width
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let demoView1 = InfiniteAutoScrollView(frame: CGRect(x: 0, y: statusBarHeight, width: screenWidth, height: 200))
        self.view.addSubview(demoView1)

        demoView1.contentArray = dataArray as [AnyObject]
        demoView1.isAutoScrollEnabled = true
        demoView1.timeInterval = 2.0
        demoView1.isPageControlShown = true
        demoView1.currentPageControlColor = .orange
        demoView1.pageControlTintColor = .darkGray
        demoView1.delegate = self
        
        
        // Create view by storyboard
        demoView2.contentArray = dataArray as [AnyObject]
        demoView2.isAutoScrollEnabled = true
        demoView2.timeInterval = 2.0
        demoView2.isPageControlShown = false
//        demoView2.currentPageControlColor = .brown
//        demoView2.pageControlTintColor = .lightGray
        demoView2.delegate = self
    }
}

// MARK: - InfiniteAutoScrollViewDelegate
extension ViewController: InfiniteAutoScrollViewDelegate {
    
    func didTapItem(_ collectionView: UICollectionView, selectedItem item: Int) {
        if collectionView == demoView2.collectionView {
            print("🦄 demoView2 Item \(item) is tapped")
        } else {
            print("🥑 demoView1 Item \(item) is tapped")
        }
    }
}
