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
    var fallingIndex = 0
    
    var wordTestLayer = [CATextLayer]()
    var randomPositionXArray = [Float]()
    
    var rightCounut = 0
    var isEnded = false {
        didSet {
            if isEnded {
                var buttonTitle = AttributedString.init("완료")
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
    
    //MARK: IBOutlet 변수
    @IBOutlet weak var rainBackgroundView: UIView!
    @IBOutlet weak var rainBackgroundViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    //MARK: IBOutlet Function
    @IBAction func tapNextButton(_ sender: UIButton) {
        var foundName = ""
        
        if self.isEnded {
            self.delegate?.sendTestWordResult(wordTests: wordTests)
            self.navigationController?.pushViewController(self.resultViewController, animated: true)
        } else {
            self.wordList.forEach { word in
                if word.meaning == self.wordTestLayer[fallingIndex].string as? String {
                    foundName = word.name ?? ""
                }
            }
            print(fallingIndex)
            if foundName == self.textField.text {
                self.wordTestLayer[fallingIndex].foregroundColor = UIColor.clear.cgColor
                self.rightCounut += 1
                self.wordTests[fallingIndex].isCorrect = true
            }
            self.textField.text = ""
        }
        
    }
    
    //MARK: View LifeCycle Function
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationCheck(_:)),
                                               name: Notification.Name("newIndex"), object: nil)
        self.delegate = self.resultViewController
        
        self.styleFunction()
        self.countWord()
        self.addRandomPositionXArray()
        self.setCALayer()
        self.rainTestStart()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.textField.becomeFirstResponder()
    }
    
    @objc func notificationCheck(_ notification: Notification) {
        guard let index = notification.object as? Int else { return }

        self.fallingIndex = index
        print(fallingIndex)
    }
    
    //MARK: 기능 구현
    private func countWord() {
        var count = 0
        var numbers = [Int]()

        self.wordList = CoreDataManager.shared.fetchWord()
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
        self.countQuestion = wordTests.count
    }
    
    private func addRandomPositionXArray() {
        while self.randomPositionXArray.count < self.countQuestion {
            let randomX = Float.random(in: 75.0..<Float(self.rainBackgroundView.bounds.width - 75))
            randomPositionXArray.append(randomX)
        }
    }
    
    private func setCALayer() {
        let layerWidth = self.rainBackgroundView.bounds.width / 10
        
        self.wordTests.indices.forEach { index in
            let rainDropWord = CATextLayer()
            rainDropWord.bounds = CGRect(x: 0, y: 0, width: self.rainBackgroundView.bounds.width / 3, height: 30)
            rainDropWord.position = CGPoint(x: CGFloat(randomPositionXArray[index]), y: layerWidth)
            
            rainDropWord.string = wordTests[index].word.meaning
            rainDropWord.foregroundColor = UIColor.NColor.blue.cgColor
            rainDropWord.font = UIFont.NFont.arrangeButtonFont
            rainDropWord.isWrapped = true
            rainDropWord.fontSize = 16
            rainDropWord.contentsScale = UIScreen.main.scale
            
            self.wordTestLayer.append(rainDropWord)
        }
    }
    
    private func animationLayer(rainDropWord: CATextLayer) {
        let baseViewHeight = self.rainBackgroundView.bounds.height
        // CATextLayer Animation
        let animation = CABasicAnimation(keyPath: "position")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        animation.fromValue = rainDropWord.position
        animation.toValue = CGPoint(x: rainDropWord.position.x, y: baseViewHeight - baseViewHeight / 12)
        animation.duration = 4
        animation.fillMode = .both
        rainDropWord.add(animation, forKey: "basic animation")
        rainDropWord.position = CGPoint(x: rainDropWord.position.x, y: baseViewHeight - baseViewHeight / 10)
    }
    
    private func rainTestStart() {
        var time: Double = 0
        self.wordTestLayer.indices.forEach { index in
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0 * time) {

                NotificationCenter.default.post(name: Notification.Name("newIndex"), object: index, userInfo: nil)

                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.rainBackgroundView.layer.insertSublayer(self.wordTestLayer[index], at: 0)
                    self.animationLayer(rainDropWord: self.wordTestLayer[index])
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.6) {
                    self.wordTestLayer[index].foregroundColor = UIColor.clear.cgColor
                }
            }
            time += 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4.0 * time) {
            self.isEnded = true
        }
    }
    
    //MARK: Style Function
    private func styleFunction(){
        self.configureTestView()
        self.configureTextField()
        self.configureNextButton()
    }
    
    private func configureTestView() {
        self.rainBackgroundView.backgroundColor = UIColor.NColor.lightBlue
        self.rainBackgroundView.layer.cornerRadius = 10.0
    }
    
    private func configureTextField() {
        self.textField.delegate = self
        self.textField.backgroundColor = UIColor.NColor.lightBlue
        self.textField.layer.borderWidth = 0.5
        self.textField.layer.cornerRadius = 5.0
        self.textField.layer.borderColor = UIColor.NColor.lightBlue.cgColor
        self.textField.font = UIFont.NFont.textFieldFont
        self.textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        self.textField.leftViewMode = .always
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
