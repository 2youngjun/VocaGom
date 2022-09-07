//
//  AddWordViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/04.
//

import UIKit

protocol AddWordViewDelegate: AnyObject {
    func didSelectSaveWord()
}

class AddWordViewController: UIViewController, SendWordNameDelegate {
    
    var cameraWord = String()
    var configureSaveButtonState: Bool = false {
        didSet {
            if configureSaveButtonState {
                self.saveButton.isEnabled = true
                configureSaveButton(self.saveButton)
            } else {
                self.saveButton.isEnabled = false
                configureSaveButton(self.saveButton)
            }
        }
    }
    
    private func configureSaveButton(_ button: UIButton) {
        if button.isEnabled {
            button.setTitleColor(UIColor.NColor.white, for: .normal)
            button.backgroundColor = UIColor.NColor.blue
        } else {
            button.setTitleColor(UIColor.NColor.blue, for: .normal)
            button.backgroundColor = UIColor.NColor.weakBlue
        }
    }
    
    func sendWord(wordName: String) {
        cameraWord = wordName
    }
    
    override var sheetPresentationController: UISheetPresentationController {
        presentationController as! UISheetPresentationController
    }
    
    var wordList: [Word] = []
    weak var delegate: AddWordViewDelegate?
    
    // MARK: IBOutlet 변수
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var wordName: UILabel!
    @IBOutlet weak var wordMeaning: UILabel!
    @IBOutlet weak var wordSynoym: UILabel!
    @IBOutlet weak var wordExample: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var meaningTextField: UITextField!
    @IBOutlet weak var synoymTextField: UITextField!
    @IBOutlet weak var exampleTextField: UITextField!
    
    
    @IBOutlet weak var duplicateSentense: UILabel!
    @IBOutlet weak var duplicateMargin: NSLayoutConstraint!
    
    @IBOutlet weak var automaticMeaningButton: UIButton!
    
    @IBOutlet var textFieldCollection: [UITextField]!
    
    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        sheetPresentationController.detents = [.medium()]
        wordList = CoreDataManager.shared.fetchWord()
        
        configureLayoutStyle()
        
        configureInputField()
        configureTextFieldStyle()
        
        self.saveButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if cameraWord != String() {
            self.nameTextField.text = cameraWord
        }
        
