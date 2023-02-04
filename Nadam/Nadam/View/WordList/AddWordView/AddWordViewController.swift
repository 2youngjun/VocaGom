//
//  AddWordViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/04.
//

import UIKit

enum EditMode {
    case new
    case edit(Word)
}

class AddWordViewController: UIViewController, SendWordNameDelegate {
    
    var wordList: [Word] = []
    var cameraWord = String()
    var configureSaveButtonState: Bool = false {
        didSet {
            self.saveButton.isEnabled = configureSaveButtonState ? true : false
            self.configureSaveButton(self.saveButton)
        }
    }
    var editMode: EditMode = .new
    func sendWord(wordName: String) {
        cameraWord = wordName
    }
    
    // MARK: IBOutlet 변수
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var wordName: UILabel!
    @IBOutlet weak var wordMeaning: UILabel!
    @IBOutlet weak var wordSynoym: UILabel!
    @IBOutlet weak var wordExample: UILabel!
    
    @IBOutlet var titleLabelCollection: [UILabel]!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var meaningTextField: UITextField!
    @IBOutlet weak var synoymTextField: UITextField!
    @IBOutlet weak var exampleTextView: UITextView!
    @IBOutlet var textFieldCollection: [UITextField]!
    @IBOutlet weak var exampleTextViewLimitLabel: UILabel!
    
    @IBOutlet weak var duplicateSentense: UILabel!
    
