//
//  WordListViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/04.
//

import UIKit

class WordListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.font = UIFont.NFont.wordListTitleLabel
        titleLabel.sizeToFit()
        self.view.backgroundColor = UIColor.NColor.background
        self.addWordButton.tintColor = UIColor.NColor.orange
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var addWordButton: UIButton!
    
    @IBAction func tapAddWordButton(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "AddWordView", bundle:nil)
        guard let addWordViewController = storyBoard.instantiateViewController(withIdentifier: "AddWordViewController") as? AddWordViewController else {return}
        
        self.present(addWordViewController, animated:true, completion:nil)
    }
}
