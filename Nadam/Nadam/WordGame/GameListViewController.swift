//
//  GameListViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/20.
//

import UIKit

class GameListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureTitleLabel()
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func configureTitleLabel() {
        self.titleLabel.font = UIFont.NFont.wordListTitleLabel
        self.titleLabel.textColor = UIColor.NColor.blue
    }
    
    
}
