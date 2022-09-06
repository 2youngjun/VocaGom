//
//  TapWordCell.swift
//  Nadam
//
//  Created by 이영준 on 2022/09/05.
//

import UIKit

class TapWordCell: UICollectionViewCell {

    @IBOutlet weak var wordName: UILabel!
    @IBOutlet weak var wordMeaning: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
