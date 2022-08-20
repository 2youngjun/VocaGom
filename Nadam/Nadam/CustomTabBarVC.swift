//
//  CustomTabBarVC.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/20.
//

import UIKit

class CustomTabBarVC: UITabBar {
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height),cornerRadius: 26)
        UIColor.NColor.blue.setFill()
        self.unselectedItemTintColor = UIColor.NColor.background
        self.tintColor = UIColor.white
        path.fill()
    }
}
