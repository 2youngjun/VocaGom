//
//  NextButtonState.swift
//  Nadam
//
//  Created by 이영준 on 2022/09/24.
//

import UIKit

class NextButtonState: UIButton {
    override var isEnabled: Bool {
        didSet {
            self.tintColor = self.isEnabled ? UIColor.NColor.white : UIColor.NColor.blue
            self.configuration?.background.backgroundColor = self.isEnabled ? UIColor.NColor.blue : UIColor.NColor.lightBlue
        }
    }
}
