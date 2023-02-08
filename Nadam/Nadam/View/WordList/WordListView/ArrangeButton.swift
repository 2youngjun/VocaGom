//
//  ArrangeButton.swift
//  Nadam
//
//  Created by 이영준 on 2022/09/08.
//

import UIKit

class ArrangeButton: UIButton {

    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.configuration?.background.backgroundColor = UIColor.NColor.orange
                self.tintColor = UIColor.NColor.white
                self.titleLabel?.font = UIFont.NFont.arrangeButtonFont
            } else {
                self.configuration?.background.backgroundColor = UIColor.NColor.border
                self.tintColor = UIColor.NColor.gray
                self.titleLabel?.font = UIFont.NFont.arrangeButtonFont
            }
        }
    }
    
    
    
}
