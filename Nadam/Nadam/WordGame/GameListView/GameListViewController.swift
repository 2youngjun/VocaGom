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
        let storyboard = UIStoryboard(name: "SpellingTestView", bundle: nil)
        guard let spellingTestViewController = storyboard.instantiateViewController(withIdentifier: "SpellingTestViewController") as? SpellingTestViewController else { return }
        
        self.navigationController?.pushViewController(spellingTestViewController, animated: true)
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
        
        DispatchQueue.main.async {
            alert.present(alert, animated: true, completion: nil)
        }

    }
}
