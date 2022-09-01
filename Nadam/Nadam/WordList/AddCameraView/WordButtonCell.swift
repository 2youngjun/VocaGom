//
//  WordButtonCell.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/26.
//

import UIKit

class WordButtonCell: UICollectionViewCell {
    
    @IBOutlet weak var wordLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.contentView.layer.cornerRadius = 20
        self.contentView.backgroundColor = UIColor.NColor.weakBlue
        self.contentView.layer.borderWidth = 0
//        self.contentView.layer.borderColor = UIColor.NColor.blue.cgColor
        
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.contentView.backgroundColor = UIColor.NColor.blue
                self.wordLabel.textColor = UIColor.NColor.white
            } else {
                self.contentView.backgroundColor = UIColor.NColor.weakBlue
                self.wordLabel.textColor = UIColor.NColor.blue
            }
        }
    }
}