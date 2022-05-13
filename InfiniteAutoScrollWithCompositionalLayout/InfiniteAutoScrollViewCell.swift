//
//  InfiniteAutoScrollViewCell.swift
//  InfiniteAutoScrollWithCompositionalLayout
//
//  Created by Rachel Chen on 2022/5/13.
//

import UIKit

protocol InfiniteAutoScrollViewCellDelegate: AnyObject {
    func invalidateTimer()
}

class InfiniteAutoScrollViewCell: UICollectionViewCell {
    
    weak var delegate: InfiniteAutoScrollViewCellDelegate?
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        initCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initCell() {
        // .backgroundColor = .yellow // Helper for layout
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePan(_ pan: UIPanGestureRecognizer) {
        // Invalidate timer when user pan on cell
        delegate?.invalidateTimer()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension InfiniteAutoScrollViewCell: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
