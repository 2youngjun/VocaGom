//
//  SelectTestListViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/09/27.
//

import UIKit

class SelectTestListViewController: UIViewController, UISheetPresentationControllerDelegate {
    
    //MARK: Variables
    var wordList = [Word]()
    var whichTestIndex: Int = 0
    override var sheetPresentationController: UISheetPresentationController {
        presentationController as! UISheetPresentationController
    }
    
    //MARK: IBOutlet Variables
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet var listButtonCollection: [UIButton]!
    @IBOutlet weak var allWordListButton: UIButton!
    @IBOutlet weak var favoriteWordListButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    
    //MARK: IBOutlet Function
    @IBAction func tapAllWordListButton(_ sender: UIButton) {
        let messageComment = "단어장에 단어를 추가한 후 다시 진행해 주세요."
        if wordList.isEmpty {
            self.showAlertNoWord(messageComment: messageComment)
        } else {
            NotificationCenter.default.post(name: Notification.Name("main"), object: self.whichTestIndex)
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func tapDismissButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func tapFavoriteWordListButton(_ sender: UIButton) {
        var favoriteWordList = [Word]()
        let messageComment = "즐겨찾기 단어장에 단어를 추가한 후 다시 진행해 주세요."
        self.wordList.forEach { word in
            if word.isStar {
                favoriteWordList.append(word)
            }
        }
        
        if favoriteWordList.isEmpty {
            self.showAlertNoWord(messageComment: messageComment)
        } else {
            self.dismiss(animated: true)
            NotificationCenter.default.post(name: Notification.Name("favorite"), object: self.whichTestIndex)
        }
    }
    
    //MARK: View Lifecycle Function
    override func viewDidLoad() {
        super.viewDidLoad()
        self.wordList = CoreDataManager.shared.fetchWord()
        self.styleFunction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.wordList = CoreDataManager.shared.fetchWord()
        self.configureSheetVersion()
    }
    
    //MARK: Style Function
    private func styleFunction() {
        self.configureTitleLabel()
        self.configureListButton()
        self.configureDismissButton()
    }
    
    private func configureSheetVersion() {
        if #available(iOS 16.0, *) {
            sheetPresentationController.detents = [
                .custom { context in
                    return context.maximumDetentValue * 0.3
                }
            ]
        } else {
            sheetPresentationController.detents = [
                .medium()
            ]
        }
    }
    
    private func configureTitleLabel() {
        self.view.backgroundColor = UIColor.NColor.white
        self.mainTitleLabel.font = UIFont.NFont.testMainLabelFont
        self.mainTitleLabel.textColor = UIColor.NColor.black
        self.mainTitleLabel.sizeToFit()
    }
    
    private func configureListButton() {
        self.listButtonCollection.forEach { button in
            var buttonTitle = AttributedString.init(button.titleLabel?.text ?? "")
            buttonTitle.font = UIFont.NFont.testMainLabelFont
            button.configuration?.attributedTitle = buttonTitle
            button.layer.cornerRadius = button.bounds.height / 2
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.NColor.blue.cgColor
        }
        self.allWordListButton.configuration?.background.backgroundColor = UIColor.NColor.white
        self.allWordListButton.tintColor = UIColor.NColor.blue
        self.favoriteWordListButton.backgroundColor = UIColor.NColor.blue
        self.favoriteWordListButton.tintColor = UIColor.NColor.white
    }
    
    private func configureDismissButton() {
        self.dismissButton.tintColor = UIColor.NColor.black
    }
    
    private func showAlertNoWord(messageComment: String) {
        let alert = UIAlertController(title: "테스트할 단어가 없습니다.",
                                      message: messageComment,
                                      preferredStyle: .alert)
        
        let cancelAlert = UIAlertAction(title: "확인",
                                        style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        
        [cancelAlert].forEach(alert.addAction(_:))
        
        self.present(alert, animated: false)
    }
}

extension SelectTestListViewController: SendWhichTestIndex {
    func sendWhichTestIndex(index: Int) {
        self.whichTestIndex = index
    }
}
