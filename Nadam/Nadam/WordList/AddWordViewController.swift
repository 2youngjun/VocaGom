//
//  AddWordViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/04.
//

import UIKit

class AddWordViewController: UIViewController {
    
    override var sheetPresentationController: UISheetPresentationController {
        presentationController as! UISheetPresentationController
    }
    
    var wordList: [Word] = []
    
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
    
    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sheetPresentationController.detents = [.medium()]
        wordList = CoreDataManager.shared.fetchWord()
        
        configureLayoutStyle()
        
        configureInputField()
        self.saveButton.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print(wordList)
    }
    
    // MARK: IBAction 함수
    @IBAction func startEditingTextField(_ sender: UITextField) {
        sender.layer.borderWidth = 0.5
        sender.layer.borderColor = UIColor.NColor.blue.cgColor
        sender.layer.cornerRadius = 5.0
    }
    
    @IBAction func endEditingTextField(_ sender: UITextField) {
        sender.layer.borderWidth = 0.5
        sender.layer.borderColor = UIColor.NColor.border.cgColor
        sender.layer.cornerRadius = 5.0
    }
    
    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func tapSaveButton(_ sender: UIButton) {
        let name = nameTextField.text ?? ""
        let meaning = meaningTextField.text ?? ""
        let synoym = synoymTextField.text ?? ""
        let example = exampleTextField.text ?? ""
        
        CoreDataManager.shared.addWord(name: name, meaning: meaning, synoym: synoym, example: example, createTime: Date(), cntWrong: 0)

        self.presentingViewController?.dismiss(animated: true)
    }
    
    private func configureLayoutStyle() {
        saveButton.titleLabel?.font = UIFont.NFont.addWordButtonLabel
        saveButton.sizeToFit()
        
        cancelButton.titleLabel?.font = UIFont.NFont.addWordButtonLabel
        
        titleLabel.font = UIFont.NFont.addWordNavigationTitle
        
        wordName.font = UIFont.NFont.addWordButtonLabel
        wordMeaning.font = UIFont.NFont.addWordButtonLabel
        wordSynoym.font = UIFont.NFont.addWordButtonLabel
        wordExample.font = UIFont.NFont.addWordButtonLabel
    }
    
    @objc private func saveButtonState() {
        if nameTextField.text != "" && meaningTextField.text != "" && checkSameWord() {
            saveButton.isEnabled = true
        } else { saveButton.isEnabled = false }
    }
    
    private func checkSameWord() -> Bool {
        let wordString = nameTextField.text ?? ""
        for word in wordList {
            if word.name == wordString {
                return false
            }
        }
        return true
    }
    
    @objc private func isSameWord() {
        let wordString = nameTextField.text
        for word in wordList {
            if wordString == word.name {
                saveButton.isEnabled = false
            }
        }
    }
    
    private func configureInputField() {
        self.nameTextField.addTarget(self, action: #selector(saveButtonState), for: .editingChanged)
        self.nameTextField.addTarget(self, action: #selector(isSameWord), for: .editingDidEnd)
        self.meaningTextField.addTarget(self, action: #selector(saveButtonState), for: .editingChanged)
    }
}
