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

class AddWordViewController: UIViewController {
    
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
    
    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        sheetPresentationController.detents = [.medium()]
        wordList = CoreDataManager.shared.fetchWord()
        
        configureLayoutStyle()
        
        configureInputField()
        self.saveButton.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        CoreDataManager.shared.saveContext()
    }
    
    // MARK: IBAction 함수
    @IBAction func startEditingTextField(_ sender: UITextField) {
        sender.layer.borderWidth = 0.5
        sender.layer.cornerRadius = 5.0
        sender.layer.borderColor = UIColor.NColor.blue.cgColor
    }
    
    @IBAction func endEditingTextField(_ sender: UITextField) {
        sender.layer.borderWidth = 0.5
        sender.layer.borderColor = UIColor.NColor.border.cgColor
        sender.layer.cornerRadius = 5.0
        if sender.text != "" {
            
        }
    }
    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapSaveButton(_ sender: UIButton) {
        let name = nameTextField.text ?? ""
        let meaning = meaningTextField.text ?? ""
        let synoym = synoymTextField.text ?? ""
        let example = exampleTextField.text ?? ""
        
        CoreDataManager.shared.addWord(name: name, meaning: meaning, synoym: synoym, example: example, createTime: Date(), cntWrong: 0)
        self.delegate?.didSelectSaveWord()

        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapOtherSpace(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
        
    }
    
    private func configureLayoutStyle() {
        saveButton.titleLabel?.font = UIFont.NFont.addWordButtonLabel
        saveButton.sizeToFit()
        
        cancelButton.titleLabel?.font = UIFont.NFont.addWordButtonLabel
        cancelButton.sizeToFit()
        
        titleLabel.font = UIFont.NFont.addWordNavigationTitle
        
        wordName.font = UIFont.NFont.addWordButtonLabel
        wordMeaning.font = UIFont.NFont.addWordButtonLabel
        wordSynoym.font = UIFont.NFont.addWordButtonLabel
        wordExample.font = UIFont.NFont.addWordButtonLabel
        
        duplicateSentense.font = UIFont.NFont.addWordButtonLabel
        duplicateSentense.textColor = UIColor.NColor.orange
        duplicateSentense.layer.opacity = 0
        
        attributeNameMeaningTitle()
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
        } else { saveButton.isEnabled = false }
    }
    
    private func checkSameWord() {
        let wordString = nameTextField.text ?? ""
        for word in wordList {
            if word.name == wordString {
                self.ifIsSameWord()
                saveButton.isEnabled = false
                return
            }
        }
        self.ifIsNotSameWord()
        saveButton.isEnabled = true
    }
    
    @objc private func isSameWord() {
        if nameTextField.text != ""{
            checkSameWord()
        }
    }
    
    private func ifIsSameWord() {
        self.duplicateSentense.layer.opacity = 1.0
//        self.nameTextField.layer.borderColor = UIColor.NColor.orange.cgColor
    }
    
    private func ifIsNotSameWord() {
        self.duplicateSentense.layer.opacity = 0
//        self.nameTextField.layer.borderColor = UIColor.NColor.blue.cgColor
    }
    
    private func configureInputField() {
        self.nameTextField.addTarget(self, action: #selector(saveButtonState), for: .editingChanged)
        self.nameTextField.addTarget(self, action: #selector(isSameWord), for: .editingChanged)
        self.nameTextField.addTarget(self, action: #selector(isSameWord), for: .editingDidEnd)
        
        
        self.meaningTextField.addTarget(self, action: #selector(saveButtonState), for: .editingChanged)
    }
}
