//
//  WordButtonCell.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/26.
//

import UIKit

class WordButtonCell: UICollectionViewCell {
    @IBOutlet weak var wordButton: UIButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.contentView.layer.borderWidth = 3
    }
}