        self.meaningTextField.text = ""
        self.saveButton.isEnabled = false
        self.configureSaveButton(saveButton)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        CoreDataManager.shared.saveContext()
        cameraWord = String()
    }
    
    
    
    // MARK: IBAction 함수
    @IBAction func startEditingTextField(_ sender: UITextField) {
        sender.layer.borderWidth = 0.5
        sender.layer.cornerRadius = 5.0
        sender.layer.borderColor = UIColor.NColor.blue.cgColor
    }
    
    @IBAction func endEditingTextField(_ sender: UITextField) {
        sender.layer.borderWidth = 0.5
        sender.layer.borderColor = UIColor.NColor.weakBlue.cgColor
        sender.layer.cornerRadius = 5.0
    }
    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapSaveButton(_ sender: UIButton) {
        let name = nameTextField.text ?? ""
        let meaning = meaningTextField.text ?? ""
        let synoym = synoymTextField.text ?? ""
        let example = exampleTextField.text ?? ""
        
        CoreDataManager.shared.addWord(name: name, meaning: meaning, synoym: synoym, example: example, createTime: Date(), star: false, isTapped: false)
        self.delegate?.didSelectSaveWord()

        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func tapOtherSpace(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
        
    }
    
    @IBAction func tapAPIButton(_ sender: Any) {
        self.callPapagoAPI()
    }
    
    private func configureLayoutStyle() {
        
        saveButton.titleLabel?.font = UIFont.NFont.wordListWordMeaning
        saveButton.backgroundColor = UIColor.NColor.weakBlue
        saveButton.isEnabled = false
        saveButton.titleLabel?.textColor = UIColor.NColor.blue
        saveButton.layer.cornerRadius = 5
        
        cancelButton.titleLabel?.font = UIFont.NFont.addWordSection
        cancelButton.sizeToFit()
        
        titleLabel.font = UIFont.NFont.addWordNavigationTitle
        
        wordName.font = UIFont.NFont.addWordSection
        wordMeaning.font = UIFont.NFont.addWordSection
        wordSynoym.font = UIFont.NFont.addWordSection
        wordExample.font = UIFont.NFont.addWordSection
        
        duplicateSentense.font = UIFont.NFont.sameWordButton
        duplicateSentense.textColor = UIColor.NColor.orange
        duplicateSentense.isHidden = true
        
        automaticMeaningButton.titleLabel?.font = UIFont.NFont.automaticMeaningButton
        automaticMeaningButton.titleLabel?.sizeToFit()
        automaticMeaningButton.titleLabel?.textColor = UIColor.NColor.white
        automaticMeaningButton.backgroundColor = UIColor.NColor.orange
        automaticMeaningButton.layer.cornerRadius = 5
        
        attributeNameMeaningTitle()
    }
    
    private func configureTextFieldStyle() {
        for textField in textFieldCollection {
            textField.delegate = self
            textField.backgroundColor = UIColor.NColor.weakBlue
            textField.layer.borderWidth = 0.5
            textField.layer.cornerRadius = 5.0
            textField.layer.borderColor = UIColor.NColor.weakBlue.cgColor
            textField.font = UIFont.NFont.textFieldFont
        }
    }
    
    private func attributeNameMeaningTitle() {
        let attributedNameStr = NSMutableAttributedString(string: wordName.text!)
        let attributedMeaningStr = NSMutableAttributedString(string: wordMeaning.text!)
        attributedNameStr.addAttribute(.foregroundColor, value: UIColor.NColor.orange, range: (wordName.text! as NSString).range(of: "•"))
        attributedMeaningStr.addAttribute(.foregroundColor, value: UIColor.NColor.orange, range: (wordMeaning.text! as NSString).range(of: "•"))
        
        wordName.attributedText = attributedNameStr
        wordMeaning.attributedText = attributedMeaningStr
    }
    
    @objc private func saveButtonState() {
        if nameTextField.text != "" && meaningTextField.text != "" {
            checkSameWord()
        } else {
//            saveButton.isEnabled = false
            configureSaveButtonState = false
        }
    }
    
    private func checkSameWord() {
        let wordString = nameTextField.text ?? ""
        for word in wordList {
            if word.name == wordString {
                self.ifIsSameWord()
//                saveButton.isEnabled = false
                configureSaveButtonState = false
                return
            }
        }
        self.ifIsNotSameWord()
//        saveButton.isEnabled = true
        configureSaveButtonState = true

    }
    
    @objc private func isSameWord() {
        if nameTextField.text != ""{
            checkSameWord()
        }
    }
    
    private func ifIsSameWord() {
        self.duplicateSentense.isHidden = true
//        self.nameTextField.layer.borderColor = UIColor.NColor.orange.cgColor
    }
    
    private func ifIsNotSameWord() {
        self.duplicateSentense.isHidden = true
//        self.nameTextField.layer.borderColor = UIColor.NColor.blue.cgColor
    }
    
    private func configureInputField() {
        self.nameTextField.addTarget(self, action: #selector(saveButtonState), for: .editingChanged)
        self.nameTextField.addTarget(self, action: #selector(isSameWord), for: .editingChanged)
        self.nameTextField.addTarget(self, action: #selector(isSameWord), for: .editingDidEnd)
        
        
        self.meaningTextField.addTarget(self, action: #selector(saveButtonState), for: .editingChanged)
    }
}

extension AddWordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.nameTextField {
            meaningTextField.becomeFirstResponder()
        } else if textField == self.meaningTextField {
            synoymTextField.becomeFirstResponder()
        } else if textField == self.synoymTextField {
            exampleTextField.becomeFirstResponder()
        } else {
            exampleTextField.resignFirstResponder()
        }
        return true
    }
}

extension AddWordViewController {
    
    func callPapagoAPI() {
        guard let wordText = self.nameTextField.text else { return }
        let param = "source=en&target=ko&text=\(wordText)"
        let paramData = param.data(using: .utf8)
        let Naver_URL = URL(string: "https://openapi.naver.com/v1/papago/n2mt")
        
        let clientID = "FWrqCje_fP44uWfeKMLc"
        let clientSecret = "WsPCkYkMRF"
        
        var request = URLRequest(url: Naver_URL!)
        request.httpMethod = "POST"
        request.addValue(clientID, forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
        request.httpBody = paramData
        request.setValue(String(paramData!.count), forHTTPHeaderField: "Content-Length")
                
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: request) { [weak self] data, response, error in
            let successRange = (200..<300)
            
            guard let data = data, error == nil else { return }
            
            let decoder = JSONDecoder()
            
            if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
                guard let wordInformation = try? decoder.decode(WordInformation.self, from: data) else { return }
                
                DispatchQueue.main.async {
                    self?.meaningTextField.text = wordInformation.message.result.translatedWord.replacingOccurrences(of: "[^가-힣 ]", with: "", options: .regularExpression)
                    self?.afterAPINextButtonState()
                }
            } else {
                guard let errorMessage = try? decoder.decode(ErrorMessage.self, from: data) else { return }
                
                DispatchQueue.main.async {
                    self?.showPapagoAPIAlert(errorMessage: errorMessage.errorMessage)
                }
            }
        }.resume()
    }
    
    private func showPapagoAPIAlert(errorMessage: String) {
        let alert = UIAlertController(title: "에러", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func afterAPINextButtonState() {
        if nameTextField.text != "" && meaningTextField.text != "" {
            checkSameWord()
        } else {
            configureSaveButtonState = false
        }
    }
}
