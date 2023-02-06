//
//  ResultWordViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/09/13.
//

import UIKit

class ResultWordViewController: UIViewController {

    var tossedWords = [TestWords]()
    var wordList = [Word]()
    var wordNameColor = UIColor()
    var navigationTitle = String()
    public var prohibitToast = true
    
    //MARK: IBOutlet
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: View Lifecycle Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.wordList = CoreDataManager.shared.fetchWord()
        self.styleFunction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.configureTitleText()
        self.collectionView.reloadData()
        self.prohibitToast = true
    }

    //MARK: IBAction
    @IBAction func tapBackButton(_ sender: UIButton) {
        self.prohibitToast = false
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Style Function
    private func styleFunction() {
        self.view.backgroundColor = UIColor.NColor.background
        self.configureTitleText()
        self.configureCollectionView()
    }
    
    private func configureTitleText() {
        self.titleText.font = UIFont.NFont.addWordNavigationTitle
        self.titleText.text = navigationTitle
    }
    
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.backgroundColor = UIColor.NColor.background
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.contentInset = UIEdgeInsets(top: 12, left: 20, bottom: 0, right: 20)
    }
}

extension ResultWordViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.tossedWords.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResultWordCell", for: indexPath) as? ResultWordCell else { return UICollectionViewCell() }
        let tossedWord = self.tossedWords[indexPath.row]
        cell.wordName.text = tossedWord.word.name
        cell.wordName.textColor = self.wordNameColor
        cell.wordMeaning.text = tossedWord.word.meaning
        cell.starButton.tag = indexPath.row
        cell.starButton.addTarget(self, action: #selector(tapStarButton(sender:)), for: .touchUpInside)
        cell.starButton.imageView?.image = tossedWord.word.isStar ? UIImage(named: "star_filled") : UIImage(named: "star")
        return cell
    }
    
    @objc func tapStarButton(sender: UIButton){
        tossedWords[sender.tag].word.isStar = !tossedWords[sender.tag].word.isStar
        if tossedWords[sender.tag].word.isStar {
            sender.isSelected = true
            for word in wordList {
                if tossedWords[sender.tag].word == word {
                    word.isStar = true
                }
            }
        } else {
            sender.isSelected = false
            for word in wordList {
                if tossedWords[sender.tag].word == word {
                    word.isStar = false
                }
            }
        }
        CoreDataManager.shared.saveContext()
    }
}

extension ResultWordViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 40, height: 80)
    }
}

extension ResultWordViewController: SendResultWordDelegate {
    func sendTestWordDelegate(resultWord: [TestWords], color: UIColor, titleText: String) {
        self.tossedWords = resultWord
        self.navigationTitle = titleText
        self.wordNameColor = color
    }
}