    @IBOutlet weak var automaticMeaningButton: UIButton!
    
    
    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.wordList = CoreDataManager.shared.fetchWord()
        self.layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.wordList = CoreDataManager.shared.fetchWord()
        self.configureEditMode()
        self.configureInputField()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        CoreDataManager.shared.saveContext()
        cameraWord = String()
    }
    
    // MARK: IBAction Function
    @IBAction func startEditingTextField(_ sender: UITextField) {
        sender.layer.borderWidth = 0.5
        sender.layer.cornerRadius = 5.0
        sender.layer.borderColor = UIColor.NColor.borderBlue.cgColor
    }
    
    @IBAction func endEditingTextField(_ sender: UITextField) {
        sender.layer.borderWidth = 0.5
        sender.layer.borderColor = UIColor.NColor.lightBlue.cgColor
        sender.layer.cornerRadius = 5.0
    }
    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapSaveButton(_ sender: UIButton) {
        let name = nameTextField.text ?? ""
        let meaning = meaningTextField.text ?? ""
        let synoym = synoymTextField.text ?? ""
        let example = exampleTextView.text ?? ""
        
        switch self.editMode {
        case .new:
            CoreDataManager.shared.addWord(name: name, meaning: meaning, synoym: synoym, example: example, createTime: Date(), star: false, isTapped: false)
        
        case let .edit(word):
            word.name = name
            word.meaning = meaning
            word.synoym = synoym
            word.example = example
            CoreDataManager.shared.saveContext()
            NotificationCenter.default.post(name: Notification.Name("editWord"), object: nil)
        }
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func tapOtherSpace(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func tapAPIButton(_ sender: Any) {
        if NetworkReachability.isConnectedToNetwork() {
            guard let word = nameTextField.text else { return }
            if word.isEmpty {
                noWordToFetchMeaning()
                return
            }
            DispatchQueue.main.async {
                PapagoNetwork().fetchMeaning(word: word) { meaning in
                    DispatchQueue.main.async {
                        self.meaningTextField.text = meaning?.message.result.translatedWord.replacingOccurrences(of: "[^가-힣 ]", with: "", options: .regularExpression)
                        switch self.editMode {
                        case .new:
                            self.afterAPINextButtonState()
                        default:
                            break
                        }
                    }
                }
            }
        } else {
            self.showAlertNetworkUnreachable()
        }
    }
    
    private func showAlertNetworkUnreachable() {
        let alert = UIAlertController(title: "네트워크 연결을 확인해주세요.",
                                      message: "현재 디바이스가 네트워크에 연결되어 있지 않습니다.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:  "확인", style: .default))
        self.present(alert, animated: true)
    }
    
    private func noWordToFetchMeaning() {
        let alert = UIAlertController(title: "번역할 단어가 없습니다.", message: "단어를 입력한 후 다시 시도해 주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func afterAPINextButtonState() {
        if nameTextField.text != "" && meaningTextField.text != "" {
            checkNameField()
        } else {
            configureSaveButtonState = false
        }
    }
    
    //MARK: Default Style Function
    private func layout() {
        self.configureTitleLabel()
        self.configureDuplicatieLabel()
        self.configurePapagoButton()
        self.configureCancelButton()
        self.configureDefaultSaveButton()
        self.configureTextField()
        self.configureTextView()
    }
    
    private func configureTitleLabel() {
        self.titleLabelCollection.forEach { titleLabel in
            titleLabel.font = UIFont.NFont.addWordSection
        }
        self.attributeNameMeaningTitle()
        self.mainLabel.font = UIFont.NFont.addWordNavigationTitle
    }
    
    private func configureDuplicatieLabel() {
        self.duplicateSentense.font = UIFont.NFont.sameWordButton
        self.duplicateSentense.textColor = UIColor.NColor.subBlue
        self.duplicateSentense.isHidden = true
    }
    
    private func configurePapagoButton() {
        self.automaticMeaningButton.backgroundColor = UIColor.NColor.blue
        self.automaticMeaningButton.layer.cornerRadius = 5
    }
    
    private func configureCancelButton() {
        self.cancelButton.titleLabel?.font = UIFont.NFont.addWordSection
        self.cancelButton.sizeToFit()
    }
    
    private func configureDefaultSaveButton() {
        self.saveButton.titleLabel?.font = UIFont.NFont.wordListWordMeaning
        self.saveButton.backgroundColor = UIColor.NColor.lightBlue
        self.saveButton.titleLabel?.textColor = UIColor.NColor.blue
        self.saveButton.layer.cornerRadius = 5
        self.saveButton.isEnabled = false
    }
    
    private func configureTextField() {
        for textField in textFieldCollection {
            textField.delegate = self
            textField.backgroundColor = UIColor.NColor.lightBlue
            textField.layer.borderWidth = 0.5
            textField.layer.cornerRadius = 5.0
            textField.layer.borderColor = UIColor.NColor.lightBlue.cgColor
            textField.font = UIFont.NFont.textFieldFont
            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
            textField.leftViewMode = .always
        }
    }
    
    private func configureTextView() {
        self.exampleTextView.delegate = self
        self.exampleTextView.layer.borderWidth = 0.5
        self.exampleTextView.layer.cornerRadius = 5.0
        self.exampleTextView.layer.borderColor = UIColor.NColor.lightBlue.cgColor
        self.exampleTextView.backgroundColor = UIColor.NColor.lightBlue
        self.exampleTextView.font = UIFont.NFont.textFieldFont
        self.exampleTextView.textContainerInset = UIEdgeInsets(top: 13, left: 5, bottom: 0, right: 5)
        self.exampleTextView.isScrollEnabled = false
        self.exampleTextViewLimitLabel.font = UIFont.NFont.automaticMeaningButton
        self.exampleTextViewLimitLabel.textColor = UIColor.NColor.borderBlue
    }
    
    private func attributeNameMeaningTitle() {
        let attributedNameStr = NSMutableAttributedString(string: wordName.text!)
        let attributedMeaningStr = NSMutableAttributedString(string: wordMeaning.text!)
        attributedNameStr.addAttribute(.foregroundColor, value: UIColor.NColor.orange, range: (wordName.text! as NSString).range(of: "•"))
        attributedMeaningStr.addAttribute(.foregroundColor, value: UIColor.NColor.orange, range: (wordMeaning.text! as NSString).range(of: "•"))
        
        wordName.attributedText = attributedNameStr
        wordMeaning.attributedText = attributedMeaningStr
    }
    
    //MARK: editMode 에 따른 Style Function
    private func configureEditMode() {
        switch self.editMode {
        case let .edit(word):
            self.nameTextField.text = word.name
            self.meaningTextField.text = word.meaning
            self.synoymTextField.text = word.synoym
            self.exampleTextView.text = word.example
            self.mainLabel.text = "단어 수정하기"
            self.saveButton.isEnabled = true
            self.configureSaveButton(self.saveButton)
            
        case .new:
            if cameraWord != String() {
                self.nameTextField.text = cameraWord
            }
            self.meaningTextField.text = ""
            self.saveButton.isEnabled = false
            self.configureSaveButton(saveButton)
        }
    }
    
    private func configureInputField() {
        self.nameTextField.addTarget(self, action: #selector(checkNameField), for: .editingChanged)
        self.meaningTextField.addTarget(self, action: #selector(checkMeaningField), for: .editingChanged)
    }
    
    private func configureSaveButton(_ button: UIButton) {
        button.setTitleColor(button.isEnabled ? UIColor.NColor.white : UIColor.NColor.blue, for: .normal)
        button.backgroundColor = button.isEnabled ? UIColor.NColor.blue : UIColor.NColor.lightBlue
    }
    
    @objc private func checkNameField() {
        let wordString = nameTextField.text ?? ""
        
        switch self.editMode {
        case let .edit(word):
            if wordString == "" {
                self.duplicateSentense.isHidden = true
                configureSaveButtonState = false
                return
            }
            if wordString == word.name {
                self.duplicateSentense.isHidden = true
                if meaningTextField.text == "" {
                    configureSaveButtonState = false
                    return
                }
                configureSaveButtonState = true
            }
            for temp in wordList {
                if wordString == temp.name && wordString != word.name {
                    self.duplicateSentense.isHidden = false
                    configureSaveButtonState = false
                    return
                }
            }
            self.duplicateSentense.isHidden = true
            if meaningTextField.text == "" {
                configureSaveButtonState = false
                return
            }
            configureSaveButtonState = true
            
        case .new:
            if wordString == "" {
                self.duplicateSentense.isHidden = true
                configureSaveButtonState = false
                return
            }
            for word in wordList {
                if word.name == wordString {
                    self.duplicateSentense.isHidden = false
                    configureSaveButtonState = false
                    return
                }
            }
            self.duplicateSentense.isHidden = true
            if meaningTextField.text == "" {
                configureSaveButtonState = false
                return
            }
            configureSaveButtonState = true
        }
    }
    
    @objc func checkMeaningField() {
        if nameTextField.text == "" || meaningTextField.text == "" || duplicateSentense.isHidden == false {
            configureSaveButtonState = false
        } else {
            configureSaveButtonState = true
        }
    }
}

extension AddWordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.nameTextField {
            meaningTextField.becomeFirstResponder()
        } else if textField == self.meaningTextField {
            synoymTextField.becomeFirstResponder()
        } else if textField == self.synoymTextField {
            exampleTextView.becomeFirstResponder()
        } else {
            exampleTextView.resignFirstResponder()
        }
        return true
    }
}

extension AddWordViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.exampleTextView.layer.borderWidth = 0.5
        self.exampleTextView.layer.cornerRadius = 5.0
        self.exampleTextView.layer.borderColor = UIColor.NColor.borderBlue.cgColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.exampleTextView.layer.borderWidth = 0.5
        self.exampleTextView.layer.cornerRadius = 5.0
        self.exampleTextView.layer.borderColor = UIColor.NColor.lightBlue.cgColor
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentDetailContext = textView.text ?? ""
        guard let stringRange = Range(range, in: currentDetailContext) else { return false }
        
        let changedText = currentDetailContext.replacingCharacters(in: stringRange, with: text)
        exampleTextViewLimitLabel.text = "(\(changedText.count)/90)"
        
        return changedText.count <= 89
    }
}
