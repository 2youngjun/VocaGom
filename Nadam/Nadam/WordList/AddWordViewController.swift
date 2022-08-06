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
        setLayoutStyle()
    }
    
    // MARK: IBAction 함수
    @IBAction func startEditingTextField(_ sender: UITextField) {
        sender.layer.borderWidth = 1
        sender.layer.borderColor = UIColor.blue.cgColor
        sender.layer.cornerRadius = 6.5
    }
    
    @IBAction func endEditingTextField(_ sender: UITextField) {
        sender.layer.borderWidth = 1
        sender.layer.borderColor = UIColor.red.cgColor
        sender.layer.cornerRadius = 6.5
    }
    
    
    @IBAction func detectSaveState(_ sender: Any) {
        saveButtonState()
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
    
    func setLayoutStyle() {
        saveButton.titleLabel?.font = UIFont.NFont.addWordButtonLabel
        saveButton.sizeToFit()
        saveButton.isEnabled = false
        
        cancelButton.titleLabel?.font = UIFont.NFont.addWordButtonLabel
//        cancelButton.sizeToFit()
        
        titleLabel.font = UIFont.NFont.addWordNavigationTitle
//        titleLabel.sizeToFit()
        
        wordName.font = UIFont.NFont.addWordButtonLabel
        wordMeaning.font = UIFont.NFont.addWordButtonLabel
        wordSynoym.font = UIFont.NFont.addWordButtonLabel
        wordExample.font = UIFont.NFont.addWordButtonLabel
    }
    
    func saveButtonState() {
        if nameTextField.text != "" && meaningTextField.text != "" {
            checkSameWord()
        } else { saveButton.isEnabled = false }
    }
    
    // TODO: 동일한 단어인지 체크하는 함수 추가
    func checkSameWord() {
        let wordString = nameTextField.text ?? ""
        for word in wordList {
            if word.name == wordString {
                saveButton.isEnabled = false
                // 동일한 단어라는 문구
            }
        }
        saveButton.isEnabled = true
    }
    
    
}
