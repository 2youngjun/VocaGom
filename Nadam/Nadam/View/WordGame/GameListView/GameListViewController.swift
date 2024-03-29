//
//  GameListViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/20.
//

import UIKit

protocol SendWhichTestIndex: AnyObject {
    func sendWhichTestIndex(index: Int)
}

protocol SendTestListDelegate: AnyObject {
    func sendTestList(testList: [Word])
}

class GameListViewController: UIViewController {
    
    var wordList = [Word]()
    var whichTestIndex = 0
    weak var delegate: SendWhichTestIndex?
    weak var delegateRainTest: SendTestListDelegate?
    weak var delegateSpellingTest: SendTestListDelegate?
    
    lazy var selectTestListViewController: SelectTestListViewController = {
        let storyboard = UIStoryboard(name: "SelectTestListView", bundle: nil)
        guard let selectTestListViewController = storyboard.instantiateViewController(withIdentifier: "SelectTestListViewController") as? SelectTestListViewController else { return UIViewController() as! SelectTestListViewController }
        return selectTestListViewController
    }()
    
    let spellingTestViewController: SpellingTestViewController = {
        let storyboard = UIStoryboard(name: "SpellingTestView", bundle: nil)
        guard let spellingTestViewController = storyboard.instantiateViewController(withIdentifier: "SpellingTestViewController") as? SpellingTestViewController else { return UIViewController() as! SpellingTestViewController }
        return spellingTestViewController
    }()
    
    let rainTestViewController: RainTestViewController = {
        let storyboard = UIStoryboard(name: "RainTestView", bundle: nil)
        guard let rainTestViewController = storyboard.instantiateViewController(withIdentifier: "RainTestViewController") as? RainTestViewController else { return UIViewController() as! RainTestViewController }
        return rainTestViewController
    }()
    
    //MARK: IBOutlet Variable
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var spellingTestMainImage: UIImageView!
    @IBOutlet weak var spellingTestButtonImage: UIImageView!
    @IBOutlet weak var rainTestMainImage: UIImageView!
    
    @IBOutlet var testButtonViewCollection: [UIView]!
    @IBOutlet var testSubLabelCollection: [UILabel]!
    @IBOutlet var testMainLabelCollection: [UILabel]!
    @IBOutlet var testButtonCollection: [UIButton]!
    
    //MARK: View Lifecycle Function
    override func viewDidLoad() {
        super.viewDidLoad()
        self.styleFunction()
        self.delegate = self.selectTestListViewController
        self.delegateRainTest = self.rainTestViewController
        self.delegateSpellingTest = self.spellingTestViewController
        NotificationCenter.default.addObserver(self, selector: #selector(isMainWordTest(_:)), name: Notification.Name("main"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(isFavoriteWordTest(_:)), name: Notification.Name("favorite"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.wordList = CoreDataManager.shared.fetchWord()
    }
    
    @objc func isMainWordTest(_ notification: Notification) {
        guard let data = notification.object as? Int else { return }
        self.whichTestIndex = data
        if self.whichTestIndex == 0 {
            self.delegateRainTest?.sendTestList(testList: self.wordList)
            self.navigationController?.pushViewController(self.rainTestViewController, animated: true)
        } else {
            self.delegateSpellingTest?.sendTestList(testList: self.wordList)
            self.navigationController?.pushViewController(self.spellingTestViewController, animated: true)
        }
    }
    
    @objc func isFavoriteWordTest(_ notification: Notification) {
        guard let data = notification.object as? Int else { return }
        self.whichTestIndex = data
        
        var favoriteWordList = [Word]()
        self.wordList.forEach { word in
            if word.isStar {
                favoriteWordList.append(word)
            }
        }
        
        if self.whichTestIndex == 0 {
            self.delegateRainTest?.sendTestList(testList: favoriteWordList)
            self.navigationController?.pushViewController(self.rainTestViewController, animated: true)
        } else {
            self.delegateSpellingTest?.sendTestList(testList: favoriteWordList)
            self.navigationController?.pushViewController(self.spellingTestViewController, animated: true)
        }
    }
    
    //MARK: IBAction Function
    @IBAction func tapRainTestButton(_ sender: UIButton) {
        self.whichTestIndex = sender.tag
        self.delegate?.sendWhichTestIndex(index: self.whichTestIndex)
        self.present(self.selectTestListViewController, animated: true)
    }
    
    @IBAction func tapSpellingTestButton(_ sender: UIButton) {
        self.whichTestIndex = sender.tag
        self.delegate?.sendWhichTestIndex(index: self.whichTestIndex)
        self.present(self.selectTestListViewController, animated: true)
    }
    
    //MARK: Style Function
    private func styleFunction() {
        self.view.backgroundColor = UIColor.NColor.background
        self.configureTitleLabel()
        self.configureSpellingTestButtonView()
        self.wordList = CoreDataManager.shared.fetchWord()
    }
    
    private func configureTitleLabel() {
        self.titleLabel.font = UIFont.NFont.wordListTitleLabel
        self.titleLabel.textColor = UIColor.NColor.blue
    }
    
    private func configureSpellingTestButtonView() {
        self.testButtonViewCollection.forEach { testButtonView in
            testButtonView.layer.cornerRadius = 10.0
        }
        
        self.testSubLabelCollection.forEach { testSubLabel in
            testSubLabel.font = UIFont.NFont.testSubLabelFont
            testSubLabel.textColor = UIColor.NColor.gray
        }
        
        self.testMainLabelCollection.forEach { testMainLabel in
            testMainLabel.font = UIFont.NFont.testMainLabelFont
            testMainLabel.textColor = UIColor.NColor.black
        }
        
        self.testButtonCollection.forEach { testButton in
            testButton.layer.opacity = 1.0
            testButton.tintColor = UIColor.clear
            testButton.layer.cornerRadius = 10.0
        }
        
        self.testButtonCollection.indices.forEach { index in
            self.testButtonCollection[index].tag = index
        }
        
        self.spellingTestMainImage.image = UIImage(named: "rainTest")
        self.rainTestMainImage.image = UIImage(named: "spellingTest")
    }
}
