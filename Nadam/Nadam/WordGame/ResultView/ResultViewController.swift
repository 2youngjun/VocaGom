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
        
        self.styleFunction()
        self.delegate = self.resultWordViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.countResult()
        self.countCorrect.text = String(self.cntCorrect)
        self.countWrong.text = String(self.resultWords.count - self.cntCorrect)
        
        if resultWordViewController.prohibitToast {
            self.showToast(message: "\(self.cntCorrect * 10) 젤리가 적립되었습니다.", cntCorrect: self.cntCorrect)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.cntCorrect = 0
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
        self.resultWordViewController.prohibitToast = true
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

extension ResultViewController {
    private func showToast(message : String, font: UIFont = UIFont.NFont.automaticMeaningButton, cntCorrect: Int) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/4, y: self.view.frame.size.height - 150, width: 200, height: 40))
        toastLabel.backgroundColor = UIColor.NColor.subBlue
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 1.0, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
            
            var point = UserDefaults.standard.object(forKey: "point") as? Int
            guard point != nil else { return }
            
            point! += cntCorrect * 10
            UserDefaults.standard.set(point, forKey: "point")
            
            print(UserDefaults.standard.object(forKey: "point") as? Int)
        })
    }
}
