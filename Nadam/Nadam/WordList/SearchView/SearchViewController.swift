//
//  SearchViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/09/03.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {
    

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var wordList = [Word]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.NColor.background
        wordList = CoreDataManager.shared.fetchWord()
//        self.configureCollectionView()
        configureSearchBar()
    }
    
    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.backgroundColor = UIColor.NColor.background
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 20, right: 20)
        
    }
    
    private func configureSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "찾고 싶은 단어를 입력해주세요."
        searchBar.setImage(UIImage(), for: .search, state: .normal)
        searchBar.searchBarStyle = .prominent
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = UIColor.NColor.white
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor.NColor.white
            textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.NColor.border])

            textField.font = UIFont.NFont.searchBarTextFieldFont
            textField.textColor = UIColor.NColor.black
        }
    }
    
    @IBAction func tapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension SearchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
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

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 40, height: 80)
    }
}
