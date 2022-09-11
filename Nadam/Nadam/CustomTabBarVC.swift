//
//  CustomTabBarVC.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/20.
//

import UIKit

class CustomTabBarVC: UITabBar {
    override func draw(_ rect: CGRect) {
        UIColor.NColor.background.setFill()
        self.unselectedItemTintColor = UIColor.NColor.blue
        self.tintColor = UIColor.NColor.blue
        self.shadowImage = UIImage()
    }
    
    static func clearShadow() {
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().backgroundColor = UIColor.NColor.weakBlue
    }
}
