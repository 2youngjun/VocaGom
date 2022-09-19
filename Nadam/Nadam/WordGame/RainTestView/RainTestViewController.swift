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
    var fallintIndex = 0
    
    var wordTestLayer = [CATextLayer]()
    var randomPositionXArray = [Float]()
    
    var rightCounut = 0
    
    //MARK: IBOutlet 변수
    @IBOutlet weak var rainBackgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    //MARK: IBOutlet Function
    @IBAction func tapNextButton(_ sender: UIButton) {
        var foundName = ""
        
        self.wordList.forEach { word in
            if word.meaning == self.wordTestLayer[fallintIndex].string as? String {
                foundName = word.name ?? ""
            }
        }
        
        if foundName == self.textField.text {
            self.wordTestLayer[fallintIndex].foregroundColor = UIColor.clear.cgColor
            self.rightCounut += 1
            print(rightCounut)
        }
        
        self.textField.text = ""
    }
    
    //MARK: View LifeCycle Function
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationCheck(_:)),
                                               name: Notification.Name("@@"), object: nil)
        
        self.styleFunction()
        self.countWord()
        
        self.addRandomPositionXArray()
        self.setCALayer()
        self.rainTestStart()
    }
    
    @objc func notificationCheck(_ notification: Notification) {
        guard let index = notification.object as? Int else { return }
//        var foundName = ""
//
//        self.wordList.forEach { word in
//            if word.meaning == self.wordTestLayer[index].string as? String {
//                foundName = word.name ?? ""
//            }
//        }
//        print(index)

        self.fallintIndex = index
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
        let layerWidth = self.rainBackgroundView.bounds.width / 4
        
        
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
    
    private func addLayer(rainDropWord: CATextLayer) {
        self.rainBackgroundView.layer.addSublayer(rainDropWord)
        print("💚")
    }
    
    private func animationLayer(rainDropWord: CATextLayer) {
        let baseViewHeight = self.rainBackgroundView.bounds.height
        // CATextLayer Animation
        let animation = CABasicAnimation(keyPath: "position")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        animation.fromValue = rainDropWord.position
        animation.toValue = CGPoint(x: rainDropWord.position.x, y: baseViewHeight - baseViewHeight / 10)
        animation.duration = 4
        animation.fillMode = .both
        rainDropWord.add(animation, forKey: "basic animation")
        
        rainDropWord.position = CGPoint(x: rainDropWord.position.x, y: baseViewHeight - baseViewHeight / 10)
    }
    
    private func rainTestStart() {
        var time: Double = 0
        self.wordTestLayer.indices.forEach { index in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4.0 * time) {
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    NotificationCenter.default.post(name: Notification.Name("@@"), object: index, userInfo: nil)
                }
                
                self.rainBackgroundView.layer.insertSublayer(self.wordTestLayer[index], at: 1)
                self.animationLayer(rainDropWord: self.wordTestLayer[index])
                print(self.wordTestLayer[index].position)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4.5) {
                    self.wordTestLayer[index].foregroundColor = UIColor.clear.cgColor
//                    self.wordTestLayer[index].removeFromSuperlayer()
                }
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
        self.rainBackgroundView.layer.cornerRadius = 10.0
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
