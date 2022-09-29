//
//  SpellingTestViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/09/12.
//

import UIKit

protocol SendTestWordResultDelegate: AnyObject {
    func sendTestWordResult(wordTests: [questionWord])
}

class SpellingTestViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: 변수
    var wordList = [Word]()
    var wordTests = [questionWord]()
    var countCorrect = 0
    var totalQuestion = 0
    var currentQuestionIndex = 0 {
        didSet {
            if self.currentQuestionIndex == self.totalQuestion {
                var buttonTitle = AttributedString.init("결과 확인")
                buttonTitle.font = UIFont.NFont.spellingTestNextButton
                self.nextButton.configuration?.attributedTitle = buttonTitle
                self.nextButton.configuration?.background.backgroundColor = UIColor.NColor.orange
            }
        }
    }
    var progressing: Float = 0
    
    weak var delegate: SendTestWordResultDelegate?
    
    let resultViewController: ResultViewController = {
        let storyboard = UIStoryboard(name: "ResultView", bundle: nil)
        guard let resultViewController = storyboard.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController else { return UIViewController() as! ResultViewController }
        return resultViewController
    }()
    
    // MARK: IBOutlet
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var wordCardView: UIView!
    
    @IBOutlet weak var wordCardLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var currentCorrectView: UIView!
    @IBOutlet weak var currentCorrectLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    
    
    // MARK: View Lifecycle Function
    override func viewDidLoad() {
        super.viewDidLoad()

        self.styleFunction()
        self.delegate = self.resultViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.textField.becomeFirstResponder()
        self.setRestartTest()
        self.countWordList()
        self.configureFirstWordCard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.countCorrect = 0
        self.totalQuestion = 0
        self.currentQuestionIndex = 0
        self.progressView.progress = 0
        self.progressing = 0
    }
    
    // MARK: IBAction
    @IBAction func startEditingTextField(_ sender: UITextField) {
        self.textField.layer.borderWidth = 0.5
        self.textField.layer.cornerRadius = 5.0
        self.textField.layer.borderColor = UIColor.NColor.borderBlue.cgColor
    }
    
    @IBAction func endEditingTextField(_ sender: UITextField) {
        self.textField.layer.borderWidth = 0.5
        self.textField.layer.cornerRadius = 5.0
        self.textField.layer.borderColor = UIColor.NColor.lightBlue.cgColor
    }
    
    @IBAction func tapOtherSpace(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func tapNextButton(_ sender: UIButton) {
        self.currentQuestionIndex += 1
        if self.currentQuestionIndex > self.totalQuestion {
            self.delegate?.sendTestWordResult(wordTests: wordTests)
            self.navigationController?.pushViewController(self.resultViewController, animated: true)
        } else {
            if self.checkWordCorrect(textFieldString: self.textField.text ?? "", meaning: self.wordCardLabel.text ?? "") {
                self.countCorrect += 1
                self.currentCorrectLabel.text = String(countCorrect)
                
                self.wordTests[currentQuestionIndex - 1].isCorrect = true
            }
            if self.currentQuestionIndex != self.totalQuestion {
                self.wordCardLabel.text = wordTests[currentQuestionIndex].word.meaning
            }
            
        }
        self.progressView.progress += self.progressing
        self.textField.text = ""
    }
    
    // MARK: 기능 구현
    private func checkWordCorrect(textFieldString: String, meaning: String) -> Bool {
        var isCorrect = false
        var correctName = ""
        for word in wordList {
            if word.meaning == meaning {
                correctName = word.name ?? ""
            }
        }
        isCorrect = correctName == textFieldString ? true : false
        return isCorrect
    }
    
    private func countWordList() {
        var count = 0
        var numbers = [Int]()
//        wordList = CoreDataManager.shared.fetchWord()
        count = wordList.count
        if count > 10 {
            while numbers.count < 10 {
                let number = Int.random(in: 0..<count)
                if !numbers.contains(number) {
                    numbers.append(number)
                }
            }
            numbers.forEach { index in
                wordTests.append(questionWord(word: wordList[index], isCorrect: false))
            }
        } else {
            self.wordList.forEach { word in
                wordTests.append(questionWord(word: word, isCorrect: false))
            }
        }
        self.totalQuestion = self.wordTests.count
        self.progressing = Float(1) / Float(self.totalQuestion)
    }
    
    private func setRestartTest() {
        var buttonTitle = AttributedString.init("다음")
        buttonTitle.font = UIFont.NFont.spellingTestNextButton
        self.nextButton.configuration?.attributedTitle = buttonTitle
        self.nextButton.configuration?.background.backgroundColor = UIColor.NColor.blue
        self.textField.text = ""
        self.wordTests = [questionWord]()
    }
    
    // MARK: Style Function
    private func styleFunction() {
        self.configureWordCardView()
        self.configureTextField()
        self.configureCurrentCorrectView()
        self.configureNextButton()
        self.configureProgressView()
    }
    
    private func configureProgressView() {
        self.progressView.progress = 0.0
        self.progressView.progressTintColor = UIColor.NColor.blue
        self.progressView.trackTintColor = UIColor.NColor.background
        self.progressView.progressViewStyle = .default
    }
    
    private func configureWordCardView() {
        self.wordCardView.backgroundColor = UIColor.NColor.white
        self.wordCardView.layer.applySketchShadow(color: UIColor.NColor.black, alpha: 0.05, x: 0, y: 0, blur: 10, spread: 0)
        self.wordCardView.layer.cornerRadius = 10.0
        self.wordCardView.layer.shadowRadius = 10.0
    }
    
    private func configureFirstWordCard() {
        self.wordCardLabel.font = UIFont.NFont.spellingTestLabel
        self.wordCardLabel.textColor = UIColor.NColor.blue
        self.wordCardLabel.sizeToFit()
        self.wordCardLabel.text = self.wordTests[0].word.meaning
    }
    
    private func configureTextField() {
        self.textField.backgroundColor = UIColor.NColor.lightBlue
        self.textField.layer.borderWidth = 0.5
        self.textField.layer.cornerRadius = 5.0
        self.textField.layer.borderColor = UIColor.NColor.lightBlue.cgColor
        self.textField.font = UIFont.NFont.textFieldFont
        self.textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        self.textField.leftViewMode = .always
        self.textField.clearButtonMode = .whileEditing
    }
    
    private func configureCurrentCorrectView() {
        self.countCorrect = 0
        self.currentCorrectLabel.text = String(countCorrect)
        self.currentCorrectView.layer.cornerRadius = 10.0
        self.currentCorrectLabel.font = UIFont.NFont.automaticMeaningButton
        self.currentCorrectLabel.textColor = UIColor.NColor.orange
    }
    
    private func configureNextButton() {
        var buttonTitle = AttributedString.init(self.nextButton.titleLabel?.text ?? "")
        buttonTitle.font = UIFont.NFont.spellingTestNextButton
        self.nextButton.configuration?.attributedTitle = buttonTitle
        self.nextButton.tintColor = UIColor.NColor.white
        self.nextButton.layer.cornerRadius = 5.0
        self.nextButton.configuration?.background.backgroundColor = UIColor.NColor.blue
    }
}

extension SpellingTestViewController: SendTestListDelegate {
    func sendTestList(testList: [Word]) {
        self.wordList = testList
    }
}
