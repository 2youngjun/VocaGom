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
    @IBOutlet weak var alreadyBoughtImage: UIImageView!
    @IBOutlet weak var wearingNowLabel: UILabel!
    
    override func layoutSubviews() {
        contentView.backgroundColor = UIColor.NColor.backgroundBrown
        self.purchasingLabel.font = UIFont.NFont.automaticMeaningButton
        self.purchasingFoorprint.image = UIImage(named: "footprint")
        self.purchasingImage.layer.cornerRadius = 15
        self.alreadyBoughtImage.layer.cornerRadius = 15
        self.wearingNowLabel.text = "착용중"
        self.wearingNowLabel.textColor = UIColor.NColor.white
        self.wearingNowLabel.font = UIFont.NFont.automaticMeaningButton
    }
}
