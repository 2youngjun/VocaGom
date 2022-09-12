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
        self.view.backgroundColor = UIColor.NColor.background
        self.configureSpellingTestButtonView()
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var spellingTestButtonView: UIView!
    @IBOutlet weak var spellingTestSubLabel: UILabel!
    @IBOutlet weak var spellingTestMainLabel: UILabel!
    @IBOutlet weak var spellingTestMainImage: UIImageView!
    @IBOutlet weak var spellingTestButtonImage: UIImageView!
    @IBOutlet weak var spellingTestButton: UIButton!
    
    private func configureTitleLabel() {
        self.titleLabel.font = UIFont.NFont.wordListTitleLabel
        self.titleLabel.textColor = UIColor.NColor.blue
    }
    
    private func configureSpellingTestButtonView() {
        self.spellingTestButtonView.layer.cornerRadius = 10.0
        self.spellingTestSubLabel.font = UIFont.NFont.testSubLabelFont
        self.spellingTestSubLabel.textColor = UIColor.NColor.gray
        self.spellingTestMainLabel.font = UIFont.NFont.testMainLabelFont
        self.spellingTestMainLabel.textColor = UIColor.NColor.black
        self.spellingTestMainImage.image = UIImage(named: "spellingTestImage")
        self.spellingTestButton.layer.opacity = 1.0
        self.spellingTestButton.tintColor = UIColor.clear
        self.spellingTestButton.layer.cornerRadius = 10.0
    }
    
    @IBAction func tapSpellingTestButton(_ sender: UIButton) {
        
    }
    
}
