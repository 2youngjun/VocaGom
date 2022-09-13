//
//  ResultViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/09/12.
//

import UIKit

class ResultViewController: UIViewController {

    // MARK: 변수
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var totalCorrectionView: UIView!
    @IBOutlet weak var totalCorrectionLabel: UILabel!
    @IBOutlet weak var totalWrongView: UIView!
    @IBOutlet weak var totalWrongLabel: UILabel!
    
    @IBOutlet var buttonViewCollection: [UIView]!
    @IBOutlet var buttonInnerViewCollection: [UIView]!
    @IBOutlet var buttonLabelCollection: [UILabel]!
    @IBOutlet var buttonCollection: [UIButton]!
    
    @IBOutlet weak var completeButton: UIButton!
    
    @IBOutlet weak var countCorrect: UILabel!
    @IBOutlet weak var countWrong: UILabel!
    
    var resultWords = [isCorrectWord]()
    var cntCorrect: Int = 0
    
    // MARK: View Lifecycle Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.countResult()
        self.styleFunction()
    }
    
    @IBAction func tapCorrectButton(_ sender: UIButton) {
        
    }
    
    @IBAction func tapWrongButton(_ sender: UIButton) {
        
    }
    
    @IBAction func tapCompleteButton(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: Style Function
    private func styleFunction() {
        self.configureProgressView()
        self.configureUpperView()
        self.configureButtonView()
        self.configureCompleteButton()
    }
    
    private func configureProgressView() {
        self.progressView.progress = 1.0
        self.progressView.progressTintColor = UIColor.NColor.orange
    }
    
    private func configureUpperView() {
        self.resultLabel.font = UIFont.NFont.resultLabel
        self.totalCorrectionView.layer.cornerRadius = 10.0
        self.totalCorrectionLabel.font = UIFont.NFont.automaticMeaningButton
        self.totalCorrectionLabel.textColor = UIColor.NColor.orange
        self.totalWrongView.layer.cornerRadius = 10.0
        self.totalWrongLabel.font = UIFont.NFont.automaticMeaningButton
        self.totalWrongLabel.textColor = UIColor.NColor.blue
        
        self.countCorrect.text = String(self.cntCorrect)
        self.countWrong.text = String(self.resultWords.count - self.cntCorrect)
    }
    
    private func configureButtonView() {
        for buttonInnerView in buttonInnerViewCollection {
            buttonInnerView.layer.cornerRadius = 10.0
        }
        for buttonView in buttonViewCollection {
            buttonView.layer.shadowColor = UIColor.NColor.border.cgColor
            buttonView.layer.shadowOpacity = 0.6
            buttonView.layer.shadowOffset = CGSize(width: 5, height: 5)
        }
        for buttonLabel in buttonLabelCollection {
            buttonLabel.font = UIFont.NFont.resultLabel
        }
        for button in buttonCollection {
            button.configuration?.background.backgroundColor = UIColor.clear
            button.layer.opacity = 1.0
        }
    }
    
    private func configureCompleteButton() {
        var buttonTitle = AttributedString.init("완료")
        buttonTitle.font = UIFont.NFont.spellingTestNextButton
        self.completeButton.configuration?.attributedTitle = buttonTitle
        self.completeButton.configuration?.background.backgroundColor = UIColor.NColor.orange
        self.completeButton.layer.cornerRadius = 10.0
        self.completeButton.tintColor = UIColor.NColor.white
    }
    
    private func countResult() {
        for resultWord in resultWords {
            self.cntCorrect = resultWord.isCorrect ? self.cntCorrect + 1 : self.cntCorrect
        }
    }
}

extension ResultViewController: SendTestWordResultDelegate {
    func sendTestWordResult(wordTests: [isCorrectWord]) {
        self.resultWords = wordTests
    }
}
