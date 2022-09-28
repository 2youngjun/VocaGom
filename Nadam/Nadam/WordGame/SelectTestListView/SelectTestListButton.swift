//
//  SelectTestListButton.swift
//  Nadam
//
//  Created by 이영준 on 2022/09/28.
//

import UIKit

class SelectTestListButton: UIButton {

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.configuration?.background.backgroundColor = UIColor.NColor.blue
                self.tintColor = UIColor.NColor.white
            } else {
                self.configuration?.background.backgroundColor = UIColor.NColor.white
                self.tintColor = UIColor.NColor.blue
            }
        }
    }
}
