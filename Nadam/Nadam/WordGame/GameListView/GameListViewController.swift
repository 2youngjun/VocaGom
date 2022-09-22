//
//  GameListViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/20.
//

import UIKit

class GameListViewController: UIViewController {
    
    var wordList = [Word]()
    
    //MARK: IBOutlet Variable
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var spellingTestMainImage: UIImageView!
    @IBOutlet weak var spellingTestButtonImage: UIImageView!
    @IBOutlet weak var rainTestMainImage: UIImageView!
    
    @IBOutlet var testButtonViewCollection: [UIView]!
    @IBOutlet var testSubLabelCollection: [UILabel]!
    @IBOutlet var testMainLabelCollection: [UILabel]!
    @IBOutlet var testButtonCollection: [UIButton]!
    
    //MARK: View Lifecycle Function
    override func viewDidLoad() {
        super.viewDidLoad()
        self.styleFunction()
    }
    
    //MARK: IBAction Function
    @IBAction func tapSpellingTestButton(_ sender: UIButton) {
        if wordList.isEmpty {
            self.showAlertNoWord()
        } else {
            let storyboard = UIStoryboard(name: "SpellingTestView", bundle: nil)
            guard let spellingTestViewController = storyboard.instantiateViewController(withIdentifier: "SpellingTestViewController") as? SpellingTestViewController else { return }
            
            self.navigationController?.pushViewController(spellingTestViewController, animated: true)
        }
    }
    
    @IBAction func tapRainTestButton(_ sender: UIButton) {
        if wordList.isEmpty {
            self.showAlertNoWord()
        } else {
            let storyboard = UIStoryboard(name: "RainTestView", bundle: nil)
            guard let rainTestViewController = storyboard.instantiateViewController(withIdentifier: "RainTestViewController") as? RainTestViewController else { return }
            self.navigationController?.pushViewController(rainTestViewController, animated: true)
        }
    }
    
    //MARK: Style Function
    private func styleFunction() {
        self.view.backgroundColor = UIColor.NColor.background
        self.configureTitleLabel()
        self.configureSpellingTestButtonView()
        self.wordList = CoreDataManager.shared.fetchWord()
    }
    
    private func configureTitleLabel() {
        self.titleLabel.font = UIFont.NFont.wordListTitleLabel
        self.titleLabel.textColor = UIColor.NColor.blue
    }
    
    private func configureSpellingTestButtonView() {
        self.testButtonViewCollection.forEach { testButtonView in
            testButtonView.layer.cornerRadius = 10.0
        }
        
        self.testSubLabelCollection.forEach { testSubLabel in
            testSubLabel.font = UIFont.NFont.testSubLabelFont
            testSubLabel.textColor = UIColor.NColor.gray
        }
        
        self.testMainLabelCollection.forEach { testMainLabel in
            testMainLabel.font = UIFont.NFont.testMainLabelFont
            testMainLabel.textColor = UIColor.NColor.black
        }
        
        self.testButtonCollection.forEach { testButton in
            testButton.layer.opacity = 1.0
            testButton.tintColor = UIColor.clear
            testButton.layer.cornerRadius = 10.0
        }
        
        self.spellingTestMainImage.image = UIImage(named: "spellingTest")
        self.rainTestMainImage.image = UIImage(named: "spellingTest")
    }
    
    private func showAlertSpellingTest() {
        let alert = UIAlertController(title: "단어 철자 테스트",
                                      message: "무작위로 최대 10개의 단어로 테스트가 진행됩니다.",
                                      preferredStyle: .alert)
        
        let cancelAlert = UIAlertAction(title: "취소",
                                        style: .cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        
        let startTestAlert = UIAlertAction(title: "시작", style: .default) { _ in
            let storyboard = UIStoryboard(name: "SpellingTestView", bundle: nil)
            guard let spellingTestViewController = storyboard.instantiateViewController(withIdentifier: "SpellingTestViewController") as? SpellingTestViewController else { return }
            
            self.navigationController?.pushViewController(spellingTestViewController, animated: true)
        }
        
        [cancelAlert, startTestAlert].forEach(alert.addAction(_:))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showAlertNoWord() {
        let alert = UIAlertController(title: "테스트할 단어가 없습니다.",
                                      message: "단어를 추가한 후 다시 진행 해주세요.",
                                      preferredStyle: .alert)
        
        let cancelAlert = UIAlertAction(title: "확인",
                                        style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        
        [cancelAlert].forEach(alert.addAction(_:))
        
        self.present(alert, animated: false)
    }
}
