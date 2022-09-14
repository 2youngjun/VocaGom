//
//  ResultViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/09/12.
//

import UIKit

protocol SendResultWordDelegate: AnyObject {
    func sendTestWordDelegate(resultWord: [questionWord], color: UIColor, titleText: String)
}

class ResultViewController: UIViewController {
    
    // MARK: 변수
    var resultWords = [questionWord]()
    var cntCorrect: Int = 0
    
    weak var delegate: SendResultWordDelegate?
    let resultWordViewController: ResultWordViewController = {
        let storyBoard = UIStoryboard(name: "ResultWordView", bundle: nil)
        guard let resultWordViewController = storyBoard.instantiateViewController(withIdentifier: "ResultWordViewController") as? ResultWordViewController else { return UIViewController() as! ResultWordViewController }
        return resultWordViewController
    }()
    
    // MARK: IBOutlet
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
    
    // MARK: View Lifecycle Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.countResult()
        self.styleFunction()
        self.delegate = self.resultWordViewController
    }
    
    // MARK: IBAction
    @IBAction func tapCorrectButton(_ sender: UIButton) {
        var tossWords = [questionWord]()
        for word in resultWords {
            if word.isCorrect {
                tossWords.append(word)
            }
        }
        self.delegate?.sendTestWordDelegate(resultWord: tossWords, color: UIColor.NColor.orange, titleText: "맞힌 문제")
        self.navigationController?.pushViewController(self.resultWordViewController, animated: true)
    }
    
    @IBAction func tapWrongButton(_ sender: UIButton) {
        var tossWords = [questionWord]()
        for word in resultWords {
            if word.isCorrect == false {
                tossWords.append(word)
            }
        }
        self.delegate?.sendTestWordDelegate(resultWord: tossWords, color: UIColor.NColor.blue, titleText: "틀린 문제")
        self.navigationController?.pushViewController(self.resultWordViewController, animated: true)
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
            buttonView.layer.applySketchShadow(color: UIColor.NColor.black, alpha: 0.05, x: 0, y: 0, blur: 10, spread: 0)
            buttonView.layer.cornerRadius = 10.0

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
    func sendTestWordResult(wordTests: [questionWord]) {
        self.resultWords = wordTests
    }
}

extension CALayer {
    func applySketchShadow(
        color: UIColor,
        alpha: Float,
        x: CGFloat,
        y: CGFloat,
        blur: CGFloat,
        spread: CGFloat
    ) {
        masksToBounds = false
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / UIScreen.main.scale
        if spread == 0 {
            shadowPath = nil
        } else {
            let rect = bounds.insetBy(dx: -spread, dy: -spread)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}
