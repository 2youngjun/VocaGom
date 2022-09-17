//
//  RainTestViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/09/15.
//

import UIKit

class RainTestViewController: UIViewController {

    //MARK: 변수
    var wordList = [Word]()
    var wordTests = [questionWord]()
    var countQuestion = 0
    
    var wordTestLayer = [CATextLayer]()
    var randomPositionXArray = [Float]()
    
    
    //MARK: IBOutlet 변수
    @IBOutlet weak var rainBackgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    //MARK: IBOutlet Function
    @IBAction func tapNextButton(_ sender: UIButton) {
        
        self.textField.text = ""
    }
    
    //MARK: View LifeCycle Function
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationCheck(_:)),
                                               name: Notification.Name("hello"), object: nil)
        
        self.styleFunction()
        self.countWord()
        
        self.addRandomPositionXArray()
        self.setCALayer()
        self.rainTestStart()
    }
    
    @objc func notificationCheck(_ notification: Notification) {
        guard let string = notification.object as? CATextLayer else { return }
        var foundMeaning = ""
        
        self.wordList.forEach { word in
            if self.textField.text == word.name {
                foundMeaning = word.meaning ?? ""
            }
        }
        print(foundMeaning)
        
        DispatchQueue.main.async {
            if foundMeaning == string.string as! String {
                self.removeLayer(rainDropWord: string)
            }
        }
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
            let randomX = Float.random(in: 50.0..<Float(self.rainBackgroundView.bounds.width - 50))
            randomPositionXArray.append(randomX)
        }
    }
    
    private func setCALayer() {
        let layerWidth = self.rainBackgroundView.bounds.width / 4
        
        self.wordTests.indices.forEach { index in
            let rainDropWord = CATextLayer()
            rainDropWord.bounds = CGRect(x: 0, y: 0, width: layerWidth, height: layerWidth)
            rainDropWord.position = CGPoint(x: CGFloat(randomPositionXArray[index]), y: layerWidth)
            rainDropWord.string = wordTests[index].word.meaning
            rainDropWord.foregroundColor = UIColor.NColor.blue.cgColor
            rainDropWord.isWrapped = true
            rainDropWord.fontSize = 18
            rainDropWord.contentsScale = UIScreen.main.scale
            
            self.wordTestLayer.append(rainDropWord)
        }
    }
    
    private func addLayer(rainDropWord: CATextLayer) {
        self.rainBackgroundView.layer.addSublayer(rainDropWord)
        print("💚")
    }
    
    private func animationLayer(rainDropWord: CATextLayer) {
        let baseViewHeight = self.rainBackgroundView.bounds.height
        // CATextLayer Animation
        let animation = CABasicAnimation(keyPath: "position")
//        animation.beginTime = CACurrentMediaTime() + 3.0
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        animation.fromValue = rainDropWord.position
        animation.toValue = CGPoint(x: rainDropWord.position.x, y: baseViewHeight - baseViewHeight / 10)
        animation.duration = 5
        rainDropWord.add(animation, forKey: "basic animation")
        
        rainDropWord.position = CGPoint(x: rainDropWord.position.x, y: baseViewHeight - baseViewHeight / 10)
    }
    
    private func rainTestStart() {
        var time = 0
        self.wordTestLayer.indices.forEach { index in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0 * Double(time)) {
                self.rainBackgroundView.layer.insertSublayer(self.wordTestLayer[index], at: 1)
                self.animationLayer(rainDropWord: self.wordTestLayer[index])
            }
            time += 1
        }
    }
    
    private func removeLayer(rainDropWord: CATextLayer) {
        rainDropWord.removeFromSuperlayer()
        print("🔥")
        print("\(self.wordTestLayer.firstIndex(of: rainDropWord))")
    }
    
    private func rainTestSequence() {
        
        // wordTests 값은 넣어져있음 (인덱스 최대 10개)
        
        // 단어가 내려오고
        
        // 다음이 눌렸을 때 TextField.text 값 비교하여
        
        // 맞으면 removeSubLayer
        
        // 아니면 그대로 지속
        
        // 최종적으로 countQuestion 같으면 종료
    }
    
    //MARK: Style Function
    private func styleFunction(){
        self.configureTestView()
        self.configureTextField()
        self.configureNextButton()
    }
    
    private func configureTestView() {
        self.rainBackgroundView.backgroundColor = UIColor.NColor.lightBlue
    }
    
    private func configureTextField() {
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
