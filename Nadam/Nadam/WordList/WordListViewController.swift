//
//  WordListViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/04.
//

import UIKit

class WordListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.font = UIFont.NFont.wordListTitleLabel
        titleLabel.sizeToFit()
        self.view.backgroundColor = UIColor.NColor.background
        self.addWordButton.tintColor = UIColor.NColor.orange
        
        self.wordList = CoreDataManager.shared.fetchWord()
        
        self.configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.wordList = CoreDataManager.shared.fetchWord()
        self.collectionView.reloadData()
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var addWordButton: UIButton!
    
    var wordList: [Word] = []
    
    @IBAction func tapAddWordButton(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "AddWordView", bundle:nil)
        guard let addWordViewController = storyBoard.instantiateViewController(withIdentifier: "AddWordViewController") as? AddWordViewController else {return}
        addWordViewController.delegate = self
        
        self.present(addWordViewController, animated:true, completion:nil)
    }

    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewLayout()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }
}

extension WordListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.wordList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordCell", for: indexPath) as? WordCell else { return UICollectionViewCell() }
        let word = wordList[indexPath.row]
        cell.wordName.text = word.name
        cell.wordMeaning.text = word.meaning
        return cell
    }
}

extension WordListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 40, height: 80)
    }
}

extension WordListViewController: AddWordViewDelegate {
    func didSelectSaveWord() {
        self.wordList = CoreDataManager.shared.fetchWord()
        let indexPath = IndexPath(row: wordList.count - 1, section: 0)

        collectionView.reloadData()
        if indexPath.row == 0 {
            collectionView.deleteItems(at: [indexPath])
        }
        collectionView.insertItems(at: [indexPath])
    }
}
