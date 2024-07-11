import Foundation
import UIKit

class FullCollectionView: UICollectionView {

    override var contentSize: CGSize {
        didSet {
            guard oldValue != contentSize else { return }
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return isScrollEnabled ? super.intrinsicContentSize : collectionViewLayout.collectionViewContentSize
    }
}
