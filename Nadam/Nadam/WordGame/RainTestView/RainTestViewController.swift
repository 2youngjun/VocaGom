//
//  RainTestViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/09/15.
//

import UIKit

class RainTestViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: 변수
    var wordList = [Word]()
    var wordTests = [questionWord]()
    var countQuestion = 0
    
    var wordTestLayer = [CATextLayer]()
    var randomPositionXArray = [Float]()
    
    var isEnded = false {
        didSet {
            if isEnded {
                var buttonTitle = AttributedString.init("결과 확인")
                buttonTitle.font = UIFont.NFont.spellingTestNextButton
                self.nextButton.configuration?.attributedTitle = buttonTitle
                self.nextButton.configuration?.background.backgroundColor = UIColor.NColor.orange
            }
        }
    }
    weak var delegate: SendTestWordResultDelegate?
    let resultViewController: ResultViewController = {
        let storyboard = UIStoryboard(name: "ResultView", bundle: nil)
        guard let resultViewController = storyboard.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController else { return UIViewController() as! ResultViewController }
        return resultViewController
    }()
    
    var timer: Timer?
    var progressing: Float = 0
    var rightCount = 0
    var isAnimationEnded = 0
    
    //MARK: IBOutlet 변수
    @IBOutlet weak var rainBackgroundView: UIView!
    @IBOutlet weak var rainBackgroundViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var countCorrectView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var countCorrectLabel: UILabel!
    
    
    @IBOutlet weak var countStartLabel: UILabel!
    @IBOutlet weak var countOne: UILabel!
    @IBOutlet weak var countTwo: UILabel!
    @IBOutlet weak var countThree: UILabel!
    @IBOutlet var startCountCollection: [UILabel]!
    
    //MARK: IBOutlet Function
    @IBAction func tapNextButton(_ sender: UIButton) {
        var foundName = ""
        if self.isEnded {
            self.delegate?.sendTestWordResult(wordTests: wordTests)
            self.navigationController?.pushViewController(self.resultViewController, animated: true)
        } else {
            self.wordList.forEach { word in
                if word.meaning == self.wordTests[self.isAnimationEnded - 1].word.meaning {
                    foundName = word.name ?? ""
                }
            }
            if foundName == self.textField.text {
                self.rainBackgroundView.subviews.forEach { $0.removeFromSuperview() }
                self.rightCount += 1
                self.countCorrectLabel.text = String(rightCount)
                self.wordTests[self.isAnimationEnded - 1].isCorrect = true
            }
            self.textField.text = ""
        }
    }
    
    //MARK: View LifeCycle Function
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        self.delegate = self.resultViewController
        self.styleFunction()
        self.countWord()
        self.addRandomPositionXArray()
        self.startRainTest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    //MARK: 기능 구현
    private func countWord() {
        var count = 0
        var numbers = [Int]()
        
        self.wordList = CoreDataManager.shared.fetchWord()
        count = wordList.count
        if count > 8 {
            while numbers.count < 8 {
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
        self.countQuestion = wordTests.count
        self.progressing = Float(1) / Float(self.countQuestion)
    }
    
    private func addRandomPositionXArray() {
        while self.randomPositionXArray.count < self.countQuestion {
            let randomX = Float.random(in: 90.0..<Float(self.rainBackgroundView.bounds.width - 90))
            randomPositionXArray.append(randomX)
        }
    }
    
    private func setUILabelView(index: Int) -> UILabel {
        let layerWidth = self.rainBackgroundView.bounds.width / 11
        let label = UILabel()
        label.text = self.wordTests[index].word.meaning
        label.textColor = UIColor.NColor.blue
        label.font = UIFont.NFont.wordButton
        label.numberOfLines = 1
        label.frame = CGRect(x: CGFloat(self.randomPositionXArray[index]), y: layerWidth, width: 100, height: 30)
        label.sizeToFit()
        
        UIView.animate(withDuration: 4, delay: 0) {
            label.transform = CGAffineTransform(translationX: 0, y: self.rainBackgroundView.bounds.height - 60)
        } completion: { finished in
            label.textColor = UIColor.clear
        }
        return label
    }
    
    private func startRainTest() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(startCountTwo), userInfo: nil, repeats: false)
        
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(startCountOne), userInfo: nil, repeats: false)
        
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(startImageOn), userInfo: nil, repeats: false)
        
        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(startImageDown), userInfo: nil, repeats: false)
        
        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(checkFallingIndex), userInfo: nil, repeats: true)
    }
    
    @objc func checkFallingIndex() {
        if self.isAnimationEnded == 0 {
            self.nextButton.isEnabled = true
        }
        if self.isAnimationEnded == self.countQuestion
        {
            self.timer?.invalidate()
            self.timer = nil
            self.isEnded = true
        } else {
            self.rainBackgroundView.addSubview(self.setUILabelView(index: self.isAnimationEnded))
            self.progressView.progress += self.progressing
        }
        self.isAnimationEnded += 1
    }
    
    @objc func startCountTwo() {
        self.countThree.isHidden = true
        self.countTwo.isHidden = false
    }
    
    @objc func startCountOne() {
        self.countTwo.isHidden = true
        self.countOne.isHidden = false
    }
    
    @objc func startImageOn() {
        self.countOne.isHidden = true
        self.countStartLabel.isHidden = false
    }
    
    @objc func startImageDown() {
        self.countStartLabel.isHidden = true
    }
    
    //MARK: Style Function
    private func styleFunction(){
        self.configureTestView()
        self.configureStartCountView()
        self.configureTextField()
        self.configureNextButton()
        self.configureCountView()
        self.configureProgressView()
    }
    
    private func configureStartCountView() {
        self.countStartLabel.isHidden = true
        self.countStartLabel.font = UIFont.NFont.wordListTitleLabel
        self.countStartLabel.textColor = UIColor.NColor.orange
        self.startCountCollection.forEach { count in
            count.font = UIFont.NFont.wordListTitleLabel
            count.textColor = UIColor.NColor.blue
            count.isHidden = true
        }
        self.countThree.isHidden = false
    }
    
    private func configureTestView() {
        self.rainBackgroundView.backgroundColor = UIColor.NColor.background
        self.rainBackgroundView.layer.cornerRadius = 10.0
        self.rainBackgroundView.layer.drawsAsynchronously = true
    }
    
    private func configureTextField() {
        self.textField.delegate = self
        self.textField.backgroundColor = UIColor.NColor.lightBlue
        self.textField.layer.borderWidth = 0.5
        self.textField.layer.cornerRadius = 5.0
        self.textField.layer.borderColor = UIColor.NColor.lightBlue.cgColor
        self.textField.font = UIFont.NFont.textFieldFont
        self.textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        self.textField.leftViewMode = .always
        self.textField.clearButtonMode = .whileEditing
    }
    
    @objc func keyboardUp(notification: NSNotification){
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.rainBackgroundViewHeight.constant = UIScreen.main.bounds.height - keyboardRectangle.height - 234
        }
    }
    
    private func configureNextButton() {
        var buttonTitle = AttributedString.init(self.nextButton.titleLabel?.text ?? "")
        buttonTitle.font = UIFont.NFont.spellingTestNextButton
        self.nextButton.configuration?.attributedTitle = buttonTitle
        self.nextButton.layer.cornerRadius = 5.0
        self.nextButton.isEnabled = false
    }
    
    private func configureCountView() {
        self.countCorrectView.layer.cornerRadius = 10.0
        self.countCorrectLabel.font = UIFont.NFont.automaticMeaningButton
        self.countCorrectLabel.textColor = UIColor.NColor.orange
    }
    
    private func configureProgressView() {
        self.progressView.progress = 0.0
        self.progressView.progressTintColor = UIColor.NColor.blue
        self.progressView.trackTintColor = UIColor.NColor.background
        self.progressView.progressViewStyle = .default
    }
}
