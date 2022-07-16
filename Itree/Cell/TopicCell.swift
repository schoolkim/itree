//
//  TopicCell.swift
//  Itree
//
//  Created by HAKKYU KIM on 2022/05/26.
//

import UIKit

class TopicCell: UICollectionViewCell {
    
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    static let nib = UINib(nibName: "TopicCell", bundle: .main)
    
    func invalidateCell() {
        selectionView.isHidden = !isSelected
    }
    
    override var isSelected: Bool {
        didSet {
            invalidateCell()
        }
    }
    
    func configureCell(itemIdentifier: String) {
        titleLabel.text = itemIdentifier
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        invalidateCell()
        
    }

}
