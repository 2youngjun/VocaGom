//
//  PurchasingCell.swift
//  Nadam
//
//  Created by 이영준 on 2022/10/05.
//

import UIKit

class PurchasingCell: UICollectionViewCell {
    
    @IBOutlet weak var purchasingImage: UIImageView!
    @IBOutlet weak var purchasingFoorprint: UIImageView!
    @IBOutlet weak var purchasingLabel: UILabel!
    
    override func layoutSubviews() {
        contentView.backgroundColor = UIColor.NColor.backgroundBrown
        self.purchasingLabel.font = UIFont.NFont.automaticMeaningButton
    }
}
