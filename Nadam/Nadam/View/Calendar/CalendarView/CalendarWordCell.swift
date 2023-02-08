//
//  CalendarWordCell.swift
//  Nadam
//
//  Created by 이영준 on 2022/09/22.
//

import UIKit

class CalendarWordCell: UICollectionViewCell {
    @IBOutlet weak var wordName: UILabel!
    @IBOutlet weak var wordMeaning: UILabel!
    
    override func layoutSubviews() {
        self.layer.cornerRadius = 10.0
        self.backgroundColor = UIColor.NColor.white
        self.layer.applySketchShadow(color: UIColor.NColor.black, alpha: 0.05, x: 0, y: 0, blur: 10, spread: 0)
        
        self.wordName.font = UIFont.NFont.wordListWordName
        self.wordName.textColor = UIColor.NColor.blue
        self.wordMeaning.font = UIFont.NFont.wordListWordMeaning
        self.wordMeaning.textColor = UIColor.NColor.black
    }
}
