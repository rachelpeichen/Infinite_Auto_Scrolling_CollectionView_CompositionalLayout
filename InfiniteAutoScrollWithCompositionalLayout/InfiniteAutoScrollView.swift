//
//  InfiniteAutoScrollView.swift
//  InfiniteAutoScrollWithCompositionalLayout
//
//  Created by Rachel Chen on 2022/5/13.
//

import UIKit

protocol InfiniteAutoScrollViewDelegate: AnyObject {
    func didTapItem(_ collectionView: UICollectionView, selectedItem item:Int)
}

class InfiniteAutoScrollView: UIView {
    
    // MARK: - Properties
    weak var delegate: InfiniteAutoScrollViewDelegate?
    var collectionView: UICollectionView!
    var pageControl: UIPageControl!
    var autoScrollTimer: Timer!
    var currentAutoScrollIndex = 1
   
    var contentArray = [AnyObject]() {
        didSet {
            if contentArray.count > 1 {
                /// Modify it to be like [C, A, B, C, A] to make infinite effect
                contentArray.insert(contentArray.last!, at: 0)
                contentArray.append(contentArray[1])
            }
            
            if collectionView != nil {
                collectionView.reloadData()
                collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .left, animated: false)
                addPageControl()
            }
        }
    }
    
    /// Default is false
    var isAutoScrollEnabled = false {
        didSet {
            if  collectionView != nil && isAutoScrollEnabled == true {
                configAutoScroll()
            }
        }
    }
    
    /// Time interval for auto scroll
    var timeInterval = 1.0 {
        didSet {
            if collectionView != nil && isAutoScrollEnabled == true {
                configAutoScroll()
            }
        }
    }
    
    /// Default is true
    var isPageControlShown = true {
        didSet {
            if pageControl != nil && isPageControlShown == false {
                pageControl.isHidden = true
            }
        }
    }
    
    /// Current page color for UIPageControl
    var currentPageControlColor: UIColor? {
        didSet {
            if collectionView != nil && pageControl != nil  {
                pageControl.currentPageIndicatorTintColor = currentPageControlColor
            }
        }
    }
    
    /// Other page color for UIPageControl
    var pageControlTintColor: UIColor? {
        didSet {
            if collectionView != nil && pageControl != nil {
                pageControl.pageIndicatorTintColor = pageControlTintColor
            }
        }
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        initCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCollectionView()
    }
    
    // MARK: - Custom UI Layout Methods
    func initCollectionView() {
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(InfiniteAutoScrollViewCell.self, forCellWithReuseIdentifier: "InfiniteAutoScrollViewCell")
        // collectionView.backgroundColor = .systemMint // Helper for layout
        collectionView.showsHorizontalScrollIndicator = false
        self.addSubview(collectionView)
        
        if isPageControlShown {
            addPageControl()
        }
    }
    
    func addPageControl() {
        pageControl = UIPageControl(frame: CGRect(x: self.frame.origin.x,
                                                  y: self.collectionView.frame.origin.y + self.frame.height,
                                                  width: self.frame.size.width,
                                                  height: 40.0))
        pageControl.numberOfPages = contentArray.count - 2
        pageControl.currentPageIndicatorTintColor = currentPageControlColor
        pageControl.pageIndicatorTintColor = pageControlTintColor
        pageControl.addTarget(self, action: #selector(changePage(_:)), for: .valueChanged)
        addSubview(pageControl)
    }
    
    @objc func changePage(_ sender: UIPageControl) {
        collectionView.scrollToItem(at: IndexPath(item: sender.currentPage + 1, section: 0), at: .left, animated: true)
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            return self.createHorizontalScrollLayoutSection()
        }
    }
    
    func createHorizontalScrollLayoutSection() -> NSCollectionLayoutSection {
        let itemInset = 10.0
        let sectionMargin = 30.0

        // Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: itemInset, bottom: 0, trailing: itemInset)
        
        // Group
        let pageWidth = collectionView.bounds.width - sectionMargin * 2
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .absolute(CGFloat(pageWidth)), heightDimension: .estimated(self.frame.height))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        
        // Section
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
        
        /// When we use orthogonalScrollingBehavior, scrollViewDidScroll(_:) and scrollViewDidEndDecelerating(_:) won't be fired
        /// visibleItemsInvalidationHandler will be fired when user scroll
        layoutSection.visibleItemsInvalidationHandler = { visibleItems, point, environment in
            if var page = Int(exactly: (point.x + sectionMargin) / pageWidth) {
                let maxIndex = self.contentArray.indices.max()!
                self.currentAutoScrollIndex = page
                
                /// Setup for infinite scroll; we had modify the data array to be [C, A, B, C, A]
                if page == maxIndex {
                    /// When at last item, need to change to array[1], so it can continue to scroll right or left
                    page = 1
                    self.currentAutoScrollIndex = page
                } else if page == 0 {
                    /// When at fist item, need to change to array[3], so it can continue to scroll right or left
                    page = maxIndex - 1
                    self.currentAutoScrollIndex = page
                }
                
                /// Because we add a data in array
                let realPage = page - 1

                /// Update page control and cell only when page changed
                if self.pageControl.currentPage != realPage {
                    self.pageControl.currentPage = realPage
                    self.collectionView.scrollToItem(at: IndexPath(item: page, section: 0), at: .left, animated: false)
                }
                
                if self.isAutoScrollEnabled {
                    self.configAutoScroll()
                }
            }
        }
        
        return layoutSection
    }
}

// MARK: - Auto Scroll Methods
extension InfiniteAutoScrollView {
    
    func configAutoScroll() {
        resetAutoScrollTimer()
        if contentArray.count > 1 {
            setupAutoScrollTimer()
        }
    }
    
    func resetAutoScrollTimer() {
        if autoScrollTimer != nil {
            autoScrollTimer.invalidate()
            autoScrollTimer = nil
        }
    }
    
    func setupAutoScrollTimer() {
        autoScrollTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(autoScrollAction(timer:)), userInfo: nil, repeats: true)
        RunLoop.main.add(autoScrollTimer, forMode: RunLoop.Mode.common)
    }

    @objc func autoScrollAction(timer: Timer) {
        if self.window != nil {
            currentAutoScrollIndex += 1
            if currentAutoScrollIndex >= contentArray.count {
                currentAutoScrollIndex = currentAutoScrollIndex % contentArray.count
            }
            collectionView.scrollToItem(at: IndexPath(item: currentAutoScrollIndex, section: 0), at: .left, animated: true)
        }
    }
}

// MARK: - InfiniteAutoScrollViewCellDelegate
extension InfiniteAutoScrollView: InfiniteAutoScrollViewCellDelegate {
    
    func invalidateTimer() {
        if autoScrollTimer != nil {
            autoScrollTimer.invalidate()
            autoScrollTimer = nil
        }
    }
}

// MARK: - UICollectionViewDataSource
extension InfiniteAutoScrollView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfiniteAutoScrollViewCell", for: indexPath) as? InfiniteAutoScrollViewCell else {
            return UICollectionViewCell()
        }
        
        let content = contentArray[indexPath.item]
        
        if let realContent = content as? UIImage {
            cell.imageView.image = realContent
        }
        
        cell.delegate = self
        
        return cell
    }
}


// MARK: - UICollectionViewDelegate
extension InfiniteAutoScrollView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didTapItem(collectionView, selectedItem: indexPath.item)
    }
}

