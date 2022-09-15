//
//  RainTestViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/09/15.
//

import UIKit

class RainTestViewController: UIViewController {

    //MARK: Variable
    var wordList = [Word]()
    var testWords = [Word]()
    
    //MARK: IBOutlet Variable
    @IBOutlet weak var rainBackgroundView: UIView!
    
    //MARK: IBOutlet Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    //MARK: Style Function
    private func styleFunction(){
        self.configureStyleFunction()
    }
    
    private func configureStyleFunction() {
        self.rainBackgroundView.backgroundColor = UIColor.NColor.lightBlue
    }
    
    //MARK: 기능 구현
    private func countWord() {
        var count = 0
        
        self.wordList = CoreDataManager.shared.fetchWord()
        count = wordList.count
        
        if count > 0 {
            
        }
        
    }
    
}
