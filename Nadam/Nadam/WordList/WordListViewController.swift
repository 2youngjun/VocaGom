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
//        self.addWordButton.tintColor = UIColor.NColor.orange
        
        self.fetchWordDateDecesending()
        
        self.configureAddWordButton()
        self.configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.wordList = CoreDataManager.shared.fetchWord()
        self.fetchWordDateDecesending()
        self.collectionView.reloadData()
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addWordButton: UIButton!
    
    var wordList: [Word] = [] {
        didSet {
            CoreDataManager.shared.saveContext()
        }
    }
    
    private func configureAddWordButton() {
        self.addWordButton.showsMenuAsPrimaryAction = true
        
        let addHandButton = UIAction(title: "입력으로 추가하기", image: UIImage(systemName: "applepencil")) { _ in
            self.tapAddHandButton()
        }
        
        let addCameraButton = UIAction(title: "사진으로 추가하기", image: UIImage(systemName: "camera.fill")) { _ in
            self.tapAddCameraButton()
        }
        
        let menu = UIMenu(title: "단어 추가하기", children: [addHandButton, addCameraButton])
        self.addWordButton.menu = menu
        self.addWordButton.showsMenuAsPrimaryAction = true
    }
    
    @IBAction func tapAddWordButton(_ sender: UIButton) {
        
    }
    
    private func tapAddHandButton() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "AddWordView", bundle:nil)
        guard let addWordViewController = storyBoard.instantiateViewController(withIdentifier: "AddWordViewController") as? AddWordViewController else {return}
        addWordViewController.delegate = self
        
//        self.present(addWordViewController, animated:true, completion:nil)
        self.navigationController?.pushViewController(addWordViewController, animated: true)
    }
    
    private func tapAddCameraButton() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "AddCameraView", bundle:nil)
        guard let addCameraViewController = storyBoard.instantiateViewController(withIdentifier: "AddCameraViewController") as? AddCameraViewController else {return}
//        addCameraViewController.delegate = self
        
        self.navigationController?.pushViewController(addCameraViewController, animated: true)
    }

    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.backgroundColor = UIColor.NColor.background
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }
    
    private func fetchWordDateDecesending() {
        self.wordList = CoreDataManager.shared.fetchWord()
        self.wordList = self.wordList.sorted(by: {
            $0.createTime?.compare($1.createTime!) == .orderedDescending
        })
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
        cell.layer.cornerRadius = 10.0
        cell.backgroundColor = UIColor.NColor.white
        cell.wordName.font = UIFont.NFont.wordListWordName
        cell.wordName.textColor = UIColor.NColor.blue
        cell.wordMeaning.font = UIFont.NFont.wordListWordMeaning
        cell.wordMeaning.textColor = UIColor.NColor.black
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
        // createTime 기준 내림차순 정렬
        self.wordList = self.wordList.sorted(by: {
            $0.createTime?.compare($1.createTime!) == .orderedDescending
        })
    }
}
